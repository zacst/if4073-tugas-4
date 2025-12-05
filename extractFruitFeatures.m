function features = extractFruitFeatures(img)
    % EXTRACTFRUITFEATURES Extracts features using K-Means Clustering
    % Robust against complex/varied backgrounds.
    
    % 1. Standardize Image Size
    img = imresize(img, [128 128]); % Smaller size for faster K-Means
    
    % 2. Convert to L*a*b* Color Space
    % L*a*b* is better for color distance segmentation than RGB or HSV
    cform = makecform('srgb2lab');
    labImg = applycform(img, cform);
    
    % 3. K-Means Clustering
    % Flatten the image to list of pixels (N x 3)
    ab = double(labImg(:,:,2:3)); % Take only a* and b* (color) channels
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab, nrows*ncols, 2);
    
    % Cluster into 3 regions (e.g., Fruit, Background, Highlights)
    nColors = 3;
    try
        % 'Replicates' reduces chances of bad local minima
        [cluster_idx, cluster_centers] = kmeans(ab, nColors, 'Distance', 'sqEuclidean', 'Replicates', 3);
    catch
        % Fallback if image is too small or uniform
        features = [0, 0, 0];
        return;
    end
    
    pixel_labels = reshape(cluster_idx, nrows, ncols);
    
    % 4. Determine which cluster is the fruit
    % Strategy: The fruit is usually the cluster with the highest color intensity 
    % (distance from center of Lab space, which is gray)
    
    % Center of Lab color plane (neutral gray) is roughly [128, 128] for uint8
    % However, 'ab' here is double. In standard Lab, a=0, b=0 is gray. 
    % But applycform outputs offset values where ~128 is 0.
    % Let's measure magnitude of color away from gray.
    
    meanColors = zeros(nColors, 1);
    for k = 1:nColors
        % Get mean 'a' and 'b' of this cluster
        centerA = cluster_centers(k, 1);
        centerB = cluster_centers(k, 2);
        
        % Calculate distance from neutral gray (128, 128 in uint8 representation)
        distFromGray = sqrt((centerA - 128)^2 + (centerB - 128)^2);
        meanColors(k) = distFromGray;
    end
    
    [~, fruitClusterIdx] = max(meanColors);
    
    % Create Binary Mask for the Fruit Cluster
    mask = (pixel_labels == fruitClusterIdx);
    
    % 5. Post-Processing (Cleanup)
    mask = imfill(mask, 'holes');
    mask = bwareaopen(mask, 200); % Remove small noise
    
    if sum(mask(:)) == 0
        features = [0, 0, 0];
        return;
    end
    
    % 6. Extract Features (using robust mask)
    hsvImg = rgb2hsv(img);
    hChannel = hsvImg(:,:,1);
    sChannel = hsvImg(:,:,2);
    
    meanHue = mean(hChannel(mask));
    meanSat = mean(sChannel(mask));
    
    props = regionprops(mask, 'Area', 'Perimeter');
    [~, maxIdx] = max([props.Area]);
    fruitProps = props(maxIdx);
    
    if fruitProps.Perimeter == 0
        circularity = 0;
    else
        circularity = (4 * pi * fruitProps.Area) / (fruitProps.Perimeter ^ 2);
    end
    
    features = [meanHue, meanSat, circularity];
end