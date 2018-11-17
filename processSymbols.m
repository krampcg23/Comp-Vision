function [train, test, trainLabels, testLabels] = processSymbols(dir)
train = zeros(28, 28, 1, 180, 'single');
test = zeros(28, 28, 1, 45, 'single');
trainLabels = zeros(180);
testLabels = zeros(45);
symbolsSet = ['D', 'Y', 'E'];
fileName = ['1','2','3','4',"Test"];

for i  = 1:size(symbolsSet,2)
    for j = 1:5
        for k = 1:15
            direc = strcat(dir, symbolsSet(i), fileName(j),'-', int2str(k));
            I = imread(direc);
            if j == 5
                test(:,:,1,i*k) = I;
                testLabels(i*k) = symbolsSet(i);
            else
                train(:,:,1,i*j*k) = I;
                trainLabels(i*j*k) = symbolsSet(i);
            end
        end
    end
end
trainLabels = categorical(trainLabels);
testLabels = categorical(testLabels);
end