function GUI()
% FRUITRECOGNITIONGUI - Merged & Modernized GUI
% Combines User's Modern Styling with Coworker's Tabbed Plate Recognition.

    % --- 1. GUI Setup ---
    
    % Ensure existing figures are cleared
    close all force;
    
    % Theme Colors (From User's Branch)
    theme.bg        = [0.94 0.94 0.96]; % Light Gray Background
    theme.panel     = [1.00 1.00 1.00]; % White Panels
    theme.text      = [0.20 0.20 0.20]; % Dark Gray Text
    theme.btnLoad   = [0.00 0.45 0.74]; % MATLAB Blue
    theme.btnRun    = [0.24 0.70 0.44]; % Green
    theme.btnExtra  = [0.80 0.40 0.20]; % Burnt Orange (for Plates)
    theme.font      = 'Segoe UI';       % Modern Font
    
    % Create the main figure window
    fig = figure('Name', 'Unified Recognition System Pro', ...
                 'NumberTitle', 'off', ...
                 'Units', 'normalized', ... 
                 'Position', [0.1 0.1 0.8 0.8], ... % Start large
                 'Color', theme.bg, ...
                 'ToolBar', 'none', ...
                 'MenuBar', 'none');
                 
    % Store application data
    appData = struct();
    appData.TrainedModel = [];
    appData.CurrentFruitImg = [];
    appData.CurrentPlateImg = [];
    appData.Theme = theme; 
    set(fig, 'UserData', appData);
    
    % --- 2. Tab Group Setup ---
    % We use a Tab Group to handle the Coworker's requirement for two modes
    tabGroup = uitabgroup(fig, 'Position', [0 0 1 1]);
    
    % ==========================================================
    % TAB 1: FRUIT RECOGNITION (User's Style)
    % ==========================================================
    tabFruit = uitab(tabGroup, 'Title', 'Fruit Recognition');
    
    % A. Image Panel (Fruit)
    fruitImgPanel = uipanel(tabFruit, 'Title', '', ...
                            'Units', 'normalized', ...
                            'Position', [0.02 0.27 0.96 0.71], ... 
                            'BackgroundColor', theme.panel, ...
                            'BorderType', 'line');
    
    % B. Control Panel (Fruit)
    fruitCtrlPanel = uipanel(tabFruit, 'Title', 'Fruit Controls', ...
                                'Units', 'normalized', ...
                                'Position', [0.02 0.02 0.96 0.23], ... 
                                'BackgroundColor', theme.panel, ...
                                'FontName', theme.font, ...
                                'FontSize', 11);
                                
    % Buttons (Fruit)
    uicontrol(fruitCtrlPanel, 'Style', 'pushbutton', ...
                          'String', '1. LOAD FRUIT', ...
                          'Units', 'normalized', ...
                          'Position', [0.02 0.4 0.20 0.4], ...
                          'BackgroundColor', theme.btnLoad, ...
                          'ForegroundColor', 'white', ...
                          'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
                          'Callback', @(src, event) loadFruitImage(fig));
                          
    uicontrol(fruitCtrlPanel, 'Style', 'pushbutton', ...
                          'String', '2. IDENTIFY FRUIT', ...
                          'Units', 'normalized', ...
                          'Position', [0.24 0.4 0.20 0.4], ...
                          'BackgroundColor', theme.btnRun, ...
                          'ForegroundColor', 'white', ...
                          'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
                          'Callback', @(src, event) identifyFruit(fig));
                          
    % Result Label (Fruit)
    uicontrol(fruitCtrlPanel, 'Style', 'text', ...
                          'String', 'RESULT:', ...
                          'Units', 'normalized', ...
                          'Position', [0.68 0.65 0.30 0.2], ...
                          'BackgroundColor', theme.panel, ...
                          'FontName', theme.font, 'FontSize', 10, ...
                          'HorizontalAlignment', 'center', 'ForegroundColor', [0.5 0.5 0.5]);

    appData.ResultLabelFruit = uicontrol(fruitCtrlPanel, 'Style', 'text', ...
                          'String', 'Waiting for input...', ...
                          'Units', 'normalized', ...
                          'Position', [0.68 0.15 0.30 0.5], ...
                          'BackgroundColor', theme.panel, ...
                          'FontName', theme.font, 'FontSize', 22, ...
                          'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                          'ForegroundColor', [0.7 0.7 0.7]);
                          
    % Axes (Fruit)
    appData.AxFruit = axes(fruitImgPanel, 'Position', [0.05 0.05 0.9 0.9]);
    set(appData.AxFruit, 'XTick', [], 'YTick', [], 'Box', 'on', 'Color', [0.98 0.98 0.98]);
    text(0.5, 0.5, 'Load a fruit image', 'Parent', appData.AxFruit, ...
        'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [0.6 0.6 0.6]);

    % ==========================================================
    % TAB 2: PLATE RECOGNITION (Coworker's Feature, User's Style)
    % ==========================================================
    tabPlate = uitab(tabGroup, 'Title', 'Plate Recognition');
    
    % A. Image Panel (Plate)
    plateImgPanel = uipanel(tabPlate, 'Title', '', ...
                            'Units', 'normalized', ...
                            'Position', [0.02 0.27 0.96 0.71], ... 
                            'BackgroundColor', theme.panel, ...
                            'BorderType', 'line');
    
    % B. Control Panel (Plate)
    plateCtrlPanel = uipanel(tabPlate, 'Title', 'Plate Controls', ...
                                'Units', 'normalized', ...
                                'Position', [0.02 0.02 0.96 0.23], ... 
                                'BackgroundColor', theme.panel, ...
                                'FontName', theme.font, ...
                                'FontSize', 11);
                                
    % Buttons (Plate)
    uicontrol(plateCtrlPanel, 'Style', 'pushbutton', ...
                          'String', '1. LOAD PLATE', ...
                          'Units', 'normalized', ...
                          'Position', [0.02 0.4 0.20 0.4], ...
                          'BackgroundColor', theme.btnLoad, ...
                          'ForegroundColor', 'white', ...
                          'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
                          'Callback', @(src, event) loadPlateImage(fig));
                          
    uicontrol(plateCtrlPanel, 'Style', 'pushbutton', ...
                          'String', '2. RECOGNIZE PLATE', ...
                          'Units', 'normalized', ...
                          'Position', [0.24 0.4 0.20 0.4], ...
                          'BackgroundColor', theme.btnExtra, ... % Different color for plate
                          'ForegroundColor', 'white', ...
                          'FontName', theme.font, 'FontSize', 11, 'FontWeight', 'bold', ...
                          'Callback', @(src, event) recognizePlate(fig));
                          
    % Result Label (Plate)
    uicontrol(plateCtrlPanel, 'Style', 'text', ...
                          'String', 'DETECTED NUMBER:', ...
                          'Units', 'normalized', ...
                          'Position', [0.68 0.65 0.30 0.2], ...
                          'BackgroundColor', theme.panel, ...
                          'FontName', theme.font, 'FontSize', 10, ...
                          'HorizontalAlignment', 'center', 'ForegroundColor', [0.5 0.5 0.5]);

    appData.ResultLabelPlate = uicontrol(plateCtrlPanel, 'Style', 'text', ...
                          'String', 'Waiting for input...', ...
                          'Units', 'normalized', ...
                          'Position', [0.68 0.15 0.30 0.5], ...
                          'BackgroundColor', theme.panel, ...
                          'FontName', theme.font, 'FontSize', 22, ...
                          'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                          'ForegroundColor', [0.7 0.7 0.7]);
    
    % Axes (Plate)
    appData.AxPlate = axes(plateImgPanel, 'Position', [0.05 0.05 0.9 0.9]);
    set(appData.AxPlate, 'XTick', [], 'YTick', [], 'Box', 'on', 'Color', [0.98 0.98 0.98]);
    text(0.5, 0.5, 'Load a license plate image', 'Parent', appData.AxPlate, ...
        'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [0.6 0.6 0.6]);

    % Update UserData
    set(fig, 'UserData', appData);
    
    % --- 5. Initialization ---
    loadModel(fig);

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
        msgbox('TrainedFruitModel.mat not found! Please run main.m first.', 'System Warning', 'warn');
    end
    set(fig, 'UserData', appData);
end

function loadFruitImage(fig)
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg', 'Image Files'}, 'Select Fruit');
    if filename == 0; return; end
    
    fullPath = fullfile(pathname, filename);
    img = imread(fullPath);
    
    appData = get(fig, 'UserData');
    appData.CurrentFruitImg = img;
    
    % Display
    cla(appData.AxFruit);
    imshow(img, 'Parent', appData.AxFruit);
    
    % Reset Label
    set(appData.ResultLabelFruit, 'String', 'Ready to Scan', 'ForegroundColor', [0.2 0.2 0.2]);
    set(fig, 'UserData', appData);
end

function identifyFruit(fig)
    appData = get(fig, 'UserData');
    
    if isempty(appData.CurrentFruitImg)
        msgbox('Please load a fruit image first.', 'Warning', 'warn');
        return;
    end
    if isempty(appData.TrainedModel)
        msgbox('Fruit Model not loaded.', 'Error', 'error');
        return;
    end
    
    try
        % Extract Features (Calls extractFruitFeatures.m)
        features = extractFruitFeatures(appData.CurrentFruitImg);
        
        % Predict
        prediction = predict(appData.TrainedModel, features);
        finalText = char(prediction);
        
        % Update UI
        set(appData.ResultLabelFruit, 'String', upper(finalText));
        
        % Dynamic Colors
        col = [0.2 0.2 0.2];
        switch lower(finalText)
            case 'apple', col = [0.8 0 0];
            case 'banana', col = [0.9 0.8 0];
            case 'orange', col = [1 0.5 0];
            case 'grape', col = [0.5 0 0.5];
            case 'lemon', col = [0.8 0.8 0.2];
            case 'pear', col = [0.5 0.7 0.2];
            case 'strawberry', col = [1 0.2 0.2];
            case 'pineapple', col = [0.6 0.4 0.2];
        end
        set(appData.ResultLabelFruit, 'ForegroundColor', col);
        
    catch ME
        errordlg(['Prediction Error: ' ME.message], 'Error');
    end
end

% ==========================================================
% LOGIC: PLATE RECOGNITION
% ==========================================================

function loadPlateImage(fig)
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg', 'Image Files'}, 'Select Plate');
    if filename == 0; return; end
    
    fullPath = fullfile(pathname, filename);
    img = imread(fullPath);
    
    appData = get(fig, 'UserData');
    appData.CurrentPlateImg = img;
    
    % Display
    cla(appData.AxPlate);
    imshow(img, 'Parent', appData.AxPlate);
    
    % Reset Label
    set(appData.ResultLabelPlate, 'String', 'Ready to Read', 'ForegroundColor', [0.2 0.2 0.2]);
    set(fig, 'UserData', appData);
end

function recognizePlate(fig)
    appData = get(fig, 'UserData');
    
    if isempty(appData.CurrentPlateImg)
        msgbox('Please load a plate image first.', 'Warning', 'warn');
        return;
    end
    
    try
        % CALL EXTERNAL PROCESS (Stubbed below since file is missing)
        [plateText, processedImg] = processPlateStub(appData.CurrentPlateImg);
        
        % Show Processed Image (Optional, if returned)
        if ~isempty(processedImg)
            imshow(processedImg, 'Parent', appData.AxPlate);
        end
        
        % Update UI
        set(appData.ResultLabelPlate, 'String', upper(plateText), 'ForegroundColor', [0 0 0.8]);
        
    catch ME
        errordlg(['Plate Error: ' ME.message], 'Error');
    end
end

function [text, procImg] = processPlateStub(img)
% Placeholder logic for your coworker's processPlate function
% You should replace this function with the actual file later.
    
    % Simulation: Convert to grayscale and pretend we found a number
    procImg = rgb2gray(img); 
    
    % Simulate a delay
    pause(0.5);
    
    % Return a dummy plate number
    text = 'B 1234 XYZ'; 
end