function [processedFrame, tracks, nextId] = processHumanFrame(frame, detector, detectorType, tracks, nextId)
    % PROCESSHUMANFRAME Detects and tracks humans.
    
    % --- 1. DETECTION ---
    bboxes = [];
    
    % YOLOv8 and YOLOv4 use the same 'detect' signature in MATLAB
    if contains(detectorType, 'YOLO')
        try
            [bboxes, scores, labels] = detect(detector, frame);
            
            % YOLO detects everything (cars, dogs, etc.)
            % We must filter for 'person'
            isPerson = (labels == 'person');
            
            % Apply Threshold (Filter out low confidence predictions)
            confidenceThreshold = 0.5;
            isHighConf = scores > confidenceThreshold;
            
            % Combine filters
            keepIdx = isPerson & isHighConf;
            bboxes = bboxes(keepIdx, :);
        catch
            % If detection crashes (e.g. image format issue), return empty
            bboxes = [];
        end
        
    elseif strcmp(detectorType, 'ACF (Fallback)')
        [bboxes, ~] = detect(detector, frame);
        
    else
        % Simulation
        bboxes = [100 + nextId*2, 100, 50, 100];
    end
    
    % --- 2. TRACKING (Centroid Matching) ---
    centroids = [];
    if ~isempty(bboxes)
        centroids = [bboxes(:,1) + bboxes(:,3)/2, bboxes(:,2) + bboxes(:,4)/2];
    end
    
    nTracks = length(tracks);
    nDetections = size(bboxes, 1);
    
    % Cost matrix
    cost = zeros(nTracks, nDetections);
    for i = 1:nTracks
        trackCentroid = [tracks(i).bbox(1) + tracks(i).bbox(3)/2, tracks(i).bbox(2) + tracks(i).bbox(4)/2];
        for j = 1:nDetections
            cost(i, j) = norm(trackCentroid - centroids(j,:));
        end
    end
    
    % Assignment (Threshold: 50 pixels)
    [assignments, unassignedTracks, unassignedDetections] = assignDetectionsToTracks(cost, 50);
    
    % Update assigned tracks
    for i = 1:size(assignments, 1)
        trackIdx = assignments(i, 1);
        detIdx = assignments(i, 2);
        tracks(trackIdx).bbox = bboxes(detIdx, :);
        tracks(trackIdx).age = tracks(trackIdx).age + 1;
        tracks(trackIdx).totalVisibleCount = tracks(trackIdx).totalVisibleCount + 1;
        tracks(trackIdx).consecutiveInvisibleCount = 0;
    end
    
    % Update unassigned tracks (mark as invisible)
    for i = 1:length(unassignedTracks)
        idx = unassignedTracks(i);
        tracks(idx).consecutiveInvisibleCount = tracks(idx).consecutiveInvisibleCount + 1;
    end
    
    % Create new tracks
    for i = 1:length(unassignedDetections)
        detIdx = unassignedDetections(i);
        newTrack = struct(...
            'id', nextId, ...
            'bbox', bboxes(detIdx, :), ...
            'age', 1, ...
            'totalVisibleCount', 1, ...
            'consecutiveInvisibleCount', 0);
        tracks(end+1) = newTrack;
        nextId = nextId + 1;
    end
    
    % Prune lost tracks (invisible for > 10 frames)
    if ~isempty(tracks)
        ages = [tracks.consecutiveInvisibleCount];
        tracks(ages > 10) = [];
    end
    
    % --- 3. VISUALIZATION ---
    processedFrame = frame;
    if ~isempty(tracks)
        boxes = vertcat(tracks.bbox);
        ids = [tracks.id];
        labels = cellstr(num2str(ids', 'ID: %d'));
        
        % Check if we actually have valid boxes to draw
        if ~isempty(boxes)
            processedFrame = insertObjectAnnotation(processedFrame, 'rectangle', boxes, labels, ...
                'LineWidth', 3, 'FontSize', 18, 'Color', 'cyan');
        end
    end
end