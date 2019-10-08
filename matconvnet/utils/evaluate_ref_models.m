function evaluate_ref_models()
% Evaluate MatConvNet reference models to validate them

addpath(fullfile(fileparts(mfilename('fullpath'))), '..','examples');

models = {...
  'caffe-ref', ...
  'caffe-alex', ...
  'vgg-s', ...
  'vgg-m', ...
  'vgg-f', ...
  'vgg-verydeep-19', ...
  'vgg-verydeep-16'} ;

for i = 1:numel(models)
  opts.dataDir = 'data/imagenet12' ;
  opts.expDir = sprintf('data/models-eval/%s', models{i}) ;
  opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
  opts.modelPath = sprintf('data/models/imagenet-%s.mat', models{i}) ;
  opts.lite = false ;
  opts.numFetchThreads = 12 ;
  opts.train.batchSize = 64 ;
  opts.train.numEpochs = 1 ;
  opts.train.useGpu = true ;
  opts.train.prefetch = true ;
  opts.train.expDir = opts.expDir ;
  opts.train.conserveMemory = true ;

  resultPath = fullfile(opts.expDir, 'results.mat') ;
  if ~exist(resultPath)
    results = cnn_imagenet_evaluate(opts) ;
    save(fullfile(opts.expDir, 'results.mat'), 'results') ;
  end
end


fprintf('|%20s|%10s|%10s|%10s|\n', 'model', 'top-1 err.', 'top-5 err.', 'images/s') ;
fprintf('%s\n', repmat('-',1,20+10+10+10+5)) ;

for i = 1:numel(models)
  opts.expDir = sprintf('data/models-eval/%s', models{i}) ;
  resultPath = fullfile(opts.expDir, 'results.mat') ;
  load(resultPath, 'results') ;

  fprintf('|%20s|%10s|%10s|%10s|\n', ...
    models{i}, ...
    sprintf('%5.1f',results.val.error(end)*100), ...
    sprintf('%5.1f',results.val.topFiveError(end)*100), ...
    sprintf('%5.1f',results.val.speed(end))) ;
end
