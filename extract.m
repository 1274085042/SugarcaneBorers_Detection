function features = extract(hog, hogCellSize, scales, w, detections)

modelWidth = size(w,2) ;
modelHeight = size(w,1) ;

s = (detections(3,:) - detections(1,:)) / hogCellSize / modelWidth ;

features = {} ;
for i=1:size(detections,2)
  [~,j] = min(abs(s(i) - scales)) ;
  
  hx = (detections(1,i) - 0.5) / hogCellSize / s(i) + 1 ;
  hy = (detections(2,i) - 0.5) / hogCellSize / s(i) + 1 ;
  sx = round(hx)+ (0:modelWidth-1) ;
  sy = round(hy) + (0:modelHeight-1) ;
  
  features{end+1} = hog{j}(sy, sx, :) ;
end
features = cat(4, features{:}) ;
