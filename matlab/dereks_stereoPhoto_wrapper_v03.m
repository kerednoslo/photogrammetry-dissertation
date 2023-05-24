% Derek Olson
% 12 Aug, 2013
% Wrapper for the stereophotogrammetry engine.
% baseDir = '/run/media/derek/Seagate Backup Plus Drive/NORGEX13/NORGEX13/2013-05-09-langeby_test/test_folder';
% baseDir = '/run/media/derek/Seagate Backup Plus Drive/NORGEX13/NORGEX13/2013-05-09-langeby_test/test_folder_4ft';
% baseDir = '/run/media/derek/Seagate Backup Plus Drive/NORGEX13/NORGEX13/2013-05-09-langeby_test/test_folder_4ft_skew';
% baseDir = '/home/derek/Documents/psu/acs/research/photogrammetry/test_folder_4ft_skew';
% baseDir = '/home/derek/Documents/MATLAB/photogrammetry/images/test_8ft';
baseDir  = '/run/media/derek/DRO_DISS/NORGEX13/test_folder_8ft';
% baseDir = '/run/media/derek/DRO_DISS/NORGEX13/loc05/loc05_8ft';
processingFlags = struct;
processingFlags.reRectify = 0;
processingFlags.reCorrelate = 0;
processingFlags.computeHeightField = 1;
%% Run the Engine

status = stereophotogrammetryEngineOpenCV(baseDir,processingFlags);
%% make sure Brian has all dependencies
target_dir = '/Users/derekolsonnn/src/stereo-photogrammetry/matlab';
[fList,pList] = matlab.codetools.requiredFilesAndProducts('dereks_stereoPhoto_wrapper_v03.m');
% 