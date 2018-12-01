clear all
% Load vehicle data set
% data = load('fasterRCNNVehicleTrainingData.mat');
% vehicleDataset = data.vehicleTrainingData;
% % Display first few rows of the data set.
% vehicleDataset(1:4,:)% Add fullpath to the local vehicle data folder.
% dataDir = fullfile(toolboxdir('vision'),'visiondata');
% vehicleDataset.imageFilename = fullfile(dataDir, vehicleDataset.imageFilename);

data = load('localization_labelled.mat');
cellArray = table2cell(data.gTruth.LabelData);
vehicleDataset = table(data.gTruth.DataSource.Source, cellArray);
vehicleDataset.Properties.VariableNames = {'imageFilename' 'vehicle'};


inputLayer = imageInputLayer([32 32]);
% Define the convolutional layer parameters.
filterSize = [3 3];
numFilters = 10;

% Create the middle layers.
middleLayers = [
                
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)   
    reluLayer()
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)  
    reluLayer() 
    maxPooling2dLayer(3, 'Stride',2)    
    
    ];
finalLayers = [
    fullyConnectedLayer(64)
    reluLayer()
    fullyConnectedLayer(width(vehicleDataset))
    softmaxLayer()
    classificationLayer()
];
layers = [
    inputLayer
    middleLayers
    finalLayers
    ];
% Options for step 1.
optionsStage1 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

% Options for step 2.
optionsStage2 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

% Options for step 3.
optionsStage3 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

% Options for step 4.
optionsStage4 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

options = [
    optionsStage1
    optionsStage2
    optionsStage3
    optionsStage4
    ];

% A trained network is loaded from disk to save time when running the
% example. Set this flag to true to train the network. 
doTrainingAndEval = true;

if doTrainingAndEval
    % Set random seed to ensure example training reproducibility.
    rng(0);
    
    % Train Faster R-CNN detector. Select a BoxPyramidScale of 1.2 to allow
    % for finer resolution for multiscale object detection.
    detector = trainFasterRCNNObjectDetector(vehicleDataset, layers, options, ...
        'NegativeOverlapRange', [0 0.3], ...
        'PositiveOverlapRange', [0.6 1], ...
        'NumRegionsToSample', [256 128 256 128], ...
        'BoxPyramidScale', 1.2);
else
    % Load pretrained detector for the example.
    detector = data.detector;
end
I = imread('images/Localization/small/5.png');
% Run the detector.
[bboxes,scores] = detect(detector,I);

% Annotate detections in the image.
I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(I)