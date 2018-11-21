%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clayton Kramp and Katrina Steinman
% CSCI 507 Final Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

directory = 'images/E549.png';

I=rgb2gray(imread(directory));
%I = imresize(I, 0.5);
imshow(I)
I =~imbinarize(I,0.4);
I = bwareaopen(I,150);
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

%%
for i=1:numConnectedComponents
    if i == minIndex
        symbolsExtracted(numSymbols) = {'.'};
    else
        [row,col] = find(Labels == i);
        symbol = zeros(28, 28, 1, 1);
        newImg = imgaussfilt(single(I(min(row):max(row),min(col):max(col))),1);
        symbol(:,:,1,1) = padarray(imresize(newImg, [18 18]),[5 5],0,'both');
        if i == 1
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

%% Search for the four quadrants
maxRow = 0; minRow = inf; maxCol = 0; minCol = inf;
avgRow = 0; avgCol = 0;
for i = 1:numConnectedComponents
    if i == minIndex
        continue;
    end
    [row,col] = find(Labels == i);
    avgRow = avgRow + mean(row);
    avgCol = avgCol + mean(col);
    if (max(row) > maxRow), maxRow = max(row); end
    if (max(col) > maxCol), maxCol = max(col); end
    if (min(row) < minRow), minRow = min(row); end
    if (min(col) < minCol), minCol = min(col); end
end
avgRow = avgRow / 4;
avgCol = avgCol /4;

IProject=rgb2gray(imread(directory));
%IProject = imresize(IProject, 0.5);
figure, imshow(IProject);

dimensions = [ maxCol 1 size(IProject,2)-maxCol size(IProject, 1)-1;
               1 maxRow size(IProject,2)-1 size(IProject, 1)-maxRow;
               1 1 size(IProject,2)-1 minRow;
               1 1 minCol size(IProject, 1)-1];

hold on
for i = 1:4
    rectangle('Position',dimensions(i,:),'EdgeColor','r','LineWidth',2)
end
hold off

minBoundingBoxes = inf; coord = 1;
for i = 1:4
    Itemp = ~IProject(dimensions(i,2):dimensions(i, 2)+dimensions(i,4), ...
        dimensions(i,1):dimensions(i,1) + dimensions(i,3));
    [l, n]=bwlabel(Itemp);
    if n < minBoundingBoxes, minBoundingBoxes = n; coord = i; end
end

if coord == 1 || coord == 4
   x = dimensions(coord, 1);
   y = avgRow;
   width = dimensions(coord, 3)/2;
   height = dimensions(coord,4)/4;
else
   x = avgCol;
   y = dimensions(coord,2);
   width = dimensions(coord, 3)/4;
   height = dimensions(coord,4);
end
textPosition = [x y width height];

hold on
rectangle('Position',textPosition(:),'EdgeColor','b','LineWidth',2)
hold off
% Gathering info for the text
text_str = '';
if symbolsExtracted{1} == 'D', text_str = [text_str '$'];
elseif symbolsExtracted{1} == 'E', text_str = [text_str 'E'];
else text_str = [text_str 'Y'];
end
for i = 2:size(symbolsExtracted, 2)
    text_str = [text_str num2str(symbolsExtracted{i})];
end

remainingSpace = size(IProject, 2) - x;
if remainingSpace > 200
    spacePerChar = 40;
else
    spacePerChar = remainingSpace / numConnectedComponents * 1.5;
end

IProject = insertText(IProject, textPosition(1:2), text_str, 'FontSize', floor(spacePerChar), 'BoxColor', 'white');
figure, imshow(IProject);