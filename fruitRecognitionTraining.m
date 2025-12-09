%% fruitRecognitionTraining.m - Fruit Recognition Training System
% 1. Loads images from 'Dataset' folder
% 2. Extracts 4 features (Hue, Sat, Circ, AspectRatio) using extractFruitFeatures.m
% 3. Trains SVM with Class Balancing
% 4. Saves 'TrainedFruitModel.mat'

clear; clc; close all;

% --- CONFIGURATION ---
datasetPath = 'Dataset'; 

% 1. LOAD DATA
if ~isfolder(datasetPath)
    error('Error: "Dataset" folder not found. Please create it and add subfolders (Apple, Banana, Orange, etc.)');
end

disp('Loading images...');
% 'LabelSource', 'foldernames' automatically labels images based on their folder
imds = imageDatastore(datasetPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% --- BALANCE CLASSES ---
% It limits all fruits to the count of the smallest folder.
countTbl = countEachLabel(imds);
minCount = min(countTbl.Count);
disp(['Balancing dataset: Using ' num2str(minCount) ' images per fruit type.']);

[imdsBalanced, ~] = splitEachLabel(imds, minCount, 'randomized');

% Split: 70% Training, 30% Testing
[trainSet, testSet] = splitEachLabel(imdsBalanced, 0.7, 'randomized');

% 2. EXTRACT FEATURES FROM TRAINING SET
disp('Extracting features from Training Set (this may take a moment)...');
trainFeatures = [];
trainLabels = trainSet.Labels;

% Loop through training images
for i = 1:numel(trainSet.Files)
    img = readimage(trainSet, i);
    % extractFruitFeatures now returns [MeanHue, MeanSat, Circularity, AspectRatio]
    feat = extractFruitFeatures(img); 
    trainFeatures = [trainFeatures; feat];
end

% 3. TRAIN SVM MODEL
disp('Training SVM Model...');
% fitcecoc is the standard for Multiclass SVM in MATLAB
% We Standardize features because 'Circularity' (0-1) and 'Hue' (0-1) are different scales
svmModel = fitcecoc(trainFeatures, trainLabels, ...
    'Learners', templateSVM('Standardize', true, 'KernelFunction', 'gaussian'));

% 4. TEST ACCURACY
disp('Testing Model Accuracy...');
testFeatures = [];
for i = 1:numel(testSet.Files)
    img = readimage(testSet, i);
    feat = extractFruitFeatures(img);
    testFeatures = [testFeatures; feat];
end

predictedLabels = predict(svmModel, testFeatures);
accuracy = mean(predictedLabels == testSet.Labels);
fprintf('<strong>Model Accuracy: %.2f%%</strong>\n', accuracy * 100);

% Show Confusion Matrix to see which fruits get confused
figure;
confusionchart(testSet.Labels, predictedLabels);
title(['Confusion Matrix (Accuracy: ' num2str(accuracy*100, '%.1f') '%)']);

% 5. SAVE
save('TrainedFruitModel.mat', 'svmModel');
disp('SUCCESS: Model saved as "TrainedFruitModel.mat". You can now run FruitRecognitionGUI.');