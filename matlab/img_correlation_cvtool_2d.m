function [dd, dd_raw] = img_correlation_cvtool_2d(imgleft, imgright, blockSize, ...
    max_disp,uniqThresh,outlierWindow,outlierThresh,img_offset,img_offset_y,num_steps)

Il16 = uint16(imgleft);
Ir16 = uint16(imgright);
Il16(Il16 == max(Il16(:))) = uint16(0);
Ir16(Ir16 == max(Ir16(:))) = uint16(0);
% convert max_disp to something divisible by 16 so that the CV toolbox
% funtion 'disparity' likes it more.
n16mult = floor(max_disp/16);
max_disp = (n16mult+1) *16;

shiftOffset = img_offset_y;
shifts = (-(num_steps+1)/2:(num_steps+1)/2)+shiftOffset;
d = zeros([size(Il16,1) size(Il16,2) num_steps] , 'single');
df = d;
% shift = 0;
intMult = 16;
% constructor for stereoSGBM
% change for opencv3.4.1. SADWindowSize is no longer an option.
% now it BlockSize
bm = cv.StereoSGBM(...
    'MinDisparity', int32(img_offset+max_disp) , ...
    'NumDisparities', int32(abs(max_disp)) , ...
    'SADWindowSize' , int32(blockSize) , ...
    'Disp12MaxDiff' , int32(-1) , ...
    'UniquenessRatio', int32(uniqThresh) , ...
    'SpeckleWindowSize' , 0 );
for ii = shifts
    if ii>= 0
        Il16offset = Il16(ii +1: end, :);
        Ir16offset = Ir16(1:end-ii,:);
    else
        Il16offset = Il16(1: end+ii, :);
        Ir16offset = Ir16(1-ii:end,:);
    end
    dIndex = ii - shiftOffset+ (num_steps+1)/2+1;
%     dTemp = disparity(Il16offset , ...
%         Ir16offset, ...
%         'ContrastThreshold' ,0.5 , ... % jard-coded at 1/2 (default value anyway).
%         'BlockSize' , blockSize, ...
%         'DisparityRange' , img_offset + [0 max_disp], ...
%         'TextureThreshold' , 00 , ...
%         'UniquenessThreshold' , uniqThresh ...
%         );
    dTemp = bm.compute(im2uint8(Il16offset),im2uint8(Ir16offset));
%     ddInt = int16(dTemp.*intMult);
    dTemp(dTemp(:) < img_offset*intMult) = -1;
    dFilt = cv.filterSpeckles(dTemp , -1 , outlierWindow ,  intMult);

    d(1:size(dTemp,1) , 1:size(dTemp,2) , dIndex) = dTemp;
    df(1:size(dTemp,1) , 1:size(dTemp,2) , dIndex) = dFilt;
end

dd_raw = single(d)/intMult;
dnan = single(df)/intMult;

fprintf('Removing Outliers for each shift in the vertical direction.\n')
fprintf('This will take a while.\n')

dnan(dnan(:) > img_offset + max_disp-16) = NaN;
dnan(dnan(:)< 0 ) = NaN;
dnan = nanmedian(dnan , 3);
dnan(:,1:img_offset) = NaN;

% dmed = nanmedian(dnan,3);
% dmed(isnan(dmed(:))) = -realmax('single');

% dfilt = medfilt2(dmed , [outlierWindow outlierWindow]);

% outliers = abs(dfilt(:) - dmed(:)) > outlierThresh;

% dmed(outliers) = NaN;
% dmed(dmed(:) == -realmax('single')) = NaN;
% dd = dmed;

% dd = single(ddFilt)./intMult;
dd = dnan;
% dd(dd(:) < 0) = NaN;
% dd(dd(:) > img_offset + max_disp - 16) = NaN;
dd(Il16(:) == 0) = nan;
dd(Ir16(:) == 0) = nan;

% for ii = 1:num_steps
%     filteredIm = medfilt2(d(:,:,ii) , [outlierWindow outlierWindow]);
%     outlierMask = abs(filteredIm - d(:,:,ii)) > outlierThresh;
%     dTemp = d(:,:,ii);
%     dTemp(outlierMask) = NaN;
%     dnan(:,:,ii) = dTemp;
% 
% end
% dd_raw = dnan;
% dd = nanmedian(dnan , 3);
% dd(dd(:) == -realmax('single')) = NaN;
% dd(dd(:) > img_offset + max_disp-16) = NaN;
