function [plateText, processedImg] = processPlateDL(img, net)
    % processPlateDL - Detects and recognizes license plate number using Deep Learning (CNN)
    % Assumes input 'img' is a cropped image of the license plate.
    
    if isempty(net)
        plateText = 'Model Not Loaded';
        processedImg = img;
        return;
    end

    % 1. Preprocessing
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
    
    [rows, cols] = size(gray);
    
    % Binarize using Otsu's method (Global) - usually better for cropped plates
    level = graythresh(gray);
    bin = imbinarize(gray, level);
    
    % Heuristic: Check border pixels to determine background color.
    % If borders are mostly White (1), then Background is White.
    % We want Text=1 (White), Background=0 (Black).
    borderPixels = [bin(1,:), bin(end,:), bin(:,1)', bin(:,end)'];
    if mean(borderPixels) > 0.5
        bin = ~bin;
    end
    
    % Clean up
    % Remove very small noise
    minArea = (rows * cols) * 0.002; % Reduced to 0.2% to catch small punctuation or thin chars
    bin = bwareaopen(bin, round(minArea));
    
    % 2. Find Candidate Regions
    stats = regionprops(bin, 'BoundingBox', 'Area', 'Image');
    
    plateText = '';
    processedImg = img;
    
    candidates = [];
    
    % Filter candidates
    for k = 1 : length(stats)
        bbox = stats(k).BoundingBox;
        w = bbox(3);
        h = bbox(4);
        aspectRatio = h / w;
        
        % Filter logic:
        % 1. Height: Characters should be reasonably tall relative to the plate image
        %    Relaxed to > 20% of image height.
        % 2. Aspect Ratio: Characters are usually taller than wide.
        %    Relaxed to 0.1 to 3.0.
        
        if h > (rows * 0.20) && h < (rows * 0.95) && ...
           aspectRatio > 0.1 && aspectRatio < 3.0
            
             candidates = [candidates; stats(k)];
        end
    end
    
    if isempty(candidates)
        plateText = 'No Characters Found';
        return;
    end
    
    % Sort candidates from Left to Right
    bboxes = vertcat(candidates.BoundingBox);
    [~, sortIdx] = sort(bboxes(:, 1));
    candidates = candidates(sortIdx);
    
    inputSize = net.Layers(1).InputSize; % [227 227 3]
    detectedChars = '';
    
    % Visualization
    hFig = figure('Visible', 'off');
    imshow(img); hold on;
    
    for k = 1 : length(candidates)
        % Extract Character Image (Binary)
        charImgBin = candidates(k).Image;
        
        % Pad the character slightly to preserve aspect ratio and not touch edges
        % AlexNet expects the object to be centered.
        [ch, cw] = size(charImgBin);
        pad = 5;
        charImgBin = padarray(charImgBin, [pad pad], 0, 'both');
        
        % Resize to CNN input size
        charImgResized = imresize(charImgBin, inputSize(1:2));
        
        % Convert to RGB (3 channels) - White text on Black background
        % 'classify' works best with uint8 [0-255]
        charImgUint8 = uint8(charImgResized) * 255;
        charImgRGB = cat(3, charImgUint8, charImgUint8, charImgUint8);
        
        % Classify
        [predLabel, score] = classify(net, charImgRGB);
        
        % We accept the best guess
        detectedChars = [detectedChars, char(predLabel)];
        
        % Draw box
        rectangle('Position', candidates(k).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2);
    end
    
    plateText = detectedChars;
    
    % Capture processed image
    frame = getframe(gca);
    processedImg = frame.cdata;
    close(hFig);
end
