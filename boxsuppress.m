function keep = boxsuppress(boxes, scores, threshold)
% BOXSUPPRESS Box non-maxima suprression
%   KEEP = BOXSUPPRESS(BOXES, SCORES, THRESHOLD)

% remove any empty box (xmax < xmin or ymax < ymin)
scores(any([-1 0 1 0 ; 0 -1 0 1] * boxes < 0)) = -inf ;

keep = false(1, size(boxes,2)) ;
while true
  [score, best] = max(scores) ;
  if score == -inf, break ; end
  keep(best) = true ;
  remove = boxinclusion(boxes(:,best), boxes, 'pascalFormat', true) >= threshold ;
  scores(remove) = -inf ;
  scores(best) = -inf ; % `best` is not in `remove` if threshold > 1
end
