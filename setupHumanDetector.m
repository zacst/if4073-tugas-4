function [detector, detectorType] = setupHumanDetector()
    % SETUPHUMANDETECTOR Initializes the object detector.
    % Order of preference: YOLOv8 -> YOLOv4 -> ACF -> Simulation
    
    detector = [];
    detectorType = '';
    
    % --- 1. YOLOv4 (Available in R2021a+) ---
    try
        % Requires 'Computer Vision Toolbox Model for YOLO v4 Object
        % Detection' and 'Deep Learning Toolbox'
        detector = yolov4ObjectDetector('tiny-yolov4-coco');
        detectorType = 'YOLOv4';
        disp('Success: Loaded YOLOv4 (Tiny).');
        return;
    catch ME
        disp(['YOLOv4 Failed: ' ME.message]);
        % Continue to try ACF...
    end
    
    % --- 2. Fallback: ACF (Aggregate Channel Features) ---
    try
        detector = peopleDetectorACF();
        detectorType = 'ACF (Fallback)';
        disp('Warning: using ACF Fallback (Lower accuracy).');
        disp('To fix YOLO: Home -> Add-Ons -> Get Add-Ons -> Search "YOLO v4" or "YOLO v8"');
    catch
        detectorType = 'Simulation';
    end
end