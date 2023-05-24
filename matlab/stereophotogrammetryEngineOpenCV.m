function out = stereophotogrammetryEngineOpenCV(baseDir,processingFlags)
%
% USAGE: out = stereophotogrammetryEngine(baseDir)
% This function is the main processor for Derek's Stereophotogrammetry. It
% was adapted from Gaetano Cannepa's code, which was rewritten by Tony
% Gerig, which was in turn rewritten by Mark Noonchester.
% Inputs:
%    baseDir - the directory containing images, phtogrammetry parameters, and
%      calibration information
%    processingFlags - a struct with fields containing processing flags
%      fields:
%           reRectify - if there is saved rectification data, 1 means
%           recalculate it, 0 means do not recalculate
%           reCorrelate - if there is saved correlation results 1 means
%           recompute, 0 means do not recompute correlation.
%           

% Unpack structure
reRectify = processingFlags.reRectify;
reCorrelate = processingFlags.reCorrelate;
computeHeightField = processingFlags.computeHeightField;
% if reRectify ==1, then we MUST run the correlation again. 
if reRectify == 1
    reCorrelate = 1;
end

% create a list of the directory's contents;

[leftEnvImgNames,rightEnvImgNames,calFileNameFull...
    ,paramFilenameFull,success] = checkFilesPhotogrammetry(baseDir);
if ~success
    fprintf('checkFilesPhotogrammetry Has failed. See warnings from that file.\n');
    out = 0;
    return
end

nRightImgFiles = length(rightEnvImgNames);
baseDir2 = baseDir;

load(paramFilenameFull);
baseDir = baseDir2;
if ~exist('img_offset_y' , 'var')
    img_offset_y = 0;
end
if ~exist('uniqThresh' , 'var')
    uniqThresh = 0;
end

if ~exist('use2d' ,'var')
    use2d = 0;
end


% all the files are there. Now loop through and perform some quackulations.
        
for ii = 1 : nRightImgFiles
    
    imgNameFullL = fullfile(baseDir,leftEnvImgNames{ii});
    imgNameFullR = fullfile(baseDir,rightEnvImgNames{ii});
    
    % check for saved rectified data
    rectFileStatus = checkForSavedRectifiedData(baseDir,imgNameFullL);
   
    if (rectFileStatus <1) || ((rectFileStatus ==1) && (reRectify == 1))
%         directory does not exist. run rectification function and save for later 
    
%         [Il,Ir,X0L,X0R,Y0L,focalLength,camSep] = rectifyStereoPair(...
%             calFileNameFull, imgNameFullL,imgNameFullR,img_offset,img_offset,img_offset_y);
% Note that these images are switched!  
[Il,Ir,focalLength,camSep,Q] = rectifyStereoPairOpenCV(...
            calFileNameFull, imgNameFullL,imgNameFullR);
        
        saveRectStatus = saveRectData(...
            baseDir,imgNameFullL,Il,Ir,img_offset,img_offset,0,focalLength,camSep,Q);
    elseif (rectFileStatus ==1) && (reRectify == 0)
        [Il,Ir,X0L,X0R,Y0L,focalLength,camSep,Q] = loadRectData(...
            baseDir,imgNameFullL);
    end
%     bufferFudge = 0;
%     Il = Il(1:end-bufferFudge,:);
%     Ir = Ir(1+bufferFudge:end,:);
    [numPointsY , numPointsX] = size(Il);
%     if exist('img_offset_y' , 'var')
%         if (img_offset_y ~=0)
%         % shift the right image by im_offset_y;
%          t = Il;
%         Il = zeros(size(t));
%         Il(1:size(t,1) - img_offset_y+1 ,:) = t(img_offset_y:size(t,1) ,:);
%         Il = uint16(Il);
%         end
%     end
    
%     req_qual = 0.1;
    % Check if folder exists
     for iii = 1 : length(avg_window_size);
    fileExists = checkForSavedCorrelationResults(baseDir,imgNameFullL,avg_window_size(iii));
    
    if (~fileExists) || (fileExists && reCorrelate)
        fprintf('Begin Correlation.\n');
        if ~use2d
            [dd, dd_raw] = img_correlation_cvtool(...
                Il, Ir, avg_window_size(iii)...
                , max_disp, uniqThresh , outlier_win_size(iii),outlierThresh,img_offset);
        else
            [dd, dd_raw] = img_correlation_cvtool_2d(...
                Il, Ir, avg_window_size(iii)...
                , max_disp, uniqThresh , outlier_win_size(iii),...
                outlierThresh,img_offset,img_offset_y,num_steps_y);
        end
        
        saveCorrelationStatus = saveCorrelationResults_cvtool(...
             baseDir,imgNameFullL,dd,dd_raw,avg_window_size(iii));

    
    elseif fileExists && ~reCorrelate
%         % load in the saved data
        fprintf('Saved data exists, and recalculation is not necessary.\n');
        fprintf('Loading in saved correlation data.\n');
        [dd] = loadDisparityData(baseDir,imgNameFullL,avg_window_size(iii));
%         
    end
    
    % Save the correlation results, for future post-processing, or you
    % wanted to see the correlation.
    if computeHeightField

        fprintf('Correlation Finished. Converting disparity map into height.\n');
        if img_offset > 0
             dd(dd(:) < img_offset +1) = NaN;
        else
             dd(dd(:) > img_offset +1) = NaN;
             dd(dd(:) < img_offset+max_disp) = NaN;
        end
        
        % Convert Disparity map to height
        [X,Y,Z,Xc,Yc,Zc,fitParams,status] = convertDisparityToHeightOpenCV(numPointsX,numPointsY,dd,focalLength,camSep,Q);
        if ~status
            fprintf('Error Converting Disparity to Height. Check internals of convertDisparityToHeight.m.\n');
        end
        fprintf(['Height Field Computed for ' leftEnvImgNames{ii} '.\n']);
    %
        % save disparity map
        status = saveHeightField(baseDir,imgNameFullL,X,Y,Z,Xc,Yc,Zc,fitParams,avg_window_size(iii));
        
        fprintf('Saved Data and png.\n');
    else
        disp('Not Computing Height Field')
    end
    end
end

% out = status;
out = 1;
end