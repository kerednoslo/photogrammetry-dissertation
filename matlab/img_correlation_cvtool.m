function [dd, dd_raw] = img_correlation_cvtool(imgleft, imgright, blockSize, ...
    max_disp,uniqThresh,outlierWindow,outlierThresh,img_offset)

Il16 = uint16(imgleft);
Ir16 = uint16(imgright);
Il16(Il16 == max(Il16(:))) = uint16(0);
Ir16(Ir16 == max(Ir16(:))) = uint16(0);
% convert max_disp to something divisible by 16 so that the CV toolbox
% funtion 'disparity' likes it more.
n16mult = floor(max_disp/16);
max_disp = (n16mult+1) *16;

dd = disparity(Il16 , ...
    Ir16, ...
    'ContrastThreshold' ,0.5 , ...
    'BlockSize' , blockSize, ...
    'DisparityRange' , img_offset + [0 max_disp], ...
    'TextureThreshold' , 00 , ...
    'UniquenessThreshold' , uniqThresh ...
    );
dd_raw = dd;


% remove outliers?
fprintf('Removing Outliers\n')
% owSize = [outlierWindow outlierWindow];

% filter with a 2d median filter, then look at differences
% dFilt = medfilt2(dd , owSize);
intMult = 16;
ddInt = int16(dd_raw.*intMult);
ddFilt = cv.filterSpeckles(ddInt , -1 , outlierWindow ,  intMult);
% dFilt2 = pseudoMedianFilter2(dd , outlierWindow);
% outlierMask = logical(abs(dd - dFilt) > outlierThresh);
% dd(outlierMask) = NaN;
dd = single(ddFilt)./intMult;
dd(dd(:) < 0) = NaN;
dd(dd(:) > img_offset + max_disp - 16) = NaN;
dd(Il16(:) == 0) = nan;
dd(Ir16(:) == 0) = nan;


