I = imread('images/im3.JPG');

[height width colors] = size(I);

level = graythresh(I);
G = imbinarize(I, level);
se = strel('square', 2);
G = imclose(G, se);
G = imopen(G, se);

O = ocr(G);
best = O;
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
       best = O;
       best_angle = angle;
    end
    close all
end

best = ocr(best_R);
b = best.WordBoundingBoxes;

min_height = inf;
max_height = 0;
min_width = inf;
max_width = 0;
for i=1:size(b,1)
    if best.Words{i} == ' '
       continue 
    end
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

result = imrotate(I, best_angle);
imshow(result)
line([min_height min_height], [min_width max_width], 'LineWidth', 2);
line([min_height max_height], [max_width max_width], 'LineWidth', 2);
line([max_height max_height], [max_width min_width], 'LineWidth', 2);
line([max_height min_height], [min_width min_width], 'LineWidth', 2);

% result
 %show word boxes
%  Iname = insertObjectAnnotation(result, 'rectangle', best.WordBoundingBoxes, best.WordConfidences);
% figure
% imshow(Iname)

%% 
% orthophoto
% Ipts = [min_height min_width;
%         min_height max_width;
%         max_height min_width;
%         max_height max_width;];
%     
% Wpts = [0 0;
%         0 max_width-min_width;
%         max_height-min_height 0;
%         max_height-min_height max_width-min_width];
%     
% transform = fitgeotrans(Ipts, Wpts, 'projective');
% [ortho, ref]= imwarp(result, transform);
% figure
% imshow(ortho)
% title('Orthophoto')
% 
% [X,Y] = transformPointsForward(transform, Ipts(:,1), Ipts(:,2));
% 
% X = X - ref.XWorldLimits(1);
% Y = Y - ref.YWorldLimits(1);
%  line([X(1) X(2)], [Y(1) Y(2)], 'LineWidth', 2);
%  line([X(2) X(4)], [Y(2) Y(4)], 'LineWidth', 2);
%  line([X(3) X(4)], [Y(3) Y(4)],'LineWidth', 2);
%  line([X(3) X(1)], [Y(3) Y(1)],'LineWidth', 2);

%% write out
file = fopen('temp/rectangle.txt', 'w');
fprintf(file, '%d %d ', min_width, min_height);
fprintf(file, '%d %d', (max_width - min_width), (max_height-min_height));
fclose(file);
saveas(gcf, 'temp/post_processed.png');


