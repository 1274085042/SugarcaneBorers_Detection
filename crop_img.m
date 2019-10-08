
% This script used to crop images
folder_name = 'E:\项目\图形图像实验室\甘蔗螟虫性诱图片\DSC06508.jpg';
savefolder = 'Negative';
I = imread(folder_name);
s = 1;
I = imresize(I, s);
I = imresize(I, 1/s);
Height = size(I, 1);
Width = size(I, 2);

height_scale = 128;
width_scale = 128;
range_Height = Height - height_scale;
range_Width = Width - width_scale;
num_images = 1000;
for i = 1:num_images
    rand_Y = randi(range_Height);
    rand_X = randi(range_Width);
    I2 = imcrop(I, [rand_X rand_Y 63 63]);
    %imshow(I), figure, imshow(I2)
    ii = i+31000;
    imwrite(I2, strcat(savefolder, '\', num2str(ii), '.jpg'),'jpg')
end

