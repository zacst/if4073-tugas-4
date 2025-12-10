function createTemplates()
    % createTemplates - Generates synthetic templates for OCR (A-Z, 0-9)
    % Saves the result to 'templates.mat'
    %
    % This script creates binary images of characters using a standard font (Arial),
    % which serves as a clean reference for Template Matching.
    
    chars = ['0':'9', 'A':'Z'];
    templates = struct('Image', {}, 'Label', {});
    
    % Target size must match the resize operation in processPlate.m
    % processPlate.m uses [42, 24] (Height, Width)
    targetSize = [42, 24]; 
    
    fprintf('Generating templates...\n');
    
    % Create a hidden figure to render text
    hFig = figure('Visible', 'off', 'Color', 'white');
    
    for i = 1:length(chars)
        c = chars(i);
        
        % Clear axes
        clf;
        axis off;
        
        % Draw text centered in the figure
        % Arial Bold is a good approximation for license plates
        t = text(0.5, 0.5, c, ...
            'Units', 'normalized', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 100, ...
            'FontName', 'Arial', ... 
            'FontWeight', 'bold', ...
            'Color', 'black');
            
        % Capture the figure content
        frame = getframe(gca);
        im = frame.cdata;
        
        % Convert to grayscale
        if size(im, 3) == 3
            im = rgb2gray(im);
        end
        
        % Binarize:
        % The captured image has Black text on White background.
        % We want White text (1) on Black background (0) for correlation.
        % Threshold at 128 (midpoint)
        bw = im < 128;
        
        % Crop to the character's bounding box
        % regionprops finds the connected components (the character)
        stats = regionprops(bw, 'Image', 'Area');
        
        if isempty(stats)
            warning(['Could not generate template for: ' c]);
            continue;
        end
        
        % If there are multiple regions (e.g. noise or disjoint parts like in 'i' or 'j' - though we only do A-Z 0-9),
        % take the one with the largest area.
        % Note: For 0-9 A-Z, characters are usually single connected components 
        % (except maybe if the font has gaps, but Arial is solid).
        [~, maxIdx] = max([stats.Area]);
        charImg = stats(maxIdx).Image;
        
        % Resize to the standard target size
        charImg = imresize(charImg, targetSize);
        
        % Store in struct
        templates(i).Label = c;
        templates(i).Image = charImg;
    end
    
    % Clean up
    close(hFig);
    
    % Save to .mat file
    save('templates.mat', 'templates');
    fprintf('Successfully created templates.mat with %d characters.\n', length(templates));
end
