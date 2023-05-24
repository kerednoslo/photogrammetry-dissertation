function [Il,Ir,X0L,X0R,Y0L,focalLength,camSep,Q] = loadRectData(baseDir,imgFileName) %#ok<STOUT>
% USAGE: [Il,Ir,X0L,X0R,Y0R,loadRectStatus] = loadRectData(baseDir,imgNameFull)
% This function loads in the precomputed rectified data

% First of all, if the directory does not exist, create it.

rectifiedDataPath = fullfile(baseDir,'rectifiedData');

% imgFiles = dir(baseDir);


% Strip the leading info from the imgDataFile
underscoreLocs = strfind(imgFileName,'_');
imgFileName = imgFileName(underscoreLocs(end) +1:end-4);

% build rectified data name
rectifiedDataFileName = ['rectifiedImg_' imgFileName '.mat'];

load(fullfile(rectifiedDataPath,rectifiedDataFileName));

success = 1;

end