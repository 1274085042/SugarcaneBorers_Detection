function cnn_imagenet_minimal()
% CNN_IMAGENET_MINIMAL   Minimalistic demonstration of how to run an ImageNet CNN model

% setup toolbox
run(fullfile(fileparts(mfilename('fullpath')), '../matlab/vl_setupnn.m')) ;

% download a pre-trained CNN from the web
if ~exist('imagenet-vgg-f.mat')
  urlwrite('http://www.vlfeat.org/matconvnet/models/imagenet-vgg-f.mat', ...
    'imagenet-vgg-f.mat') ;
end
net = load('imagenet-vgg-f.mat') ;

% obtain and preprocess an image
im = imread('peppers.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.normalization.imageSize(1:2)) ;
im_ = im_ - net.normalization.averageImage ;

% run the CNN
res = vl_simplenn(net, im_) ;

% show the classification result
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;
figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s (%d), score %.3f',...
   net.classes.description{best}, best, bestScore)) ;

