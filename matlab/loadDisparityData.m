function [dd]  = loadDisparityData(baseDir,imgNameFull,avgWin)
% USAGE: [dd] = loadDisparityData(baseDir,imgNameFull);
% This function laods in the saved disparity data

disparityDir = fullfile(baseDir,'disparityData');

% determine the name to be saved

underscoreLocs = strfind(imgNameFull,'_');
imgNumStr = imgNameFull(underscoreLocs(end) + 1:end-4);
disparityDataFileName = ['disparityMap_' sprintf('%2d', avgWin) '_' imgNumStr '.mat'];

% disparityDataFileName = ['disparityMap_' imgNumStr];

disparityDataFileNameFull = fullfile(disparityDir,disparityDataFileName);

load(disparityDataFileNameFull,'dd');

end