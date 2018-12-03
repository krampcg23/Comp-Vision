imgCount = 32;
for i = 1:imgCount
    directory = 'images/Tests/Test';
    directory = [directory num2str(i) '.JPG'];
    I = rgb2gray(imresize(imread(directory), [200 300]));
    directory = 'images/Tests/Test';
    directory = [directory num2str(i) '.png'];
    imwrite(I, directory);
end