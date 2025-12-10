function GUI()
    % --- 1. GUI Setup ---
    close all force;
    
    % Theme Colors
    theme.bg        = [0.94 0.94 0.96];
    theme.panel     = [1.00 1.00 1.00];
    theme.text      = [0.20 0.20 0.20];
    theme.btnLoad   = [0.00 0.45 0.74];
    theme.btnRun    = [0.24 0.70 0.44];
    theme.btnExtra  = [0.80 0.40 0.20];
    theme.btnTrack  = [0.50 0.20 0.60];
    theme.font      = 'Segoe UI';
    
    % Create Main Window
    fig = figure('Name', 'Unified Recognition System Pro', ...
                 'NumberTitle', 'off', ...
                 'Units', 'normalized', ... 
                 'Position', [0.1 0.1 0.8 0.8], ...
                 'Color', theme.bg, ...
                 'ToolBar', 'none', ...
                 'MenuBar', 'none');
                 
    % Store Application Data
    appData = struct();
    appData.TrainedModel = [];
    appData.CurrentFruitImg = [];
    appData.CurrentPlateImg = [];
    appData.CurrentVideoPath = '';
    appData.IsTracking = false; 
    appData.Theme = theme; 
    set(fig, 'UserData', appData);
    
    % --- 2. Tab Group ---
    tabGroup = uitabgroup(fig, 'Position', [0 0 1 1]);
    
    % ==========================================================
    % TAB 1: FRUIT RECOGNITION
    % ==========================================================
    tabFruit = uitab(tabGroup, 'Title', 'Fruit Recognition');
    
    % Panels
    fruitImgPanel = uipanel(tabFruit, 'Title', '', ...
        'Units', 'normalized', 'Position', [0.02 0.27 0.96 0.71], ... 
        'BackgroundColor', theme.panel, 'BorderType', 'line');
    
    fruitCtrlPanel = uipanel(tabFruit, 'Title', 'Fruit Controls', ...
        'Units', 'normalized', 'Position', [0.02 0.02 0.96 0.23], ... 
        'BackgroundColor', theme.panel, 'FontName', theme.font, 'FontSize', 11);
                                
    % Buttons
    uicontrol(fruitCtrlPanel, 'Style', 'pushbutton', 'String', '1. LOAD FRUIT', ...
        'Units', 'normalized', 'Position', [0.02 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnLoad, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) loadFruitImage(fig));
                          
    uicontrol(fruitCtrlPanel, 'Style', 'pushbutton', 'String', '2. IDENTIFY FRUIT', ...
        'Units', 'normalized', 'Position', [0.24 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnRun, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) identifyFruit(fig));
                          
    % Labels
    uicontrol(fruitCtrlPanel, 'Style', 'text', 'String', 'RESULT:', ...
        'Units', 'normalized', 'Position', [0.68 0.65 0.30 0.2], ...
        'BackgroundColor', theme.panel, 'FontName', theme.font, ...
        'FontSize', 10, 'HorizontalAlignment', 'center', 'ForegroundColor', [0.5 0.5 0.5]);

    appData.ResultLabelFruit = uicontrol(fruitCtrlPanel, 'Style', 'text', 'String', 'Waiting for input...', ...
        'Units', 'normalized', 'Position', [0.68 0.15 0.30 0.5], ...
        'BackgroundColor', theme.panel, 'FontName', theme.font, ...
        'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'ForegroundColor', [0.7 0.7 0.7]);
                          
    appData.AxFruit = axes(fruitImgPanel, 'Position', [0.05 0.05 0.9 0.9]);
    set(appData.AxFruit, 'XTick', [], 'YTick', [], 'Box', 'on', 'Color', [0.98 0.98 0.98]);
    text(0.5, 0.5, 'Load a fruit image', 'Parent', appData.AxFruit, ...
        'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [0.6 0.6 0.6]);

    % ==========================================================
    % TAB 2: PLATE RECOGNITION
    % ==========================================================
    tabPlate = uitab(tabGroup, 'Title', 'Plate Recognition');
    
    plateImgPanel = uipanel(tabPlate, 'Title', '', ...
        'Units', 'normalized', 'Position', [0.02 0.27 0.96 0.71], ... 
        'BackgroundColor', theme.panel, 'BorderType', 'line');
    
    plateCtrlPanel = uipanel(tabPlate, 'Title', 'Plate Controls', ...
        'Units', 'normalized', 'Position', [0.02 0.02 0.96 0.23], ... 
        'BackgroundColor', theme.panel, 'FontName', theme.font, 'FontSize', 11);
                                
    uicontrol(plateCtrlPanel, 'Style', 'pushbutton', 'String', '1. LOAD PLATE', ...
        'Units', 'normalized', 'Position', [0.02 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnLoad, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) loadPlateImage(fig));
                          
    uicontrol(plateCtrlPanel, 'Style', 'pushbutton', 'String', '2. RECOGNIZE PLATE', ...
        'Units', 'normalized', 'Position', [0.24 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnExtra, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) recognizePlate(fig));
                          
    uicontrol(plateCtrlPanel, 'Style', 'text', 'String', 'DETECTED NUMBER:', ...
        'Units', 'normalized', 'Position', [0.68 0.65 0.30 0.2], ...
        'BackgroundColor', theme.panel, 'FontName', theme.font, ...
        'FontSize', 10, 'HorizontalAlignment', 'center', 'ForegroundColor', [0.5 0.5 0.5]);

    appData.ResultLabelPlate = uicontrol(plateCtrlPanel, 'Style', 'text', 'String', 'Waiting for input...', ...
        'Units', 'normalized', 'Position', [0.68 0.15 0.30 0.5], ...
        'BackgroundColor', theme.panel, 'FontName', theme.font, ...
        'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'ForegroundColor', [0.7 0.7 0.7]);
    
    appData.AxPlate = axes(plateImgPanel, 'Position', [0.05 0.05 0.9 0.9]);
    set(appData.AxPlate, 'XTick', [], 'YTick', [], 'Box', 'on', 'Color', [0.98 0.98 0.98]);
    text(0.5, 0.5, 'Load a license plate image', 'Parent', appData.AxPlate, ...
        'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [0.6 0.6 0.6]);

    % ==========================================================
    % TAB 3: HUMAN TRACKING (YOLO)
    % ==========================================================
    tabHuman = uitab(tabGroup, 'Title', 'Human Tracking (YOLO)');
    
    humanImgPanel = uipanel(tabHuman, 'Title', '', ...
        'Units', 'normalized', 'Position', [0.02 0.27 0.96 0.71], ... 
        'BackgroundColor', theme.panel, 'BorderType', 'line');
    
    humanCtrlPanel = uipanel(tabHuman, 'Title', 'Tracking Controls', ...
        'Units', 'normalized', 'Position', [0.02 0.02 0.96 0.23], ... 
        'BackgroundColor', theme.panel, 'FontName', theme.font, 'FontSize', 11);
                                
    uicontrol(humanCtrlPanel, 'Style', 'pushbutton', 'String', '1. LOAD VIDEO', ...
        'Units', 'normalized', 'Position', [0.02 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnLoad, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) loadVideoFile(fig));
                          
    appData.BtnStartTrack = uicontrol(humanCtrlPanel, 'Style', 'pushbutton', 'String', '2. START TRACKING', ...
        'Units', 'normalized', 'Position', [0.24 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnTrack, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) startHumanTracking(fig));
                          
    uicontrol(humanCtrlPanel, 'Style', 'pushbutton', 'String', 'STOP / RESET', ...
        'Units', 'normalized', 'Position', [0.46 0.4 0.20 0.4], ...
        'BackgroundColor', [0.8 0.2 0.2], 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) stopTracking(fig));
    
    appData.ResultLabelHuman = uicontrol(humanCtrlPanel, 'Style', 'text', 'String', 'Status: Ready', ...
        'Units', 'normalized', 'Position', [0.68 0.4 0.30 0.4], ...
        'BackgroundColor', theme.panel, 'FontName', theme.font, ...
        'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'ForegroundColor', [0.3 0.3 0.3]);
    
    appData.AxHuman = axes(humanImgPanel, 'Position', [0.05 0.05 0.9 0.9]);
    set(appData.AxHuman, 'XTick', [], 'YTick', [], 'Box', 'on', 'Color', [0.98 0.98 0.98]);
    text(0.5, 0.5, 'Load video to begin', 'Parent', appData.AxHuman, ...
        'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [0.6 0.6 0.6]);

    % ==========================================================
    % TAB 4: DEEP LEARNING (Fruit & Plate)
    % ==========================================================
    tabDL = uitab(tabGroup, 'Title', 'Deep Learning');
    
    % Nested Tab Group for DL
    tabGroupDL = uitabgroup(tabDL, 'Position', [0 0 1 1]);
    
    % --- DL Fruit Tab ---
    tabDLFruit = uitab(tabGroupDL, 'Title', 'DL Fruit');
    
    dlFruitImgPanel = uipanel(tabDLFruit, 'Title', '', ...
        'Units', 'normalized', 'Position', [0.02 0.27 0.96 0.71], ... 
        'BackgroundColor', theme.panel, 'BorderType', 'line');
        
    dlFruitCtrlPanel = uipanel(tabDLFruit, 'Title', 'DL Fruit Controls', ...
        'Units', 'normalized', 'Position', [0.02 0.02 0.96 0.23], ... 
        'BackgroundColor', theme.panel, 'FontName', theme.font, 'FontSize', 11);
        
    uicontrol(dlFruitCtrlPanel, 'Style', 'pushbutton', 'String', 'LOAD FRUIT', ...
        'Units', 'normalized', 'Position', [0.02 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnLoad, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) loadFruitImageDL(fig));
        
    uicontrol(dlFruitCtrlPanel, 'Style', 'pushbutton', 'String', 'IDENTIFY (CNN)', ...
        'Units', 'normalized', 'Position', [0.24 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnRun, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) identifyFruitDL(fig));
        
    appData.ResultLabelDLFruit = uicontrol(dlFruitCtrlPanel, 'Style', 'text', 'String', 'Waiting...', ...
        'Units', 'normalized', 'Position', [0.68 0.15 0.30 0.5], ...
        'BackgroundColor', theme.panel, 'FontName', theme.font, ...
        'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'ForegroundColor', [0.7 0.7 0.7]);
        
    appData.AxDLFruit = axes(dlFruitImgPanel, 'Position', [0.05 0.05 0.9 0.9]);
    set(appData.AxDLFruit, 'XTick', [], 'YTick', [], 'Box', 'on', 'Color', [0.98 0.98 0.98]);
    text(0.5, 0.5, 'Load Fruit for DL', 'Parent', appData.AxDLFruit, ...
        'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [0.6 0.6 0.6]);
        
    % --- DL Plate Tab ---
    tabDLPlate = uitab(tabGroupDL, 'Title', 'DL Plate');
    
    dlPlateImgPanel = uipanel(tabDLPlate, 'Title', '', ...
        'Units', 'normalized', 'Position', [0.02 0.27 0.96 0.71], ... 
        'BackgroundColor', theme.panel, 'BorderType', 'line');
        
    dlPlateCtrlPanel = uipanel(tabDLPlate, 'Title', 'DL Plate Controls', ...
        'Units', 'normalized', 'Position', [0.02 0.02 0.96 0.23], ... 
        'BackgroundColor', theme.panel, 'FontName', theme.font, 'FontSize', 11);
        
    uicontrol(dlPlateCtrlPanel, 'Style', 'pushbutton', 'String', 'LOAD PLATE', ...
        'Units', 'normalized', 'Position', [0.02 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnLoad, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) loadPlateImageDL(fig));
        
    uicontrol(dlPlateCtrlPanel, 'Style', 'pushbutton', 'String', 'RECOGNIZE (CNN)', ...
        'Units', 'normalized', 'Position', [0.24 0.4 0.20 0.4], ...
        'BackgroundColor', theme.btnExtra, 'ForegroundColor', 'white', ...
        'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
        'Callback', @(src, event) recognizePlateDL(fig));
        
    appData.ResultLabelDLPlate = uicontrol(dlPlateCtrlPanel, 'Style', 'text', 'String', 'Waiting...', ...
        'Units', 'normalized', 'Position', [0.68 0.15 0.30 0.5], ...
        'BackgroundColor', theme.panel, 'FontName', theme.font, ...
        'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'ForegroundColor', [0.7 0.7 0.7]);
        
    appData.AxDLPlate = axes(dlPlateImgPanel, 'Position', [0.05 0.05 0.9 0.9]);
    set(appData.AxDLPlate, 'XTick', [], 'YTick', [], 'Box', 'on', 'Color', [0.98 0.98 0.98]);
    text(0.5, 0.5, 'Load Plate for DL', 'Parent', appData.AxDLPlate, ...
        'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [0.6 0.6 0.6]);

    % Initialize DL Models in AppData
    appData.DLFruitModel = [];
    appData.DLPlateModel = [];
    appData.CurrentDLFruitImg = [];
    appData.CurrentDLPlateImg = [];

    % Update UserData and Initialize
    set(fig, 'UserData', appData);
    loadModel(fig);
    loadDLModels(fig);

end

% ==========================================================
% LOGIC: FRUIT RECOGNITION
% ==========================================================
function loadModel(fig)
    appData = get(fig, 'UserData');
    try
        data = load('TrainedFruitModel.mat');
        if isfield(data, 'svmModel')
            appData.TrainedModel = data.svmModel;
        else
            vars = fieldnames(data);
            appData.TrainedModel = data.(vars{1});
        end
        disp('Fruit Model Loaded Successfully.');
    catch
        % Silent fail
    end
    set(fig, 'UserData', appData);
end

function loadFruitImage(fig)
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg'}, 'Select Fruit');
    if filename == 0; return; end
    fullPath = fullfile(pathname, filename);
    img = imread(fullPath);
    appData = get(fig, 'UserData');
    appData.CurrentFruitImg = img;
    cla(appData.AxFruit); imshow(img, 'Parent', appData.AxFruit);
    set(appData.ResultLabelFruit, 'String', 'Ready to Scan', 'ForegroundColor', [0.2 0.2 0.2]);
    set(fig, 'UserData', appData);
end

function identifyFruit(fig)
    appData = get(fig, 'UserData');
    if isempty(appData.CurrentFruitImg), msgbox('Load fruit first.', 'Warning', 'warn'); return; end
    if isempty(appData.TrainedModel), msgbox('Model not loaded.', 'Error', 'error'); return; end
    try
        % External Call
        features = extractFruitFeatures(appData.CurrentFruitImg);
        prediction = predict(appData.TrainedModel, features);
        finalText = char(prediction);
        set(appData.ResultLabelFruit, 'String', upper(finalText));
        
        col = [0.2 0.2 0.2];
        switch lower(finalText)
            case 'apple', col = [0.8 0 0];
            case 'banana', col = [0.9 0.8 0];
            case 'orange', col = [1 0.5 0];
            case 'lemon', col = [0.8 0.8 0.2];
            case 'pear', col = [0.5 0.7 0.2];
        end
        set(appData.ResultLabelFruit, 'ForegroundColor', col);
    catch ME
        errordlg(ME.message, 'Error');
    end
end

% ==========================================================
% LOGIC: PLATE RECOGNITION
% ==========================================================
function loadPlateImage(fig)
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg'}, 'Select Plate');
    if filename == 0; return; end
    fullPath = fullfile(pathname, filename);
    img = imread(fullPath);
    appData = get(fig, 'UserData');
    appData.CurrentPlateImg = img;
    cla(appData.AxPlate); imshow(img, 'Parent', appData.AxPlate);
    set(appData.ResultLabelPlate, 'String', 'Ready to Read', 'ForegroundColor', [0.2 0.2 0.2]);
    set(fig, 'UserData', appData);
end

function recognizePlate(fig)
    appData = get(fig, 'UserData');
    if isempty(appData.CurrentPlateImg), msgbox('Load plate first.', 'Warning', 'warn'); return; end
    try
        % External Call to processPlate.m
        [plateText, processedImg] = processPlate(appData.CurrentPlateImg);
        
        if ~isempty(processedImg), imshow(processedImg, 'Parent', appData.AxPlate); end
        set(appData.ResultLabelPlate, 'String', upper(plateText), 'ForegroundColor', [0 0 0.8]);
    catch ME
        errordlg(ME.message, 'Error');
    end
end

% ==========================================================
% LOGIC: HUMAN TRACKING (YOLO)
% ==========================================================

function loadVideoFile(fig)
    [filename, pathname] = uigetfile({'*.mp4;*.avi;*.mov', 'Video Files'}, 'Select Video');
    if filename == 0; return; end
    
    appData = get(fig, 'UserData');
    appData.CurrentVideoPath = fullfile(pathname, filename);
    set(appData.ResultLabelHuman, 'String', 'Video Loaded.');
    
    v = VideoReader(appData.CurrentVideoPath);
    if hasFrame(v)
        frame = readFrame(v);
        imshow(frame, 'Parent', appData.AxHuman);
    end
    set(fig, 'UserData', appData);
end

function stopTracking(fig)
    appData = get(fig, 'UserData');
    appData.IsTracking = false; 
    set(appData.ResultLabelHuman, 'String', 'Stopping...');
    set(fig, 'UserData', appData);
end

function startHumanTracking(fig)
    appData = get(fig, 'UserData');
    
    if isempty(appData.CurrentVideoPath)
        msgbox('Please load video first.', 'Warning', 'warn');
        return;
    end
    
    appData.IsTracking = true;
    set(fig, 'UserData', appData);
    set(appData.ResultLabelHuman, 'String', 'Initializing Detector...');
    drawnow;
    
    % --- 1. SETUP DETECTOR (External Call) ---
    [detector, detectorType] = setupHumanDetector();
    
    set(appData.ResultLabelHuman, 'String', ['Detector: ' detectorType]);
    
    % --- 2. TRACKING LOOP ---
    video = VideoReader(appData.CurrentVideoPath);
    
    % Initialize Tracks (Struct Array)
    tracks = struct('id', {}, 'bbox', {}, 'age', {}, 'totalVisibleCount', {}, 'consecutiveInvisibleCount', {});
    nextId = 1;
    
    while hasFrame(video)
        appData = get(fig, 'UserData');
        if ~appData.IsTracking
            break;
        end
        
        frame = readFrame(video);
        
        % --- 3. PROCESS FRAME (External Call) ---
        [displayFrame, tracks, nextId] = processHumanFrame(frame, detector, detectorType, tracks, nextId);
        
        imshow(displayFrame, 'Parent', appData.AxHuman);
        drawnow;
    end
    
    set(appData.ResultLabelHuman, 'String', 'Finished.');
end

% ==========================================================
% LOGIC: DEEP LEARNING
% ==========================================================
function loadDLModels(fig)
    appData = get(fig, 'UserData');
    
    % Load Fruit DL Model
    try
        data = load('TrainedFruitModelDL.mat');
        if isfield(data, 'fruitNet')
            appData.DLFruitModel = data.fruitNet;
        end
    catch
        % disp('DL Fruit Model not found.');
    end
    
    % Load Plate DL Model
    try
        data = load('TrainedPlateModelDL.mat');
        if isfield(data, 'charNet')
            appData.DLPlateModel = data.charNet;
        end
    catch
        % disp('DL Plate Model not found.');
    end
    
    set(fig, 'UserData', appData);
end

function loadFruitImageDL(fig)
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg'}, 'Select Fruit');
    if filename == 0; return; end
    fullPath = fullfile(pathname, filename);
    img = imread(fullPath);
    appData = get(fig, 'UserData');
    appData.CurrentDLFruitImg = img;
    cla(appData.AxDLFruit); imshow(img, 'Parent', appData.AxDLFruit);
    set(appData.ResultLabelDLFruit, 'String', 'Ready', 'ForegroundColor', [0.2 0.2 0.2]);
    set(fig, 'UserData', appData);
end

function identifyFruitDL(fig)
    appData = get(fig, 'UserData');
    if isempty(appData.CurrentDLFruitImg), msgbox('Load fruit first.', 'Warning', 'warn'); return; end
    
    % Try to load model if not loaded
    if isempty(appData.DLFruitModel)
        loadDLModels(fig);
        appData = get(fig, 'UserData');
        if isempty(appData.DLFruitModel)
            msgbox('DL Fruit Model (TrainedFruitModelDL.mat) not found. Please run trainFruitDL.m first.', 'Error', 'error'); 
            return; 
        end
    end
    
    try
        [label, score] = processFruitDL(appData.CurrentDLFruitImg, appData.DLFruitModel);
        set(appData.ResultLabelDLFruit, 'String', [upper(label) ' (' num2str(score*100, '%.1f') '%)']);
        set(appData.ResultLabelDLFruit, 'ForegroundColor', [0 0.5 0]);
    catch ME
        errordlg(ME.message, 'Error');
    end
end

function loadPlateImageDL(fig)
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg'}, 'Select Plate');
    if filename == 0; return; end
    fullPath = fullfile(pathname, filename);
    img = imread(fullPath);
    appData = get(fig, 'UserData');
    appData.CurrentDLPlateImg = img;
    cla(appData.AxDLPlate); imshow(img, 'Parent', appData.AxDLPlate);
    set(appData.ResultLabelDLPlate, 'String', 'Ready', 'ForegroundColor', [0.2 0.2 0.2]);
    set(fig, 'UserData', appData);
end

function recognizePlateDL(fig)
    appData = get(fig, 'UserData');
    if isempty(appData.CurrentDLPlateImg), msgbox('Load plate first.', 'Warning', 'warn'); return; end
    
    % Try to load model if not loaded
    if isempty(appData.DLPlateModel)
        loadDLModels(fig);
        appData = get(fig, 'UserData');
        if isempty(appData.DLPlateModel)
            msgbox('DL Plate Model (TrainedPlateModelDL.mat) not found. Please run trainPlateCharDL.m first.', 'Error', 'error'); 
            return; 
        end
    end
    
    try
        [plateText, processedImg] = processPlateDL(appData.CurrentDLPlateImg, appData.DLPlateModel);
        if ~isempty(processedImg), imshow(processedImg, 'Parent', appData.AxDLPlate); end
        set(appData.ResultLabelDLPlate, 'String', upper(plateText), 'ForegroundColor', [0 0 0.8]);
    catch ME
        errordlg(ME.message, 'Error');
    end
end