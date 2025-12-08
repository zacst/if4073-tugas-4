function [plateText, processedImg] = processPlate(img)
    % processPlate - Detects and recognizes license plate number (Non-ML / Template Matching)
    %
    % Inputs:
    %   img: Input image (RGB or Grayscale)
    %
    % Outputs:
    %   plateText: Recognized text string
    %   processedImg: Image with bounding box around the plate
    
    % 1. Preprocessing
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
    
    % Median filter to remove noise
    gray = medfilt2(gray);
    
    % 2. Edge Detection & Morphology
    edges = edge(gray, 'sobel');
    
    % DILATION: Use a much wider structuring element to bridge the gap 
    % between the region code (e.g. 'B') and the numbers (e.g. '1234').
    % Indonesian plates: "AA 1111 AA" -> gaps are significant.
    se = strel('rectangle', [4, 35]); 
    dilated = imdilate(edges, se);
    filled = imfill(dilated, 'holes');
    
    % Remove small noise regions
    minArea = size(img, 1) * size(img, 2) * 0.005; 
    cleaned = bwareaopen(filled, round(minArea));
    
    % 3. Find Candidate Regions
    stats = regionprops(cleaned, 'BoundingBox', 'Area', 'Image', 'Orientation');
    
    plateText = 'Not Found';
    processedImg = img;
    bestScore = 0;
    
    % Load Templates
    templates = getTemplates();
    
    % Sort by Area (Largest first)
    [~, sortIdx] = sort([stats.Area], 'descend');
    stats = stats(sortIdx);
    
    for k = 1 : length(stats)
        bbox = stats(k).BoundingBox;
        aspectRatio = bbox(3) / bbox(4);
        
        % Relaxed Aspect Ratio: Plates can be wide (2 to 8)
        if aspectRatio > 2 && aspectRatio < 8
            
            % Crop the candidate region
            % Add a small padding to avoid cutting off edges of characters
            padding = 5;
            rect = [bbox(1)-padding, bbox(2)-padding, bbox(3)+2*padding, bbox(4)+2*padding];
            plateRegion = imcrop(gray, rect);
            
            % 4. Process Candidate Region (Binarization)
            % Reverted to Global (Otsu) as it is often more robust for high contrast plates
            try
                bwPlate = imbinarize(plateRegion, 'global');
            catch
                % Fallback if crop is invalid
                continue;
            end
            
            % Ensure White Text on Black Background
            if mean(bwPlate(:)) > 0.5
                bwPlate = ~bwPlate;
            end
            
            % Clean up
            bwPlate = bwareaopen(bwPlate, 30); 
            % Do NOT use imclearborder here as it might remove the first/last letters 
            % if the crop is tight.
            
            % 5. Character Segmentation
            [L, num] = bwlabel(bwPlate);
            charStats = regionprops(L, 'BoundingBox', 'Image', 'Area');
            
            if num < 3
                continue;
            end
            
            % Robust Character Filtering
            % 1. Filter by Height relative to the Plate Region Height
            [h_plate, ~] = size(bwPlate);
            
            validChars = [];
            heights = [];
            
            % First pass: Collect heights of "reasonable" blobs to find the median
            for i = 1:num
                h = charStats(i).BoundingBox(4);
                % A character should be at least 30% of the plate height
                if h > h_plate * 0.3
                    heights = [heights, h];
                end
            end
            
            if isempty(heights)
                continue;
            end
            
            medianH = median(heights);
            
            % Second pass: Select characters based on median height
            for i = 1:num
                cBox = charStats(i).BoundingBox;
                cH = cBox(4);
                cW = cBox(3);
                
                % Allow wider variation (50% to 150% of median height)
                % This handles perspective distortion better.
                if cH > medianH * 0.5 && cH < medianH * 1.5 && ...
                   cW / cH < 1.5 && cW / cH > 0.05 % Aspect ratio check
                    validChars = [validChars; charStats(i)];
                end
            end
            
            % Sort characters left-to-right
            if ~isempty(validChars)
                [~, idx] = sort(arrayfun(@(x) x.BoundingBox(1), validChars));
                validChars = validChars(idx);
                
                % 6. Template Matching
                currentText = '';
                if isempty(templates)
                    currentText = 'NoTemplates';
                else
                    for j = 1:length(validChars)
                        charImg = validChars(j).Image;
                        letter = matchCharacter(charImg, templates);
                        currentText = [currentText letter];
                    end
                end
                
                % Scoring
                score = length(currentText);
                
                % We expect at least 4 characters for a valid plate
                if score > bestScore && score >= 4
                    bestScore = score;
                    plateText = currentText;
                    
                    % Draw bounding box
                    processedImg = insertShape(img, 'Rectangle', bbox, 'LineWidth', 4, 'Color', 'green');
                    processedImg = insertText(processedImg, [bbox(1), bbox(2)-30], plateText, 'FontSize', 18, 'BoxColor', 'green', 'TextColor', 'white');
                    
                    break; 
                end
            end
        end
    end
end

function letter = matchCharacter(im, templates)
    targetSize = [42, 24];
    im = imresize(im, targetSize);
    
    bestCorr = -inf;
    letter = '?';
    
    for k = 1:length(templates)
        temp = templates(k).Image;
        corr = corr2(double(im), double(temp));
        
        if corr > bestCorr
            bestCorr = corr;
            letter = templates(k).Label;
        end
    end
end

function templates = getTemplates()
    persistent t;
    if isempty(t)
        if exist('templates.mat', 'file')
            data = load('templates.mat');
            if isfield(data, 'templates')
                t = data.templates;
            else
                t = [];
            end
        else
            t = [];
        end
    end
    templates = t;
end
