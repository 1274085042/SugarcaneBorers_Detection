clear all

size_sample.height = 64;
size_sample.width = 64;
hogCellSize=8;

% Collect negative training data
neg_path = 'train images';
neg_folder= dir(strcat(neg_path, '\*.jpg'));
neg = {} ;
modelWidth =8 ;
modelHeight = 8 ;
for  i=1:length(neg_folder)
  % Get the HOG features of a training image
  t = imread(strcat(neg_path,'\', neg_folder(i).name)) ;
  t = im2single(t) ;  
  hog = vl_hog(t, hogCellSize) ;
  
  % Sample uniformly 400 HOG patches
  % Assume that these are negative (almost certain)
  width = size(hog,2) - modelWidth + 1 ;
  height = size(hog,1) - modelHeight + 1 ;
  index = vl_colsubset(1:width*height, 400, 'uniform') ;

  for j=1:numel(index)
    [hy, hx] = ind2sub([height width], index(j)) ;
    sx = hx + (0:modelWidth-1) ;
    sy = hy + (0:modelHeight-1) ;
    neg{end+1} = hog(sy, sx, :) ;
  end 
end
neg = cat(4, neg{:}) ;
save('data/neg_hog/neg_hog','neg')

% Collect positive training data
pos_path = 'data/Positive';
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
save('more_trainingdata_mat\positive.mat', 'pos_data');
save('more_trainingdata_mat\positive_flip.mat', 'pos_flipdata');
pos_data = cat(4, pos_data, pos_flipdata);

pos = {} ;
for i = 1:size(pos_data,4)
  t = im2single(pos_data(:,:,:,i)) ;
  pos{i} = vl_hog(t, hogCellSize) ;
end
pos = cat(4, pos{:}) ;
save('data/pos_hog/pos_hog','pos')


    
% load data including pos and neg in specified file

% pos_path = 'E:\Project\practical-category-detection-2014a\Positive';
% neg_path = 'E:\Project\practical-category-detection-2014a\Negative';
% pos_folder = dir(strcat(pos_path,'\*.jpg'));    % read positive images from pos_path
% neg_folder= dir(strcat(neg_path, '\*.jpg'));   % read negtive images from neg_path

%loop for read positive samples and save as mat form
% for i=1:length(pos_folder)
%     Image_jpg = imread(strcat(pos_path,'\', pos_folder(i).name)); % read images
%     Image_height = size(Image_jpg, 1);
%     Image_width = size(Image_jpg, 2);
%     if Image_height ~= size_sample.height | Image_width ~= size_sample.width
%         Image_jpg = imresize(Image_jpg, [size_sample.height  size_sample.width]);
%     end
%     pos_data(:,:,:,i) = Image_jpg ; 
    %figure, imshow(Image_jpg)
%     pos_flipdata(:,:,:,i) = flip(Image_jpg);
   % figure, imshow(flip(Image_jpg));
% end
% save('more_trainingdata_mat\positive.mat', 'pos_data');
% save('more_trainingdata_mat\positive_flip.mat', 'pos_flipdata');
% pos_data = cat(4, pos_data, pos_flipdata);

%loop for read negative samples and save as mat form
% for i=1:length(neg_folder)
%     Image_jpg = imread(strcat(neg_path,'\', neg_folder(i).name)); % read images
%     Image_height = size(Image_jpg, 1);
%     Image_width = size(Image_jpg, 2);
%     figure
%     image(Image_jpg)
%     if Image_height ~= size_sample.height | Image_width ~= size_sample.width
%         Image_jpg = imresize(Image_jpg, [size_sample.height  size_sample.width]);
%     end
%     figure
%      image(Image_jpg)
%     neg_data(:,:,:,i) = Image_jpg ; % 
% end
% save('training_data_mat\negative.mat', 'neg_data');


% figure(1);
% vl_imarraysc(pos_data);
% figure(2);
% vl_imarraysc(neg_data(:,:,:,1:100));



% extrcting HOG for training 
% hogCellSize = 8 ;
% pos_trainHog = {} ;
% for i = 1:size(pos_data,4)
%   t = im2single(pos_data(:,:,:,i)) ;
%   pos_trainHog{i} = vl_hog(t, hogCellSize) ;
% end
% pos_trainHog = cat(4, pos_trainHog{:}) ;
% 
% neg_trainHog = {} ;
% for i = 1:1800
%   t = im2single(neg_data(:,:,:,i)) ;
%   neg_trainHog{i} = vl_hog(t, hogCellSize) ;
% end
% neg_trainHog = cat(4, neg_trainHog{:}) ;

 data_training = cat(4, pos, neg) ;
% preparing data with labels for svm training
numPos = size(pos, 4);
numNeg = size(neg, 4);
x_training = reshape(data_training, [], numPos + numNeg) ;

% Create a vector of binary labels and permutation
y_training = [ones(1, numPos) -ones(1, numNeg)] ;
index_rand = randperm(numPos + numNeg);

x_training = x_training(:, index_rand);
y_training = y_training(index_rand);

% Learn the SVM using an SVM solver
C = 10 ;
lambda = 1 / (C * (numPos + numNeg)) ;

num_test =100;
num_alltrain = numPos + numNeg;
[w, b] = vl_svmtrain(x_training(:,1:(num_alltrain-num_test)), y_training(1:(num_alltrain-num_test)), lambda) ;


predict_y = x_training(:,(num_alltrain-num_test+1):num_alltrain)'*w + b;
real_y = y_training((num_alltrain-num_test+1):num_alltrain) ;

predict_y(predict_y>=0) = 1;
predict_y(predict_y<0) = -1;
real_y = reshape(real_y, [], 1);
index_traincorrect(predict_y==real_y) = 1;
rate_correct = sum(index_traincorrect)/length(real_y);

% Reshape the model vector into a model HOG template
modelHeight = 8;
modelWidth = 8;
w = single(reshape(w, modelHeight, modelWidth, [])) ;
save('more_training_model/w.mat', 'w') ;
save('more_training_model/b.mat', 'b');

% Plot model
% figure(1) ; clf ;
% imagesc(vl_hog('render', w)) ;
% colormap gray ; axis equal off ;
% title('SVM HOG model') ;


% Detect objects at Multiscales   从这个地方开始，前面的W B导入
run matconvnet/matlab/vl_setupnn
% Feature configuration
hogCellSize = 8 ;
numHardNegativeMiningIterations = 7 ;
minScale =0 ;
maxScale =6 ;
numOctaveSubdivisions = 3 ;
scales = 2.^linspace(...
  minScale,...
  maxScale,...
  numOctaveSubdivisions*(maxScale-minScale+1)) ;

%-------------------------------------------------------------------------
% Read imges from folder
%-------------------------------------------------------------------------
Img_folder = 'test images\2.JPG';
im = imread(Img_folder) ;
% im = imresize(im, 0.3) ;
im = im2single(im) ;



% 
% figure(5) ; clf ;
% detection = detectAtMultipleScales(im, w, b,hogCellSize, scales) ;
% % Plot top detection
% figure(6) ; clf ;
% imagesc(im) ; axis equal off ; hold on ;
% vl_plotbox(detection, 'g', 'linewidth', 2) ;
% title('SVM detector output') ;

% Compute detections
[detections, scores] = detect_xu(im, w, b, hogCellSize, scales) ;


figure(3) ; clf ;
imagesc(im) ; axis equal off ; hold on ;
vl_plotbox(detections, 'g', 'linewidth', 2) ;
title('SVM detector output') ;


% Non-maxima suppression
keep = boxsuppress(detections, scores, 0.25) ;

detections = detections(:, keep) ;
scores = scores(keep) ;

figure(7) ; clf ;
imagesc(im) ; axis equal off ; hold on ;
vl_plotbox(detections, 'g', 'linewidth', 2) ;
title('Non-maxima suppression output') ;

% -------------------------------------------------------------------------
%Detector evaluation
% -------------------------------------------------------------------------

% Find all the objects in the target image
s = find(strcmp(testImages{10}, testBoxImages)) ;
gtBoxes = testBoxes(:, s) ;

% No example is considered difficult
gtDifficult = false(1, numel(s)) ;

% PASCAL-like evaluation
matches = evalDetections(...
  gtBoxes, gtDifficult, ...
  detections, scores) ;

% Visualization
figure(8) ; clf ;
imagesc(im) ; axis equal ; hold on ;
vl_plotbox(detections(:, matches.detBoxFlags==+1), 'g', 'linewidth', 2) ;
vl_plotbox(detections(:, matches.detBoxFlags==-1), 'r', 'linewidth', 2) ;
vl_plotbox(gtBoxes, 'b', 'linewidth', 1) ;
axis off ;

figure(9) ; clf ;
vl_pr(matches.labels, matches.scores,'Interpolate','TRUE') ;


figure(10) ; clf ;
vl_pr(matches.labels, matches.scores) ;


% -------------------------------------------------------------------------
% Evaluation on multiple images
% -------------------------------------------------------------------------

figure(11) ; clf ;

matches = evaluateModel(testImages, testBoxes, testBoxImages, ...
  w,b, hogCellSize, scales) ;










% Further keep only top detections
% detections = detections(:, 1:5) ;
% scores = scores(1:5) ;
% ex_response = find(scores>0.12);
% scores = scores(index_response) ;
% detections = detections(:, index_response) ;


% Plot top detection
figure(12) ; clf ;
imagesc(im) ; axis equal ;
hold on ;
vl_plotbox(detections, 'g', 'linewidth', 2, ...
  'label', arrayfun(@(x)sprintf('%.2f',x),scores,'uniformoutput',0)) ;
% title('Multiple detections') ;

