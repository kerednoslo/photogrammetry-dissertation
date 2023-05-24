function success = saveRectData(baseDir,imgFileName,Il,Ir,X0L,X0R,Y0L,focalLength,camSep,Q) %#ok<INUSD>
% USAGE: success = saveRectData(baseDir,Il,Ir,X0L,X0R,Y0R);
% This function takes the rectified images, along with the parameters and
% saves them in the 'rectifiedData' folder.

% First of all, if the directory does not exist, create it.

rectifiedDataPath = fullfile(baseDir,'rectifiedData');

imgFiles = dir(baseDir);
folderExists = 0;
for ii = 1 : length(imgFiles)
    currentFile = imgFiles(ii).name;
    isFound = strcmp(currentFile,'rectifiedData');
    if isFound
        fprintf('rectifiedData folder exists.\n');
        folderExists = 1;
        break
    end
end

if ~folderExists
    fprintf('rectifiedData folder does not exist, creating')
    mkdir(rectifiedDataPath);
%     success = -2;
%     return
end
% Now that the folder exists, save the data into a file with the correct
% format.
% Strip the leading info from the imgDataFile
underscoreLocs = strfind(imgFileName,'_');
imgFileName = imgFileName(underscoreLocs(end) +1:end-4);


% build rectified data name
rectifiedDataFileName = ['rectifiedImg_' imgFileName '.mat'];
rectifiedDataFileNameFull = fullfile(baseDir,'rectifiedData',rectifiedDataFileName)
save(rectifiedDataFileNameFull,'Il','Ir','X0R','X0L','Y0L','focalLength','camSep','Q')

success = 1;


end