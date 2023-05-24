function [IL1, IR1,focalLength,camSep,Q]=rectifyStereoPairOpenCV(stereo_cal_file,left_image_file,right_image_file)
% Use the MEX interface to OpenCV to perform the rectification

load (stereo_cal_file)
IL = (rgb2gray(imread(left_image_file)));
IR = (rgb2gray(imread(right_image_file)));

% set up the struct arrays

S.cameraMatrix1 = KK_left;
S.cameraMatrix2 = KK_right;
S.distCoeffs1 = kc_left;
S.distCoeffs2 = kc_right;
imageSize = [size(IL,2) size(IL,1)];
S.R= R;
S.T = T;


RCT = cv.stereoRectify(S.cameraMatrix1, S.distCoeffs1,...
    S.cameraMatrix2, S.distCoeffs2, imageSize, S.R, S.T,...
    'Alpha',-1);
Q = RCT.Q;
% compute the mappings 
RM = struct('map1',cell(1,2),'map2',cell(1,2));
% it appears that 3.4.1 has eliminated one of the inputs, P1 (or P2)
% just getting rid of the matrix seems OK..
% In the old mexopencv version, new cameara matrix was a required option.
% but now it is a name-value pair, called "newcameraMatrix"
% just deleting the RCT.P1 input made the images too far apart and the
% stereo matching algorithm couldn't operate.
% for some reason 3.4.1 creates much idfferent rectified images than 2.4. I
% will stick with 2.4.
[RM(1).map1, RM(1).map2] = cv.initUndistortRectifyMap(...
    S.cameraMatrix1, S.distCoeffs1, RCT.P1, imageSize,...
    'R', RCT.R1, 'M1Type', 'int16');
% [RM(1).map1, RM(1).map2] = cv.initUndistortRectifyMap(...
%     S.cameraMatrix1, S.distCoeffs1, imageSize,...
%     'R', RCT.R1, 'M1Type', 'int16','NewCameraMatrix',RCT.P1);
[RM(2).map1, RM(2).map2] = cv.initUndistortRectifyMap(...
    S.cameraMatrix2, S.distCoeffs2, RCT.P2, imageSize,...
    'R', RCT.R2, 'M1Type', 'int16');
% [RM(2).map1, RM(2).map2] = cv.initUndistortRectifyMap(...
%     S.cameraMatrix2, S.distCoeffs2, imageSize,...
%     'R', RCT.R2, 'M1Type', 'int16','NewCameraMatrix',RCT.P2);
% apply mappings
    IL1 = cv.remap(IL, RM(1).map1, RM(1).map2);
    IR1 = cv.remap(IR, RM(2).map1, RM(2).map2);
    
% now compute the camera separation and focal lengths
camSep = norm(T);
focalLength = abs(RCT.P1(1,1));

end
    