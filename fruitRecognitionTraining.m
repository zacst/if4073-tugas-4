%% fruitRecognitionTraining.m - Fruit Recognition Training System
% 1. Loads images from 'Dataset' folder
% 2. Extracts features using extractFruitFeatures.m
% 3. Trains an SVM
% 4. Saves 'TrainedFruitModel.mat'

clear; clc; close all;

% --- CONFIGURATION ---
datasetPath = 'Dataset'; 

% 1. LOAD DATA
if ~isfolder(datasetPath)
    error('Error: "Dataset" folder not found. Please create it and add subfolders (Apple, Orange, etc.)');
end

disp('Loading images...');
% 'LabelSource', 'foldernames' automatically labels images based on their folder
imds = imageDatastore(datasetPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Split: 70% for training, 30% for testing accuracy
[trainSet, testSet] = splitEachLabel(imds, 0.7, 'randomized');

% 2. EXTRACT FEATURES FROM TRAINING SET
disp('Extracting features from Training Set...');
trainFeatures = [];
trainLabels = trainSet.Labels;

for i = 1:numel(trainSet.Files)
    img = readimage(trainSet, i);
    feat = extractFruitFeatures(img); % Call our helper function
    trainFeatures = [trainFeatures; feat];
end

% 3. TRAIN SVM MODEL
disp('Training SVM Model...');
% fitcecoc is the standard for Multiclass SVM in MATLAB
svmModel = fitcecoc(trainFeatures, trainLabels, ...
    'Learners', templateSVM('Standardize', true, 'KernelFunction', 'gaussian'));

% 4. TEST ACCURACY (OPTIONAL BUT RECOMMENDED)
disp('Testing Model Accuracy...');
testFeatures = [];
for i = 1:numel(testSet.Files)
    img = readimage(testSet, i);
    feat = extractFruitFeatures(img);
    testFeatures = [testFeatures; feat];
end

predictedLabels = predict(svmModel, testFeatures);
accuracy = mean(predictedLabels == testSet.Labels);
fprintf('Model Accuracy: %.2f%%\n', accuracy * 100);

% 5. SAVE THE TRAINED MODEL
save('TrainedFruitModel.mat', 'svmModel');
disp('SUCCESS: Model saved as "TrainedFruitModel.mat". You can now run the GUI.');