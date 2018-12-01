clear all

data = load('localization_labelled.mat');
cellArray = table2cell(data.gTruth.LabelData);
dataset = table(data.gTruth.DataSource.Source, cellArray);
dataset.Properties.VariableNames = {'imageFilename' 'boxes'};


inputLayer = imageInputLayer([32 32 3]);

middleLayers = [         
    convolution2dLayer([3 3], 20, 'Padding', 1)   
    reluLayer()
    convolution2dLayer([3 3], 20, 'Padding', 1)  
    reluLayer() 
    maxPooling2dLayer(3, 'Stride',2)  
    ];
finalLayers = [
    fullyConnectedLayer(64)
    reluLayer()
    fullyConnectedLayer(width(dataset))
    softmaxLayer()
    classificationLayer()
];
layers = [
    inputLayer
    middleLayers
    finalLayers
    ];

optionsStage1 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

optionsStage2 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

optionsStage3 = trainingOptions('sgdm', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'CheckpointPath', tempdir);

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

rng(0);
    
detector = trainFasterRCNNObjectDetector(dataset, layers, options);

I = imread('images/Localization/small/5.png');
[bboxes,scores] = detect(detector,I);

I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(I)