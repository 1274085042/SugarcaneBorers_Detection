%function detection = detectAtMultipleScales(im, w, hogCellSize, scales)
function detection = detectAtMultipleScales(im, w, b, hogCellSize, scales)
modelWidth = size(w, 2) ;
modelHeight = size(w, 1) ;
bestScore = -inf ;
minScore = +inf ;
maxScore = -inf ;
h = [] ;

for s = scales
  % scale image
  t = imresize(im, 1/s) ;
  
   % skip if too small
  if min([size(t,1), size(t,2)]) < 128, break ; end
  
  % extract HOG features
  hog = vl_hog(t, hogCellSize) ;
  
  % convolve model
  %scores = vl_nnconv(hog, w, []) ;
  scores  = vl_nnconv(hog, w, [])+b ;
  
  % pick best response
  [score, index] = max(scores(:)) ;
  if score > bestScore
    bestScore = score ;
    [hy, hx] = ind2sub(size(scores), index) ;
    x = (hx - 1) * hogCellSize * s + 1 ;
    y = (hy - 1) * hogCellSize * s + 1 ;
    detection = [
      x - 0.5 ;
      y - 0.5 ;
      x + hogCellSize * modelWidth * s - 0.5 ;
      y + hogCellSize * modelHeight * s - 0.5 ;] ;
  end
    
  % plot score map
  vl_tightsubplot(numel(scales),find(s==scales)) ;
  imagesc(scores) ; axis off square ;
  h(end+1) = gca;
  minScore = min([minScore;scores(:)]) ;
  maxScore = max([maxScore;scores(:)]) ;
end

set(h, 'clim', [minScore, maxScore]) ;


