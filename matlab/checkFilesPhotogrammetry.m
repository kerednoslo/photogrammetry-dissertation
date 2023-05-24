function [leftEnvImgNames,rightEnvImgNames,calFileNameFull,paramFilenameFull,success]= checkFilesPhotogrammetry(baseDir)
% USAGE: success = checkFilesPhotogrammetry(baseDir)
% The directory, baseDir, must contain pairs of environmental images
% prefixed by CMX, where X is either A or B, followed by the string
% '_matched_', followed by a number. THe A and B camera images are matched
% according to the number. The directory must contain a file called
% 'calibration_results_stereo.mat', which contains the results of the
% stereo calibration process. THe last piece of data is a text file
% containing two parameters, the image_offset, and max_disparity. These two
% parameter are used to set the domain of the correlation process.
% Input: baseDir, the directory in which to check if files exist
% Output: leftEnvImgNames,rightEnvImageNames: Cell arrays containing the
% names of the images.
% calFileNameFull: the full path to the file containing calibration
% information


fileList = dir(baseDir);
% trim . and .. from the file list
if (strcmpi(fileList(1).name,'.') && strcmpi(fileList(2).name,'..'))
    fprintf('. and .. will be stripped from CMA files.\n')
    fileList = fileList(3:end);
end
% find the calibration data;
% Determine if the calibration data exists
fprintf('Looking for file "calibration_results_stereo".\n');

calFileExist = 0;
for ii = 1 : length(fileList)
    currentFile = fileList(ii).name;
    isFound = strfind(currentFile,'calibration_results_stereo');
    if ~isempty(isFound)
        calFileExist = 1;
        fprintf('Calibration file exists.\n');
        break
    end
end

if ~calFileExist
    fprintf('Calibration data not found. Exiting.\n');
    success = 0;
    return
end
% load('calibration_results_stereo.mat');
calFileNameFull = fullfile(baseDir,'calibration_results_stereo.mat');

% load image parameters:
photogrammetryParametersExist = 0;
for ii = 1 : length(fileList)
    currentFile = fileList(ii).name;
    isFound = strfind(currentFile,'photogrammetryParameters');
    if ~isempty(isFound)
        photogrammetryParametersExist = 1;
            fprintf('Photogrammetry parameters found.\n');
        break
    end
end



if ~ photogrammetryParametersExist
    fprintf('File with photogrammetry parameters not found. Exiting.\n');
    success = 0;
    return
end
paramFilenameFull = fullfile(baseDir,'photogrammetryParameters.mat');
% based on the information in the file, determine whether A or B is the
% right or left camera.
load(paramFilenameFull);
if strcmpi(rightCamera,'a')
    rightCameraString = 'CMA';
    leftCameraString = 'CMB';
else
    rightCameraString = 'CMB';
    leftCameraString = 'CMA';
end
% Find the environmental images, load their names into a structure

leftEnvImgNames = cell(1);
rightEnvImgNames = cell(1);

counterL = 1;
counterR = 1;
for ii = 1 : length(fileList);
    currentFile = fileList(ii).name;
    isFound = strfind(currentFile,rightCameraString);
    if ~isempty(isFound)
        rightEnvImgNames{counterR} = currentFile;
        counterR = counterR + 1 ;
    end
    isFound = strfind(currentFile,leftCameraString);
    if ~isempty(isFound)
        leftEnvImgNames{counterL} = currentFile;
        counterL = counterL + 1 ;
    end
    
end
nRightImgFiles = counterR - 1;
nLeftImgFiles = counterL - 1;
% go through both lists of file names and determine if they match or not.

if ~(nRightImgFiles == nLeftImgFiles)
    fprintf('Number of Left and Right Images does not match.\n');
    return
end

for ii = 1 : nRightImgFiles
    underscoreLocs = strfind(leftEnvImgNames{ii},'_');
    leftNumber = int16(str2double(...
        leftEnvImgNames{ii}(underscoreLocs(2)+1:end-4)));
    
    underscoreLocs = strfind(rightEnvImgNames{ii},'_');
    rightNumber = int16(str2double(...
        rightEnvImgNames{ii}(underscoreLocs(2)+1:end-4)));
    leftRightEqual = leftNumber == rightNumber;
    if ~leftRightEqual
        fprintf('The numbers from %s and %s do not match',rightEnvImgNames{ii},leftEnvImgNames{ii});
        success = 0;
        return
    end
    
end

% If everything passes, it succeeds!
success = 1;

end