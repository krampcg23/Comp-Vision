data = load('localization_labelled.mat');
cellArray = table2cell(data.gTruth.LabelData);
T = table(data.gTruth.DataSource.Source, cellArray);

inputLayer = imageInputLayer([32 32]);
filterSize = [3 3];
numFilters = 10;

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
fullyConnectedLayer(2)
softmaxLayer()
classificationLayer()
];

layers = [
inputLayer
middleLayers
finalLayers
];

batch = 1;
options = trainingOptions( 'sgdm',...
'MiniBatchSize', batch,...
'VerboseFrequency', 10, ...
'MaxEpochs',25);
rng(0);
detector = trainFasterRCNNObjectDetector(T, layers, options);
