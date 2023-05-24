function saveCorrelationStatus = saveCorrelationResults_cvtool(baseDir,imgFileName,dd,dd_raw,avgWin) %#ok<INUSD>
% USAGE: saveCorrelationStatus = saveCorrelationResults(baseDir,old_dd, costmap,pcost,dd,dd_raw)
%
% This function saves the output of the correlation function in the
% directory 'correlationData'. I don't care if there's already data, so
% overwriting is not a problem.


disparityDataPath = fullfile(baseDir,'disparityData');

imgFiles = dir(baseDir);
folderExists = 0;
for ii = 1 : length(imgFiles)
    currentFile = imgFiles(ii).name;
    isFound = strcmp(currentFile,'disparityData');
    if isFound
        fprintf('disparityData folder exists.\n');
        folderExists = 1;
        break
    end
end

if ~folderExists
    fprintf('disparityData folder does not exist, creating')
    mkdir(disparityDataPath);
%     success = -2;
%     return
end
% Now that the folder exists, save the data into a file with the correct
% format.
% Strip the leading info from the imgDataFile
underscoreLocs = strfind(imgFileName,'_');
imgFileName = imgFileName(underscoreLocs(end) +1:end-4);

% build rectified data name
disparityDataFileName = ['disparityMap_' sprintf('%2d', avgWin) '_' imgFileName '.mat'];
disparityDataFileNameFull = fullfile(disparityDataPath,disparityDataFileName);
% Don't care if the data exists or not
save(disparityDataFileNameFull,'dd','dd_raw')

saveCorrelationStatus = 1;

end