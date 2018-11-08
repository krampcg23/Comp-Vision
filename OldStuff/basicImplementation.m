%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clayton Kramp and Katrina Steinman
% CSCI 507 Final Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%alphabet = 'aefilmoprstvy';
alphabet = 'abcdefghijklmnopqrstuvwxyz';
text = rgb2gray(imread('images/helloworld.png'));
numItems = 1;

for i = 1:size(alphabet,2)
    % Construct the template
    str = strcat('images/alphabet/', (alphabet(i)), '.png');
    template = rgb2gray(imread(str));

    % Find the correlation values
    correlation = normxcorr2(template, text);
    
    % Threshold into bw image
    threshold = 0.85;
    BW = im2bw(correlation, threshold);
    
    % Count number of values
    regionalMax = imregionalmax(correlation);
    Final = regionalMax & BW;
    %fprintf('Number of %s is %d \n', alphabet(i), sum(Final(:)));
    
    % Overlay Plot
    [rows,cols] = find(Final);
      
    for j = 1:size(cols, 1)
        element.alphabet = alphabet(i);
        element.col = cols(j);
        allLetters(numItems) = element;
        numItems = numItems + 1;
    end
end
if size(allLetters) > 0
    allLetters = SortArrayofStruct(allLetters, 'col');
    currentCol = allLetters(1).col;
    fprintf('%s', allLetters(1).alphabet)
    for i = 1:size(allLetters, 2)-1
        dist = allLetters(i+1).col - allLetters(i).col;
        distances(i) = dist;
    end
    averageDist = mean(distances);
    distThresh = 1.5 * averageDist;
    for i = 2:size(allLetters, 2)
        str = allLetters(i).alphabet;
        if currentCol + distThresh < allLetters(i).col
            str = [' ', str];
        end
        currentCol = allLetters(i).col;
        fprintf('%s', str)
    end
else 
    fprintf('No text found')
end
