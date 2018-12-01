%function imcropped = localize
    clear all
    close all
    theSize = 16;
    directories = cell(1, theSize);
    x = zeros(1, theSize); y = zeros(1, theSize); 
    w = zeros(1, theSize); h = zeros(1, theSize);
    labels = {};
    if ~exist('locations.mat', 'file')
        for i = 1:theSize
            directory = 'images/Localization/';
            directory = strcat(directory, num2str(i), '.JPG');
            I = imresize(rgb2gray(imread(directory)), [100 150]);
            figure, imshow(I)
            rect = getrect;
            directories(i) = {directory};
            x(i) = rect(1); y(i) = rect(2); w(i) = rect(3); h(i) = rect(4);
        end
        save('locations.mat', 'directories', 'x', 'y', 'w', 'h');
    else
        load('locations.mat');
    end
    
    train = zeros(100, 150, 1, theSize, 'single');
    for i = 1:theSize
        directory = 'images/Localization/';
        directory = strcat(directory, num2str(i), '.JPG');
        I = imresize(rgb2gray(imread(directory)), [100 150]);
        I = double(I);
        I = I/255;
        train(:,:,1,i) = I;
    end
        

    layers = [  imageInputLayer([100 150 1])
                convolution2dLayer([50 50], 20, 'Padding', 20)   
                reluLayer()
                convolution2dLayer([10 10], 20, 'Padding', 3)  
                reluLayer() 
                maxPooling2dLayer(2, 'Stride',2)    
                fullyConnectedLayer(4)
                regressionLayer
            ];
    rng(0);
    batch = 4;
    trainOptions = trainingOptions( 'sgdm',...
    'MiniBatchSize', batch,...
    'Plots', 'training-progress',...
    'VerboseFrequency', 10, ...
    'MaxEpochs',25);
    nn = trainNetwork(train, [x' y' w' h'], layers, trainOptions);
    
%     I = deepDreamImage(nn,2,1:10,'PyramidLevels',1);
%     figure
%     I = imtile(I,'ThumbnailSize',[64 64]);
%     imshow(I)
%     title(['Layer ',name,' Features'])

%end