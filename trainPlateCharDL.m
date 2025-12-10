%% trainPlateCharDL.m - Deep Learning Plate Character Recognition Training
% This script generates synthetic character data and trains a CNN (Transfer Learning with AlexNet).

clear; clc; close all;

% --- CONFIGURATION ---
outputFolder = 'Dataset_Chars_v2'; % Changed folder name to force new robust generation
chars = ['0':'9', 'A':'Z'];
numSamplesPerChar = 50; 

% 1. Generate Synthetic Data
shouldGenerate = true;
if isfolder(outputFolder)
    d = dir(outputFolder);
    d = d([d.isdir]);
    if length(d) > 2
        shouldGenerate = false;
        disp('Dataset_Chars_v2 folder detected. Skipping generation.');
    end
end

if shouldGenerate
    if ~isfolder(outputFolder)
        mkdir(outputFolder);
    end
    
    disp('Generating ROBUST synthetic character dataset (with Noise & Blur)...');
    hFig = figure('Visible', 'off', 'Color', 'white');
    
    for i = 1:length(chars)
        charName = chars(i);
        charFolder = fullfile(outputFolder, charName);
        if ~isfolder(charFolder)
            mkdir(charFolder);
        end
        
        for j = 1:numSamplesPerChar
            clf; axis off;
            
            % Randomize font properties
            fontSize = 100 + randi([-15, 15]);
            rotAngle = randi([-15, 15]); % Increased rotation range
            
            % Draw text
            t = text(0.5, 0.5, charName, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', fontSize, ...
                'FontName', 'Arial', ...
                'FontWeight', 'bold', ...
                'Rotation', rotAngle, ...
                'Color', 'black');
                
            frame = getframe(gca);
            im = frame.cdata;
            
            if size(im, 3) == 3
                im = rgb2gray(im);
            end
            im = imbinarize(im);
            im = ~im; % White text on Black
            
            % Crop
            stats = regionprops(im, 'BoundingBox', 'Area');
            if ~isempty(stats)
                [~, idx] = max([stats.Area]);
                bbox = stats(idx).BoundingBox;
                im = imcrop(im, bbox);
            end
            
            % --- ADD NOISE & DISTORTION ---
            % Convert to double (0.0 to 1.0) because imnoise/imgaussfilt don't like logical
            im = double(im);

            % 1. Resize to standard BEFORE noise (so noise size is consistent)
            im = imresize(im, [227, 227]);
            
            % 2. Add Salt & Pepper Noise (simulates dirt)
            if rand > 0.3
                im = imnoise(im, 'salt & pepper', 0.05);
            end
            
            % 3. Add Gaussian Blur (simulates out of focus/motion)
            if rand > 0.3
                im = imgaussfilt(im, 1.5);
            end
            
            % 4. Randomly erode/dilate (simulates thin/thick print)
            r = rand;
            if r > 0.7
                im = imdilate(im, strel('square', 3));
            elseif r < 0.3
                im = imerode(im, strel('square', 3));
            end
            
            % Save
            imRGB = cat(3, im, im, im);
            fileName = fullfile(charFolder, sprintf('%s_%d.jpg', charName, j));
            imwrite(imRGB, fileName);
        end
    end
    close(hFig);
end

% 2. Load Data
imds = imageDatastore(outputFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
[imdsTrain, imdsValidation] = splitEachLabel(imds, 0.8, 'randomized');

% 3. Load Pre-trained Network (AlexNet)
try
    net = alexnet;
catch
    error('AlexNet not found. Please install the "Deep Learning Toolbox Model for AlexNet Network" support package.');
end

% 4. Modify Network
layers = net.Layers;
inputSize = net.Layers(1).InputSize; 

numClasses = numel(categories(imdsTrain.Labels));
layers(end-2) = fullyConnectedLayer(numClasses, 'Name', 'fc_char', ...
    'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10);
layers(end-1) = softmaxLayer('Name', 'softmax_char');
layers(end) = classificationLayer('Name', 'classoutput_char');

% 5. Training Options
% Use a small learning rate for fine-tuning
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 32, ...
    'MaxEpochs', 5, ...
    'InitialLearnRate', 1e-4, ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', 10, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% 6. Train
disp('Training Deep Learning Model for Characters...');
charNet = trainNetwork(imdsTrain, layers, options);

% 7. Save
save('TrainedPlateModelDL.mat', 'charNet');
disp('Model saved as TrainedPlateModelDL.mat');
