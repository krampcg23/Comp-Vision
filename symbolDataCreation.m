clear all
close all

symbolsSet = ['D', 'Y', 'E'];
fileName = ['1','2','3','4',"Test"];
for i  = 1:size(symbolsSet,2)
    for j = 1:5
        dir = strcat('images/symbols/', symbolsSet(i), fileName(j),'.png');
        I = rgb2gray(imread(dir));
        I = imresize(I, 0.5);
        imshow(I);
        I =~im2bw(I,0.4);
        I = bwareaopen(I,10);
        [Labels numConnectedComponents]=bwlabel(I);
        props = regionprops(Labels,'BoundingBox');
        hold on
        for n=1:size(props,1)
            rectangle('Position',props(n).BoundingBox,'EdgeColor','r','LineWidth',2)
        end
        hold off

        for k=1:numConnectedComponents
            [row,col] = find(Labels == k);
            newImg = imgaussfilt(single(I(min(row):max(row),min(col):max(col))),1);
            symbol(:,:) = padarray(imresize(newImg, [18 18]),[5 5],0,'both');
            if j == 5
                dir2 = strcat('Data/Symbols/Test/', symbolsSet(i),fileName(j),'-',int2str(k),'.png');
            else 
                dir2 = strcat('Data/Symbols/Train/', symbolsSet(i),fileName(j),'-',int2str(k),'.png');
            end
            imwrite(symbol, dir2);
        end
    end
end