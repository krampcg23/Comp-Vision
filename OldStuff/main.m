%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clayton Kramp and Katrina Steinman
% CSCI 507 Final Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

I=rgb2gray(imread('../images/34.jpg'));
threshold = graythresh(I);
imshow(I);
I =~im2bw(I,threshold);
I = bwareaopen(I,10);

[Labels numConnectedComponents]=bwlabel(I);
props = regionprops(Labels,'BoundingBox');

hold on
for n=1:size(props,1)
    rectangle('Position',props(n).BoundingBox,'EdgeColor','r','LineWidth',2)
end
hold off

%figure
for n=1:numConnectedComponents
    [r,c] = find(Labels==n);
    n1=I(min(r):max(r),min(c):max(c));
    %imshow(~n1);
end