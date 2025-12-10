%% trainFruitDL.m - Deep Learning Fruit Recognition Training
% This script uses Transfer Learning with a pre-trained AlexNet model.
% It requires the Deep Learning Toolbox and the AlexNet support package.

clear; clc; close all;

datasetPath = 'Dataset';
if ~isfolder(datasetPath)
    error('Dataset folder not found.');
end

% 1. Load Data
imds = imageDatastore(datasetPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Balance the dataset
countTbl = countEachLabel(imds);
minCount = min(countTbl.Count);
[imdsBalanced, ~] = splitEachLabel(imds, minCount, 'randomized');

% Split into training and validation
[imdsTrain, imdsValidation] = splitEachLabel(imdsBalanced, 0.7, 'randomized');

% 2. Load Pre-trained Network (AlexNet)
try
    net = alexnet;
catch
    error('AlexNet not found. Please install the "Deep Learning Toolbox Model for AlexNet Network" support package.');
end

% 3. Modify Network for Transfer Learning
% The last three layers of AlexNet are for 1000 classes. We replace them.
layers = net.Layers;
inputSize = net.Layers(1).InputSize; % 227x227x3

% Replace the last fully connected layer
numClasses = numel(categories(imdsTrain.Labels));
layers(end-2) = fullyConnectedLayer(numClasses, 'Name', 'fc_fruit', ...
    'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10);

% Replace the softmax and classification layers
layers(end-1) = softmaxLayer('Name', 'softmax_fruit');
layers(end) = classificationLayer('Name', 'classoutput_fruit');

% 4. Resize Images
% AlexNet requires 227x227 images. We use an augmented image datastore.
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection', true, ...
    'RandXTranslation', pixelRange, ...
    'RandYTranslation', pixelRange);

augimdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain, ...
    'DataAugmentation', imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2), imdsValidation);

% 5. Training Options
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 10, ...
    'MaxEpochs', 6, ...
    'InitialLearnRate', 1e-4, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augimdsValidation, ...
    'ValidationFrequency', 3, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% 6. Train the Network
disp('Training Deep Learning Model for Fruits...');
fruitNet = trainNetwork(augimdsTrain, layers, options);

% 7. Save Model
save('TrainedFruitModelDL.mat', 'fruitNet');
disp('Model saved as TrainedFruitModelDL.mat');
