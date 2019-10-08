function loadData(targetClass, numPosImages, numNegImages)
% LOADDATA  Load data for exercies
%   LOADDATA(TARGETCLASS) loads the data configuring it to train
%   the specified target class. TARGETCLASS is a vector of one or more
%   labels. If more than one label is specified, then multiple classes
%   are merged into one.
%
%   LOADDATA(TARGETCLASS, NUMPOSIMAGES, NUMNEGIMAGES) allows specifying
%   the number of positive and negative images too.
%
%   The following variables are created in the workspace:
%
%   - trainImages: list of training image names.
%   - trainBoxes: 4 x N array of object bounding boxes
%   - trainBoxImages: for each box, the corresponding image.
%   - trainBoxLabels: the class label of the box (one of TARGETCLASS).
%   - trainBoxPatches: 64 x 64 x 3 x N array of box patches.
%
%   The same for the test data.

if nargin < 2
  numPosImages = 20 ;
end

if nargin < 3
  numNegImages = 20 ;
end

load('data/signs.mat', ...
  'trainImages', ...
  'trainBoxes', ...
  'trainBoxImages', ...
  'trainBoxLabels', ...
  'trainBoxPatches', ...
  'testImages', ...
  'testBoxes', ...
  'testBoxImages', ...
  'testBoxLabels', ...
  'testBoxPatches') ;


if isstr(targetClass)
  switch lower(targetClass)
    case 'prohibitory', targetClass = [0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 15, 16] ;
    case 'mandatory', targetClass = [33, 34, 35, 36, 37, 38, 39, 40] ;
    case 'danger', targetClass = [11, 18, 19, 20 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31] ;
  end
end

% Select only the target class
ok = ismember(trainBoxLabels, targetClass) ;
trainBoxes = trainBoxes(:,ok) ;
trainBoxImages = trainBoxImages(ok) ;
trainBoxLabels = trainBoxLabels(ok) ;
trainBoxPatches = trainBoxPatches(:,:,:,ok) ;

ok = ismember(testBoxLabels, targetClass) ;
testBoxes = testBoxes(:,ok) ;
testBoxImages = testBoxImages(ok) ;
testBoxLabels = testBoxLabels(ok) ;
testBoxPatches = testBoxPatches(:,:,:,ok) ;

% Select a subset of training and testing images
[~,perm] = sort(ismember(trainImages, trainBoxImages),'descend') ;
trainImages = trainImages(vl_colsubset(perm', numPosImages, 'beginning')) ;

[~,perm] = sort(ismember(testImages, testBoxImages),'descend') ;
testImages = testImages(vl_colsubset(perm', numNegImages, 'beginning')) ;
  
vars = {...
  'trainImages', ...
  'trainBoxes', ...
  'trainBoxImages', ...
  'trainBoxLabels', ...
  'trainBoxPatches', ...
  'testImages', ...
  'testBoxes', ...
  'testBoxImages', ...
  'testBoxLabels', ...
  'testBoxPatches', ...
  'targetClass'} ;

for i = 1:numel(vars)
  assignin('caller',vars{i},eval(vars{i})) ;
end
