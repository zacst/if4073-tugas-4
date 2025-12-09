function features = extractFruitFeatures(img)
    % EXTRACTFRUITFEATURES Extracts Color and Shape features (incl. Aspect Ratio)
    % Output: [MeanHue, MeanSaturation, Circularity, AspectRatio]
    
    % 1. Standardize Image Size (100x100 is perfect for Fruits-360)
    img = imresize(img, [100 100]); 
    
    % 2. Convert to L*a*b* Color Space
    cform = makecform('srgb2lab');
    labImg = applycform(img, cform);
    
    % 3. K-Means Clustering (Segmentation)
    ab = double(labImg(:,:,2:3)); 
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab, nrows*ncols, 2);
    
    nColors = 3;
    try
        % Cluster colors (Background vs Fruit vs Shadow)
        [cluster_idx, cluster_centers] = kmeans(ab, nColors, 'Distance', 'sqEuclidean', 'Replicates', 3);
    catch
        features = [0, 0, 0, 0]; return;
    end
    
    pixel_labels = reshape(cluster_idx, nrows, ncols);
    
    % 4. Find the "Fruit" Cluster (Furthest from Gray)
    meanColors = zeros(nColors, 1);
    for k = 1:nColors
        centerA = cluster_centers(k, 1);
        centerB = cluster_centers(k, 2);
        distFromGray = sqrt((centerA - 128)^2 + (centerB - 128)^2);
        meanColors(k) = distFromGray;
    end
    
    [~, fruitClusterIdx] = max(meanColors);
    mask = (pixel_labels == fruitClusterIdx);
    
    % 5. Post-Processing
    mask = imfill(mask, 'holes');
    mask = bwareaopen(mask, 200);
    
    if sum(mask(:)) == 0
        features = [0, 0, 0, 0]; return;
    end
    
    % 6. Extract Features
    
    % --- Color Features ---
    hsvImg = rgb2hsv(img);
    hChannel = hsvImg(:,:,1);
    sChannel = hsvImg(:,:,2);
    meanHue = mean(hChannel(mask));
    meanSat = mean(sChannel(mask));
    
    % --- Shape Features ---
    props = regionprops(mask, 'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength');
    [~, maxIdx] = max([props.Area]);
    fruitProps = props(maxIdx);
    
    % Feature 3: Circularity
    if fruitProps.Perimeter == 0
        circularity = 0;
    else
        circularity = (4 * pi * fruitProps.Area) / (fruitProps.Perimeter ^ 2);
    end
    
    % Feature 4: Aspect Ratio (CRITICAL FOR BANANA VS LEMON)
    % 1.0 = Circle. Low value (0.3) = Long.
    if fruitProps.MajorAxisLength == 0
        aspectRatio = 0;
    else
        aspectRatio = fruitProps.MinorAxisLength / fruitProps.MajorAxisLength;
    end
    
    % Return 4 features
    features = [meanHue, meanSat, circularity, aspectRatio];
end