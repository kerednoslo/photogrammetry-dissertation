function success = checkForSavedRectifiedData(baseDir,imageFileName)
%
% USAGE: success = checkForSavedRectifiedData(baseDir);
% This function checks for a directory in the same containing directory as
% baseDir, called 'rectifiedData'. If it exists, then it imports
% output: status:
%      -2 directory does not exist
%      -1 directory exists but is empty (save for .. and .);
%       0 directory exists but the specified file is not there
%       1 directory exists and the rectified imagery file exists. 

% Check for a trailing filesep


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
    fprintf('rectifiedData folder does not exist')
    success = -2;
    return
end

% The Folder exists, now determine if the name of the filename in the
% rectified folder match the names of the image files.

rectifiedFiles = dir(rectifiedDataPath);
if length(rectifiedFiles) == 2;
    fprintf('No files in this folder.\n')
    success = -1;
    return
end

% Now there are files in the folder, but we don't know if it contains the
% file we need.
% strip the prefix 'CMX' from the image file name

underscoreLocs = strfind(imageFileName,'_');
imageFileName = imageFileName(underscoreLocs(end)+1:end-4);

if (strcmpi(rectifiedFiles(1).name,'.') && strcmpi(rectifiedFiles(2).name,'..'))
    fprintf('. and .. will be stripped from rectifiedFiles.\n')
    rectifiedFiles = rectifiedFiles(3:end);
end

fileExists = 0;
% Strip leading name and file extension and compare the number strings
for ii = 1 : length(rectifiedFiles)
    currentFile = rectifiedFiles(ii).name;
    rectifiedNumberString = currentFile(14:end-4);
    fileExists = strcmp(rectifiedNumberString,imageFileName);
    if fileExists

        break
    end
end

if ~fileExists
    success = 0;
else
    success = 1;
end

end