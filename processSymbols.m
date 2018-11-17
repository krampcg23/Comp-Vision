function [train, test, trainLabels, testLabels] = processSymbols(dir)
train = zeros(28, 28, 1, 180, 'single');
test = zeros(28, 28, 1, 45, 'single');
trainLabels = {};
testLabels = {};
symbolsSet = ['D', 'Y', 'E'];
fileName = ['1','2','3','4',"Test"];

for i  = 1:size(symbolsSet,2)
    for j = 1:5
        for k = 1:15
            if j == 5
                direc = strcat(dir, 'Test/', symbolsSet(i), fileName(j),'-', int2str(k),'.png');
                I = imread(direc);
                I = I/255;
                test(:,:,1,(i-1)*15 + k) = I;
                testLabels(1,(i-1)*15 + k) = {symbolsSet(i)};
            else
                direc = strcat(dir, 'Train/', symbolsSet(i), fileName(j),'-', int2str(k),'.png');
                I = imread(direc);
                I = I/255;
                train(:,:,1,(i-1)*60 + (j-1)*15 + k) = I;
                trainLabels(1,(i-1)*60 + (j-1)*15 + k) = {symbolsSet(i)};
            end
        end
    end
end
trainLabels = categorical(trainLabels);
trainLabels = reshape(trainLabels, [180 1]);
testLabels = categorical(testLabels);
testLabels = reshape(testLabels, [45 1]);
end