% -------------------------------------------------------------------------
% Visualize the training images
% -------------------------------------------------------------------------
% Collect positive training data
size_sample.height =180;
size_sample.width=180;
pos_path = 'data/positive_test';
pos_folder = dir(strcat(pos_path,'\*.png'));    % read positive images from pos_path
for i=1:length(pos_folder)
    Image = imread(strcat(pos_path,'\', pos_folder(i).name));  % read images
    Image_height = size(Image, 1);
    Image_width = size(Image, 2);
    if Image_height ~= size_sample.height | Image_width ~= size_sample.width
        Image = imresize(Image, [size_sample.height  size_sample.width]);
    end
    pos_data(:,:,:,i) = Image ; 
    pos_flipdata(:,:,:,i) = flip(Image);
 
end

figure(1) ; clf ;

subplot(1,2,1) ;
vl_imarraysc(pos_data);
axis off ;
title('Training images (ori positive samples)') ;
axis equal ;

subplot(1,2,2) ;
vl_imarraysc(pos_flipdata);
axis off ;
title('Training images (flip positive samples)') ;
axis equal ;

pos = cat(4, pos_data, pos_flipdata);

% -------------------------------------------------------------------------
%  Extract HOG features from the training images
% -------------------------------------------------------------------------
hogCellSize = 8 ;
poshog = {} ;
for i = 1:size(pos,4)
  t = im2single(pos(:,:,:,i)) ;
  poshog{i} = vl_hog(t, hogCellSize) ;
end
poshog = cat(4, poshog{:}) ;

% -------------------------------------------------------------------------
% Learn a simple HOG template model
% -------------------------------------------------------------------------
w = mean(poshog, 4) ;

figure(2) ; clf ;
imagesc(vl_hog('render', w)) ;
colormap gray ;
axis equal ;
title('HOG model') ;

% -------------------------------------------------------------------------
% Apply the model to a test image
% -------------------------------------------------------------------------
run matconvnet/matlab/vl_setupnn

% Detect objects at Multiscales   从这个地方开始，前面的W B导入

im = imread('QQ截图20180417212606.png') ;
% im =imresize(im,3,'bilinear');
im = im2single(im) ;
hog = vl_hog(im, 8) ;
scores = {} ;
sc = vl_nnconv(hog, w, [])+b ;   %卷积后的维度（？）
% imshow(im);
 [hy,hx] = ind2sub(size(sc), 1:numel(sc)) ;
detections = {} ;

 hx = hx(:)' ;
 hy = hy(:)' ;
 x = (hx - 1) * 8  + 1 ;
 y = (hy - 1) * 8  + 1 ;
 detections{end+1} = [...
    x - 0.5 ;
    y - 0.5 ;
    x + 8 * 8-0.5 ;
    y + 8 * 8-0.5 ;] ;
 scores{end+1} = sc(:)' ;

detections = cat(2, detections{:}) ;
scores = cat(2, scores{:}) ;

[~, perm] = sort(scores, 'descend') ;

perm = perm(1) ;
scores = scores(perm) ;
detections = detections(:, perm) ;

figure(3) ; clf ;
imagesc(sc) ;
title('response map') ;
colorbar ;


% Plot top detection
figure(5) ; clf ;
imagesc(im) ; axis equal off ; hold on ;
vl_plotbox(detections, 'g', 'linewidth', 2) ;
title('SVM detector output') ;









