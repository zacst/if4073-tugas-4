function GUI
    % GUI Programmatic GUI for Classification
    % This script creates a modern UI using MATLAB's uifigure framework.
    
    % 1. MAIN VARIABLES (State Management)
    % These variables are shared between the nested functions below
    trainedModel = []; 
    currentImg = [];
    
    % 2. CREATE THE MAIN WINDOW
    % Get screen size to center the window
    screenSize = get(0, 'ScreenSize');
    figWidth = 500;
    figHeight = 600;
    posX = (screenSize(3) - figWidth) / 2;
    posY = (screenSize(4) - figHeight) / 2;

    fig = uifigure('Name', 'Fruit Recognition System', ...
        'Position', [posX, posY, figWidth, figHeight], ...
        'Color', [0.95 0.95 0.95]); % Light gray background

    % 3. INITIALIZE SYSTEM
    loadModel();

    % 4. UI COMPONENTS LAYOUT
    
    % Title Label
    uilabel(fig, ...
        'Position', [50, 550, 400, 30], ...
        'Text', 'Sistem Pengenalan Buah', ...
        'FontSize', 20, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');

    % Axes (The Image Display)
    % We use 'uiaxes' for modern apps. We hide the X/Y tick marks.
    ax = uiaxes(fig, ...
        'Position', [50, 200, 400, 320], ...
        'XTick', [], 'YTick', [], 'Box', 'on');
    title(ax, 'No Image Loaded');

    % "Load Image" Button
    uibutton(fig, ...
        'Text', '1. Load Image', ...
        'Position', [50, 120, 180, 40], ...
        'BackgroundColor', [0.2 0.6 0.8], ... % Blueish
        'FontColor', 'white', ...
        'ButtonPushedFcn', @loadButtonPushed);

    % "Identify" Button
    uibutton(fig, ...
        'Text', '2. Identify Fruit', ...
        'Position', [270, 120, 180, 40], ...
        'BackgroundColor', [0.2 0.7 0.3], ... % Greenish
        'FontColor', 'white', ...
        'FontSize', 14, ...
        'ButtonPushedFcn', @identifyButtonPushed);

    % Result Label (Large Text)
    resultLabel = uilabel(fig, ...
        'Position', [50, 40, 400, 50], ...
        'Text', 'Waiting for input...', ...
        'FontSize', 24, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'FontColor', [0.5 0.5 0.5]); % Gray initially

    % ---------------------------------------------------------
    % 5. CALLBACK FUNCTIONS (The Logic)
    % ---------------------------------------------------------

    % Function to Load Model on Startup
    function loadModel()
        try
            data = load('TrainedFruitModel.mat');
            % Handle cases where the variable name might differ
            if isfield(data, 'svmModel')
                trainedModel = data.svmModel;
            else
                % Just take the first variable found if name is wrong
                vars = fieldnames(data);
                trainedModel = data.(vars{1});
            end
        catch
            uialert(fig, 'TrainedFruitModel.mat not found! Please run training first.', 'Error');
        end
    end

    % Callback: User clicks "Load Image"
    function loadButtonPushed(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg', 'Image Files'});
        if isequal(file, 0)
            return; % Cancelled
        end
        
        fullPath = fullfile(path, file);
        currentImg = imread(fullPath);
        
        % Display image
        imshow(currentImg, 'Parent', ax);
        title(ax, 'Image Loaded');
        
        % Reset Result Label
        resultLabel.Text = 'Ready to Identify';
        resultLabel.FontColor = 'black';
    end

    % Callback: User clicks "Identify Fruit"
    function identifyButtonPushed(~, ~)
        % Validation
        if isempty(currentImg)
            uialert(fig, 'Please load an image first.', 'Warning');
            return;
        end
        
        if isempty(trainedModel)
            uialert(fig, 'Model not loaded. Cannot predict.', 'Error');
            return;
        end
        
        % --- PROCESSING ---
        % 1. Extract Features (Calls your separate .m file)
        try
            features = extractFruitFeatures(currentImg);
        catch ME
            uialert(fig, ['Error in feature extraction: ' ME.message], 'Code Error');
            return;
        end
        
        % 2. Predict
        prediction = predict(trainedModel, features);
        
        % 3. Display Result
        finalText = char(prediction); % Convert categorical/cell to string
        resultLabel.Text = ['Detected: ' finalText];
        
        % Dynamic Text Color
        switch lower(finalText)
            case 'apple'
                resultLabel.FontColor = [0.8 0 0]; % Red
            case 'orange'
                resultLabel.FontColor = [1 0.5 0]; % Orange
            case 'pear'
                resultLabel.FontColor = [0.6 0.8 0.2]; % Pear Green
            otherwise
                resultLabel.FontColor = [0 0 0]; % Black
        end
        
        title(ax, ['Result: ' finalText]);
    end

end