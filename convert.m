%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clayton Kramp and Katrina Steinman
% CSCI 507 Final Project
% Convert file - takes in input image and converts it to our expected
% output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

% Start with loading an image
directory = 'images/Tests/crop-3.png';
% Bounding box stuff
I=(imread(directory));
imshow(I)
I =~imbinarize(I,0.5);
I = bwareaopen(I,5);
numSymbols = 1;
symbolsExtracted = {};

[Labels, numConnectedComponents]=bwlabel(I);
props = regionprops(Labels,'BoundingBox');

minSize = inf; minIndex = 1;
hold on
for n=1:size(props,1)
    rectangle('Position',props(n).BoundingBox,'EdgeColor','r','LineWidth',2)
    if props(n).BoundingBox(3) * props(n).BoundingBox(4) < minSize
        minSize = props(n).BoundingBox(3) * props(n).BoundingBox(4);
        minIndex = n;
    end 
end
hold off

pause

% Train our two MNIST and symbol networks
path = 'Data/';

tempTrainImages = loadMNISTImages(strcat(path,'Train/train-images-idx3-ubyte'));
TrainImages = zeros(28, 28, 1, size(tempTrainImages, 2), 'single');
for i = 1:size(tempTrainImages, 2)
    TrainImages(:,:,1,i) = reshape(tempTrainImages(1:784, i), [28 28]);
end
TrainLabels = loadMNISTLabels(strcat(path,'Train/train-labels-idx1-ubyte'));

tempTestImages = loadMNISTImages(strcat(path,'Test/t10k-images-idx3-ubyte'));
TestImages = zeros(28, 28, 1, size(tempTestImages, 2), 'single');
for i = 1:size(tempTestImages, 2)
    TestImages(:,:,1,i) = reshape(tempTestImages(1:784, i), [28 28]);
end
TestLabels = loadMNISTLabels(strcat(path, 'Test/t10k-labels-idx1-ubyte'));

[trainSymbols, testSymbols, trainSymLabels, testSymLabels] = ...
    processSymbols('Data/Symbols/');

symbolLayers = [ imageInputLayer([28 28 1])
            convolution2dLayer(5,20)
            reluLayer
            maxPooling2dLayer(2, 'Stride', 2)
            dropoutLayer
            fullyConnectedLayer(3)
            softmaxLayer
            classificationLayer() ];
        
batch = 15;
trainOptions = trainingOptions( 'sgdm',...
    'MiniBatchSize', batch,...
    'Plots', 'training-progress',...
    'MaxEpochs',25);
nnSymbol = trainNetwork(trainSymbols, trainSymLabels, symbolLayers, trainOptions);
testing = nnSymbol.classify(testSymbols);
testAccuracy = sum(testing == testSymLabels) / numel(testSymLabels);
fprintf("Test Accuracy for Symbols is %f\n", testAccuracy);

layers = [  imageInputLayer([28 28 1])
            convolution2dLayer(5,20)
            reluLayer
            maxPooling2dLayer(2, 'Stride', 2)
            dropoutLayer
            fullyConnectedLayer(10)
            softmaxLayer
            classificationLayer()   ];
        
batch = 50;
trainOptions = trainingOptions( 'sgdm',...
    'MiniBatchSize', batch,...
    'Plots', 'training-progress',...
    'MaxEpochs',1);
nn = trainNetwork(TrainImages, categorical(TrainLabels), layers, trainOptions);
testing = nn.classify(TestImages);
testAccuracy = sum(testing == categorical(TestLabels)) / numel(TestLabels);
fprintf("Test Accuracy is for numerics is %f\n", testAccuracy);

%% Running symbol and MNIST classification
for i=1:numConnectedComponents
    if i == minIndex
        symbolsExtracted(numSymbols) = {'.'};
    else
        [row,col] = find(Labels == i);
        symbol = zeros(28, 28, 1, 1);
        newImg = imgaussfilt(single(I(min(row):max(row),min(col):max(col))),1);
        symbol(:,:,1,1) = padarray(imresize(newImg, [18 18]),[5 5],0,'both');
        if i == 1 || i == 2
            [prediction, score] = nnSymbol.classify(symbol);
            symbolsExtracted(numSymbols) = {char(prediction)};
        else
            [prediction, score] = nn.classify(symbol);
           symbolsExtracted(numSymbols) = {str2num(char(prediction))};
        end
    end
    numSymbols = numSymbols + 1;
end
symbolsExtracted

%% Projection

IProject=(imread(directory));
figure, imshow(IProject);
[row1, col1] = find(Labels == 1);
[row2, col2] = find(Labels == 2);
if min(row1) < min(row2)
    topRow = row1;
    topCol = col1;
    bottomRow = row2;
    bottomCol = col2;
    fromNum = 1;
    toNum = 2;
else 
    topRow = row2;
    topCol = col2;
    bottomRow = row1;
    bottomCol = col1;
    fromNum = 2;
    toNum = 1;
end

x = max(bottomCol);
y = min(bottomRow);

% Gathering info for the text
text_str = '';
for i = 3:size(symbolsExtracted, 2)
    text_str = [text_str num2str(symbolsExtracted{i})];
end

%   D E Y
% D
% E
% Y
conversionMatrix = [1 0.88 113; 1.13 1 128.76; 0.0088 0.0078 1];
from = symbolsExtracted{fromNum};
to = symbolsExtracted{toNum};
if from == 'D'
    from = 1;
elseif from == 'E'
    from = 2;
else
    from = 3;
end

if to == 'D'
    to = 1;
elseif to == 'E'
    to = 2;
else
    to = 3;
end

convertedVal = conversionMatrix(from, to) * str2num(text_str);

remainingSpace = size(IProject, 2) - x;
if remainingSpace > 200
    spacePerChar = 40;
else
    spacePerChar = remainingSpace / numConnectedComponents * 1;
end

IProject = insertText(IProject, [x y], convertedVal, 'FontSize', floor(spacePerChar), 'BoxColor', 'white');
figure, imshow(IProject);

%% Filters display for pretty pictures
I = deepDreamImage(nn,2,1:16,'PyramidLevels',1);
figure
hold on
I = imtile(I,'ThumbnailSize',[64 64]);
title('Filters for MNIST', 'FontSize', 32)
imshow(I)
hold off