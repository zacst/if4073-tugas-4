function GUI
    % GUI Programmatic GUI for Classification
    % This script creates a modern UI using MATLAB's uifigure framework.
    
    % 1. MAIN VARIABLES (State Management)
    trainedModel = []; 
    currentFruitImg = [];
    currentPlateImg = [];
    
    % 2. CREATE THE MAIN WINDOW
    screenSize = get(0, 'ScreenSize');
    figWidth = 600;
    figHeight = 700;
    posX = (screenSize(3) - figWidth) / 2;
    posY = (screenSize(4) - figHeight) / 2;

    fig = uifigure('Name', 'Image Processing System', ...
        'Position', [posX, posY, figWidth, figHeight], ...
        'Color', [0.95 0.95 0.95]);

    % Create Tab Group
    tabGroup = uitabgroup(fig, 'Position', [0, 0, figWidth, figHeight]);
    
    % --- TAB 1: FRUIT RECOGNITION ---
    tabFruit = uitab(tabGroup, 'Title', 'Fruit Recognition');
    
    % Title Label (Fruit)
    uilabel(tabFruit, ...
        'Position', [50, 600, 500, 30], ...
        'Text', 'Sistem Pengenalan Buah', ...
        'FontSize', 20, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    % Axes (Fruit)
    axFruit = uiaxes(tabFruit, ...
        'Position', [100, 250, 400, 320], ...
        'XTick', [], 'YTick', [], 'Box', 'on');
    title(axFruit, 'No Image Loaded');

    % "Load Image" Button (Fruit)
    uibutton(tabFruit, ...
        'Text', '1. Load Image', ...
        'Position', [100, 170, 180, 40], ...
        'BackgroundColor', [0.2 0.6 0.8], ...
        'FontColor', 'white', ...
        'ButtonPushedFcn', @loadFruitButtonPushed);

    % "Identify" Button (Fruit)
    uibutton(tabFruit, ...
        'Text', '2. Identify Fruit', ...
        'Position', [320, 170, 180, 40], ...
        'BackgroundColor', [0.2 0.7 0.3], ...
        'FontColor', 'white', ...
        'FontSize', 14, ...
        'ButtonPushedFcn', @identifyFruitButtonPushed);

    % Result Label (Fruit)
    resultLabelFruit = uilabel(tabFruit, ...
        'Position', [50, 90, 500, 50], ...
        'Text', 'Waiting for input...', ...
        'FontSize', 24, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'FontColor', [0.5 0.5 0.5]);

    % --- TAB 2: PLATE RECOGNITION ---
    tabPlate = uitab(tabGroup, 'Title', 'Plate Recognition');
    
    % Title Label (Plate)
    uilabel(tabPlate, ...
        'Position', [50, 600, 500, 30], ...
        'Text', 'Automatic Plate Number Recognition', ...
        'FontSize', 20, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    % Axes (Plate)
    axPlate = uiaxes(tabPlate, ...
        'Position', [100, 250, 400, 320], ...
        'XTick', [], 'YTick', [], 'Box', 'on');
    title(axPlate, 'No Image Loaded');

    % "Load Image" Button (Plate)
    uibutton(tabPlate, ...
        'Text', '1. Load Plate Image', ...
        'Position', [100, 170, 180, 40], ...
        'BackgroundColor', [0.2 0.6 0.8], ...
        'FontColor', 'white', ...
        'ButtonPushedFcn', @loadPlateButtonPushed);

    % "Recognize" Button (Plate)
    uibutton(tabPlate, ...
        'Text', '2. Recognize Plate', ...
        'Position', [320, 170, 180, 40], ...
        'BackgroundColor', [0.8 0.4 0.2], ...
        'FontColor', 'white', ...
        'FontSize', 14, ...
        'ButtonPushedFcn', @recognizePlateButtonPushed);

    % Result Label (Plate)
    resultLabelPlate = uilabel(tabPlate, ...
        'Position', [50, 90, 500, 50], ...
        'Text', 'Waiting for input...', ...
        'FontSize', 24, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'FontColor', [0.5 0.5 0.5]);

    % 3. INITIALIZE SYSTEM
    loadModel();

    % ---------------------------------------------------------
    % 4. CALLBACK FUNCTIONS
    % ---------------------------------------------------------

    % --- FRUIT FUNCTIONS ---
    function loadModel()
        try
            data = load('TrainedFruitModel.mat');
            if isfield(data, 'svmModel')
                trainedModel = data.svmModel;
            else
                vars = fieldnames(data);
                trainedModel = data.(vars{1});
            end
        catch
            % Don't show alert immediately, maybe just log or ignore until needed
        end
    end

    function loadFruitButtonPushed(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg;*.avif', 'Image Files'});
        if isequal(file, 0), return; end
        
        fullPath = fullfile(path, file);
        currentFruitImg = imread(fullPath);
        imshow(currentFruitImg, 'Parent', axFruit);
        title(axFruit, 'Image Loaded');
        resultLabelFruit.Text = 'Ready to Identify';
        resultLabelFruit.FontColor = 'black';
    end

    function identifyFruitButtonPushed(~, ~)
        if isempty(currentFruitImg)
            uialert(fig, 'Please load an image first.', 'Warning');
            return;
        end
        if isempty(trainedModel)
            uialert(fig, 'Model not loaded. Cannot predict.', 'Error');
            return;
        end
        
        try
            features = extractFruitFeatures(currentFruitImg);
        catch ME
            uialert(fig, ['Error in feature extraction: ' ME.message], 'Code Error');
            return;
        end
        
        prediction = predict(trainedModel, features);
        finalText = char(prediction);
        resultLabelFruit.Text = ['Detected: ' finalText];
        
        switch lower(finalText)
            case 'apple', resultLabelFruit.FontColor = [0.8 0 0];
            case 'orange', resultLabelFruit.FontColor = [1 0.5 0];
            case 'pear', resultLabelFruit.FontColor = [0.6 0.8 0.2];
            otherwise, resultLabelFruit.FontColor = [0 0 0];
        end
        title(axFruit, ['Result: ' finalText]);
    end

    % --- PLATE FUNCTIONS ---
    function loadPlateButtonPushed(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg;*.avif', 'Image Files'});
        if isequal(file, 0), return; end
        
        fullPath = fullfile(path, file);
        currentPlateImg = imread(fullPath);
        imshow(currentPlateImg, 'Parent', axPlate);
        title(axPlate, 'Image Loaded');
        resultLabelPlate.Text = 'Ready to Recognize';
        resultLabelPlate.FontColor = 'black';
    end

    function recognizePlateButtonPushed(~, ~)
        if isempty(currentPlateImg)
            uialert(fig, 'Please load an image first.', 'Warning');
            return;
        end
        
        try
            % Call the processing function
            [plateText, processedImg] = processPlate(currentPlateImg);
            
            % Display result
            imshow(processedImg, 'Parent', axPlate);
            resultLabelPlate.Text = ['Plate: ' plateText];
            resultLabelPlate.FontColor = [0 0 0.8]; % Blue
            title(axPlate, ['Result: ' plateText]);
            
        catch ME
            uialert(fig, ['Error in processing: ' ME.message], 'Error');
        end
    end

end
