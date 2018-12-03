%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clayton Kramp and Katrina Steinman
% CSCI 507 Final Project
% Faster R-CNN to find ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

% Includes the localized information
data = load('localization_labelled.mat');
cellArray = table2cell(data.gTruth.LabelData);
dataset = table(data.gTruth.DataSource.Source, cellArray);
dataset.Properties.VariableNames = {'imageFilename' 'boxes'};

% Define our layers
layers = [
    imageInputLayer([32 32 3]);       
    convolution2dLayer([3 3], 20, 'Padding', 1)   
    reluLayer()
    convolution2dLayer([3 3], 20, 'Padding', 1)  
    reluLayer() 
    maxPooling2dLayer(3, 'Stride',2)  
    fullyConnectedLayer(64)
    reluLayer()
    fullyConnectedLayer(width(dataset))
    softmaxLayer()
    classificationLayer()
];

% Define our training options
option = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

options = [
    option
    option
    option
    option
    ];

rng(0);

% Train and run!
detector = trainFasterRCNNObjectDetector(dataset, layers, options);

%% Test on an image
I = imread('images/Tests/Test1.png');
[bboxes,scores] = detect(detector,I);

I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(I)