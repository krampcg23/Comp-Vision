clear variables
close all
rng(0);

alphabet = 'abcdefghijklmnopqrstuvwxyz';
text = single(rgb2gray(imread('images/helloworld.png')));
% These parameters limit the number of features detected
peak_thresh = 0;    % increase to limit; default is 0
edge_thresh = 10;   % decrease to limit; default is 10
numItems = 1;

for i = 1:size(alphabet,2)
    % Construct the template
    str = strcat('images/alphabet/', (alphabet(i)), '.png');
    template = single(rgb2gray(imread(str)));
    
    if exist('vl_sift', 'file')==0
        run('./vlfeat/toolbox/vl_setup');
    end
    
    [f1,d1] = vl_sift(text, ...
        'PeakThresh', peak_thresh, ...
        'edgethresh', edge_thresh );

    [f2,d2] = vl_sift(template, ...
        'PeakThresh', peak_thresh, ...
        'edgethresh', edge_thresh );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Match features
    thresh = 1.5;   % default = 1.5; increase to limit matches
    [matches, scores] = vl_ubcmatch(d1, d2, thresh);

    indices1 = matches(1,:);        % Get matching features
    f1match = f1(:,indices1);
    d1match = d1(:,indices1);

    indices2 = matches(2,:);
    f2match = f2(:,indices2);
    d2match = d2(:,indices2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Show matches
    template = imresize(template, [size(text, 1), size(text, 2)]);
    figure, imshow([text,template],[]);
    o = size(text,2) ;
    line([f1match(1,:);f2match(1,:)+o], ...
        [f1match(2,:);f2match(2,:)]) ;
    for l=1:size(f1match,2)
        x = f1match(1,l);
        y = f1match(2,l);
        text(x,y,sprintf('%d',l), 'Color', 'r');
    end
    for l=1:size(f2match,2)
        x = f2match(1,l);
        y = f2match(2,l);
        text(x+o,y,sprintf('%d',l), 'Color', 'r');
    end
    
    for j = 1:size(f1match, 1)
        element.alphabet = alphabet(i);
        %element.col = cols(j);
        allLetters(numItems) = element;
        numItems = numItems + 1;
    end 
end

if size(allLetters) > 0
    %allLetters = SortArrayofStruct(allLetters, 'col');
    %currentCol = allLetters(1).col;
    fprintf('%s', allLetters(1).alphabet)
    %for i = 1:size(allLetters, 2)-1
    %    dist = allLetters(i+1).col - allLetters(i).col;
    %    distances(i) = dist;
    %end
    %averageDist = mean(distances);
    %distThresh = 1.5 * averageDist;
    for i = 2:size(allLetters, 2)
        str = allLetters(i).alphabet;
     %   if currentCol + distThresh < allLetters(i).col
     %       str = [' ', str];
     %   end
     %   currentCol = allLetters(i).col;
        fprintf('%s', str);
    end
else 
    fprintf('No text found')
end