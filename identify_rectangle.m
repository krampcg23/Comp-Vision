I = imread('im3.JPG');
%I = imresize(I, 0.3);

[height width colors] = size(I);

level = graythresh(I);
G = imbinarize(I, level);
% E = edge(G, 'canny');
% imshow(E)


% [mserRegions, mserConnComp] = detectMSERFeatures(G, 'RegionAreaRange',[height width],'ThresholdDelta',0.001);
% 
% figure
% imshow(I)
% hold on
% plot(mserRegions, 'showPixelList', true,'showEllipses',false)
% title('MSER regions')
% hold off   

O = ocr(G);
%word = O.Words{2};
%wordBBox = O.WordBoundingBoxes(2,:);
%figure;
%Iname = insertObjectAnnotation(I, 'rectangle', wordBBox, word);
%imshow(Iname);
best_R = G;
% find best confidence
max_conf = 0;
best_angle = 0;
for angle = -20:1:20
    R = imrotate(G, angle);
    O = ocr(R);
    if(size(O.CharacterConfidences, 1) > max_conf)
       max_conf = size(O.CharacterConfidences, 1);
       best_R = R;
       best_angle = angle;
    end
    close all
end

b = ocr(best_R);
b = b.WordBoundingBoxes;

min_height = inf;
max_height = 0;
min_width = inf;
max_width = 0;
for i=1:size(b,1)
    if(b(i,1) < min_height)
       min_height = b(i,1); 
    end
    
    if(b(i,2) < min_width)
       min_width = b(i,2);
    end
    
    if((b(i,1)+b(i,3)) > max_height)
        max_height = (b(i,1)+b(i,3));
    end
    
    if((b(i,2)+b(i,4)) > max_width)
        max_width = (b(i,2)+b(i,4));
    end
end

% pts = insertMarker(I, [min_height min_width], 'color', 'red', 'size', 10);
% pts = insertMarker(pts, [min_height max_width], 'color', 'green', 'size', 10);
% pts = insertMarker(pts, [max_height min_width], 'color', 'white', 'size', 10);
% pts = insertMarker(pts, [max_height max_width], 'color', 'blue', 'size', 10);
% figure
% imshow(pts)
result = imrotate(I, best_angle);
result = result(:,:,1);
imshow(result)
line([min_height min_height], [min_width max_width], 'LineWidth', 2);
line([min_height max_height], [max_width max_width], 'LineWidth', 2);
line([max_height max_height], [max_width min_width], 'LineWidth', 2);
line([max_height min_height], [min_width min_width], 'LineWidth', 2);

% wordBBox = b(:,:);
% figure;
% Iname = insertObjectAnnotation(result, 'rectangle', wordBBox, word);
% imshow(Iname);



%% 
% orthophoto

%  [min_height min_width]
%  [min_height max_width]
%  [max_height min_width]
%  [max_height max_width]
file = fopen('rectangle.txt', 'w');
fprintf(file, '%d %d ', min_width, min_height);
fprintf(file, '%d %d', (max_width - min_width), (max_height-min_height));
fclose(file);



