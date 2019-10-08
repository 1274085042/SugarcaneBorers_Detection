function match = evalDetections(gtBoxes, gtDifficult, detBoxes, detScores, varargin)
% EVALDETECTIONS
%   MATCH = EVALDETECTIONS(GTBOXES, GTDIFFICUTL, DETBOXES, DETSCORES)
%
%   MATCH.DETBOXFLAGS: +1 good, 0 match to difficult/ignored, -1 wrong
%   MATCH.DETBOXTOGT:  map to matched GT,  NaN if no match
%   MATCH.GTBOXTODET:  map to matched Det, NaN if missed, 0 if difficult, -1 if ignored
%   MATCH.SCORES:      for evaluation (missed boxes have -inf score)
%   MATCH.LABELS:      for evaluation (difficult/ignored boxes are assigned 0 label)
%
%   The first portion fo MATCH.SCORES and MATCH.LABELS correspond to
%   the DETBOXES, and DETSCORES passed as input. To these, any
%   non-matched ground thruth bounding box is appended with -INF
%   score.
%
%   The boxes are assumed to be given in the PASCAL format, i.e.  the
%   coordinates are indeces of the top-left, bottom-right pixels, not
%   dimensionless coordinates of the box boundaries.
%
%   The detection scores are NOT used to reorder the detection boxes
%   (these should normally be passed by decreasing score) so the
%   output variables match the order of the input variables.
%
%   Auhtor:: Andrea Vedaldi

% AUTORIGHTS
% Copyright (C) 2008-09 Andrea Vedaldi
%
% This file is part of the VGG MKL Class and VGG MKL Det code packages,
% available in the terms of the GNU General Public License version 2.

opts.threshold = 0.5 ;
opts.criterion = 'overlap' ;
opts.ignoreDuplicates = false ;
opts.pascalFormat = true ;
opts.display = false ;
opts = vl_argparse(opts, varargin) ;
numGtBoxes  = size(gtBoxes, 2) ;
numDetBoxes = size(detBoxes, 2) ;

gtBoxToDet  = NaN * ones(1, numGtBoxes) ;
detBoxToGt  = NaN * zeros(1, numDetBoxes) ;
detBoxFlags = - ones(1,numDetBoxes) ;

if isempty(gtBoxes)
  match.detBoxFlags = detBoxFlags ;
  match.detBoxToGt  = detBoxToGt ;
  match.gtBoxToDet  = [] ;
  match.scores      = detScores ;
  match.labels      = -ones(1,size(detBoxes,2)) ;
  return ;
end

% match detected boxes to gt boxes based on the selected criterion
switch lower(opts.criterion)
  case 'overlap'
    criterion = boxoverlap(gtBoxes, detBoxes, 'pascalFormat', opts.pascalFormat) ;
  case 'inclusion'
    criterion = boxinclusion(gtBoxes, detBoxes, 'pascalFormat', opts.pascalFormat) ;
  otherwise
    error('Unknown criterion %s.',  opts.criterion) ;
end
[criterion, allDetBoxToGt] = max(criterion', [], 2) ;

% prematch detected boxes to difficult gt boxes and remove them from
% the evaluation
selDiff = find((criterion > opts.threshold) & gtDifficult(1,allDetBoxToGt)') ;
detBoxFlags(selDiff) = 0 ;
detBoxToGt(selDiff) = allDetBoxToGt(selDiff) ;
gtBoxToDet(gtDifficult) = 0 ;

% match the remaining detected boxes to the non-difficult gt boxes
selDetOk = find(criterion > opts.threshold) ;

nMiss = sum(~gtDifficult) ;
for oki = 1:length(selDetOk)
  % if all gt boxes have been assigned stop
  if nMiss == 0 & ~opts.ignoreDuplicates, break ; end

  dei = selDetOk(oki) ;
  gti = allDetBoxToGt(dei) ;

  % match the gt box to the detection only if the gt box
  % is still unassigned (first detection)
  if isnan(gtBoxToDet(gti))
    gtBoxToDet(gti)  = dei ;
    detBoxToGt(dei)  = gti ;
    detBoxFlags(dei) = +1 ;
    nMiss = nMiss - 1 ;

    detBoxToGt(dei)  = gti ;
    detBoxFlags(dei) = +1 ;
  elseif opts.ignoreDuplicates
    % match the detection to the gt box in any case
    % if duplicates are ignoreed
    detBoxToGt(dei)  = gti ;
    detBoxFlags(dei) = 0 ;
  end
end

% calculate equivalent (scores, labels) pair
selM   = find(detBoxFlags == +1) ; % match
selDM  = find(detBoxFlags == -1) ; % don't match
selDF  = find(detBoxFlags ==  0) ; % difficult or ignored

scores = [detScores, -inf * ones(1,nMiss)] ;
labels = [ones(size(detScores)), ones(1,nMiss)] ;
labels(selDM) = -1 ;
labels(selDF) = 0 ;

match.detBoxFlags = detBoxFlags ;
match.detBoxToGt = detBoxToGt ;
match.gtBoxToDet = gtBoxToDet ;
match.scores = scores ;
match.labels = labels ;

if opts.display
  hold on ;
  vl_plotbox(gtBoxes, 'b', 'linewidth', 2) ;
  vl_plotbox(detBoxes(:, detBoxFlags == +1), 'g') ;
  vl_plotbox(detBoxes(:, detBoxFlags ==  0), 'y') ;
  vl_plotbox(detBoxes(:, detBoxFlags == -1), 'r') ;
end
