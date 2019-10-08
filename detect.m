function [detections,scores,hog] = detect(im, w, hogCellSize, scales)

modelWidth = size(w, 2) ;
modelHeight = size(w, 1) ;

detections = {} ;
scores = {} ;
hog = {} ;

for s = scales
  % scale image
  t = imresize(im, 1/s) ;
  
  % skip if too small
  if min([size(t,1), size(t,2)]) < 128, break ; end

  % extract HOG features
  hog{end+1} = vl_hog(t, hogCellSize) ;
  
  % convolve model
  sc = vl_nnconv(hog{end}, w, []) ;
  
  % get all detections
  [hy,hx] = ind2sub(size(sc), 1:numel(sc)) ;
  
  hx = hx(:)' ;
  hy = hy(:)' ;
  x = (hx - 1) * hogCellSize * s + 1 ;
  y = (hy - 1) * hogCellSize * s + 1 ;
  detections{end+1} = [...
    x - 0.5 ;
    y - 0.5 ;
    x + hogCellSize * modelWidth * s - 0.5 ;
    y + hogCellSize * modelHeight * s - 0.5 ;] ;
  scores{end+1} = sc(:)' ;
end

detections = cat(2, detections{:}) ;
scores = cat(2, scores{:}) ;

[~, perm] = sort(scores, 'descend') ;

perm = perm(1:1000) ;
scores = scores(perm) ;
detections = detections(:, perm) ;
