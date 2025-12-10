function [label, score] = processFruitDL(img, net)
    % processFruitDL - Classify fruit using Deep Learning model
    %
    % Inputs:
    %   img: Input image
    %   net: Trained SeriesNetwork (AlexNet based)
    %
    % Outputs:
    %   label: Predicted class label (string)
    %   score: Confidence score
    
    if isempty(net)
        error('Model not loaded.');
    end
    
    % Resize image to match AlexNet input
    inputSize = net.Layers(1).InputSize; % [227 227 3]
    imgResized = imresize(img, inputSize(1:2));
    
    % Classify
    [predLabel, scores] = classify(net, imgResized);
    
    label = char(predLabel);
    score = max(scores);
end
