function [X,Y,Z,Xc,Yc,Zc,fitParams,status] = convertDisparityToHeightOpenCV(numPointsX,numPointsY,disparityMap,focalLength,camSep,Q)
% USAGE: status = convertDisparityToHeight()
% Uses the output from the correlator to convert disparity map to height
% Needed inputs: Il (just for image sizes)
%               X0R,X0L for image axes (what units? pixels probably)
%               dd  from correlator
%               av, d (from calibration)

% FOr now, set undersamp = 1, later use it as an input for the parameters

% Trimming the image changes the number of pixels
% ny1 = size(Il,1);
% nx1 = size(Il,2);
% [numPointsY,numPointsX] = size(disparityMap);

% hack!
% Define the disparity map coordinates in pixels
% numPointsX = numPointsX;
% numPointsY = numPointsY;
% disparity
dmap_X = (-(numPointsX-1)/2:(numPointsX-1)/2);
dmap_Y = (-(numPointsY-1)/2:(numPointsY-1)/2); %Y0L is always zero.
% ix=(-(nx1-1)/2:(nx1-1)/2)+X0R;  %image axes
% iy=(-(ny1-1)/2:(ny1-1)/2)+Y0L;
% TODO: figure out how to integrate undersampling into the code
% dmap_X = dmap_X .* undersamp;
% dmap_Y = dmap_Y .* undersamp;
numPointsX=size(dmap_X,2);  %number of pixels in the disparity image
numPointsY=size(dmap_Y,2);

%create position vectors for all points in the disparity image
%(homogeneou=7r coordinates)
[dmapGrid_X,dmapGrid_Y]=meshgrid(dmap_X,dmap_Y);
dmapGrid_X=reshape(dmapGrid_X,1,numPointsX*numPointsY);
dmapGrid_Y=reshape(dmapGrid_Y,1,numPointsX*numPointsY);
I=ones(1,numPointsX*numPointsY);
%accounts for undersampling in correlation stage
% disparityMap = disparityMap;
% disparityMap = reshape(disparityMap,1,numPointsX*numPointsY);
% TODO: find a better name than xp for this variable
% xp=double([dmapGrid_X;dmapGrid_Y;disparityMap;I]); 


% clear dmapGrid_X dmapGrid_Y dmap_X dmap_Y disparityMap;
% for explaination and figures, see "principles of photogrammetry, chapter
% 10" (freely available on the net, and Wong, basic Mathematics of
% Photogrammetry, in "Manual of Photogrammetry, 4th ed.

% transformationMatrix= [1 0 0 0;
%                        0 1 0 0;
%                        0 0 0 focalLength;
%                        0 0 1/camSep 0];
transformationMatrix = Q;
% xformedCoord=transformationMatrix*xp;
% heightFieldRaw = xformedCoord(1:3,:)./([1 1 1]'*xformedCoord(4,:));  %transformed coordinates (from image to seafloor); i.e. xnew is the height field
heightFieldRaw = cv.reprojectImageTo3D(-disparityMap , Q);
xp = reshape(heightFieldRaw(:,:,1),[numPointsY numPointsX]);
yp = reshape(heightFieldRaw(:,:,2),[numPointsY numPointsX]);
zp = reshape(heightFieldRaw(:,:,3),[numPointsY numPointsX]);
heightFieldRaw = [xp(:).' ; yp(:).' ; zp(:).']; 
%z=focallength(pixels)/disparity(pixels)*cameraseparation(SI units)
%-->see Wong, Math. of Photogrammetry
%x=imagex(pixels)/focallength(pixels)*z(SI units)
%y=imagey(pixels)/focallength(pixels)*z(SI units)

%Regrid the height field

% DO: Mark takes the center 100x100 x-coordinates from the image , then takes the
% same data moved over by one pixel. The difference between these
% x-coordinate chunks gives a delta_x for each sample. The mean of these is
% used to compute the "true" delta_x, which is the basis for regridding the
% image.
xCoords =xp;
xCoords(isinf(xCoords(:))) = NaN;
xSlice = nanmean(xCoords,1);
xslNanInds = isnan(xSlice);
xT = dmap_X;
xSlice = xSlice(~xslNanInds);
xSlInfInds = isinf(xSlice);
xT = xT(~xslNanInds);
% perform a linear fit to the data without nans.
px = polyfitn(xT , xSlice ,1);

deltax = px.Coefficients(1);
deltaxErr = px.ParameterStd(1);


yCoords = yp;
yCoords(isinf(yCoords(:))) = NaN;
ySlice = nanmean(yCoords,2);
yslNanInds = isnan(ySlice);
yT = dmap_Y;
ySlice = ySlice(~yslNanInds);
yT = yT(~yslNanInds);

py = polyfitn(yT(:) , ySlice(:) , 1);

deltay = py.Coefficients(1);
deltayErr = py.ParameterStd(1);

fitParams.px = px;
fitParams.py = py;

% numPointsForGrid = 500;
% deltaX_grid=  xCoords(fix(numPointsY/2)+(-50:50),fix(numPointsX/2)+(-50:50))...
%     -xCoords(fix(numPointsY/2)+(-50:50),fix(numPointsX/2)+(-51:49));
% deltaX_grid=  xCoords(fix(numPointsY/2)+(-numPointsForGrid:numPointsForGrid),fix(numPointsX/2)+(-numPointsForGrid:numPointsForGrid))...
%     -xCoords(fix(numPointsY/2)+(-numPointsForGrid:numPointsForGrid),fix(numPointsX/2)+(-numPointsForGrid-1:numPointsForGrid-1));
% MN: this is an average value of the distance between x and y coordinates; it is used to determine pixel size for regridding
% deltax = abs(mean(deltaX_grid(~isnan(deltaX_grid(:)))));
fprintf('delta X is %2.2f +/- %2.4f microns.\n' , deltax*1000,deltaxErr*1000);
fprintf('delta Y is %2.2f +/- %2.4f microns.\n' , deltay*1000,deltayErr*1000);

clear xCoords deltaX_grid deltaY_grid;
% clear xn xp

% remove NaN values from data set
% field_length=size(heightFieldRaw(1,:),2);
% xnew2 = zeros( 3, field_length, 'single' );
% count = 0;
% Remove NaN and truncate
% heightFieldCleaned = nan(size(heightFieldRaw));
% numNonNans = numPointsX;
% notNanCounter = 0;

%  remove anything in x or y that's outside the viewing area. Sometimes
%  outliers in the disparity map can put one point outside where we took
%  data. This problem can be solved through cropping, but it does make the
%  interpolation more difficult.

% Automatically crop the area. Assume that the x and y positions are
% uniformely distributed (For things that ar nominally planar, this should
% be a decent assumption). FInd the empirical cdf (which for a uniform
% distributions should be linear). The edges of the distribution occur when
% the CDF intersects Y = 0 and Y= 1 respectifly. Use the center of the cdf
% to fit a linear function, then solve for their intersection with 0 and
% 1. These intersections should give a good estimate of where the majority
% of the information is. Hopefully I won't have to crop it.
heightFieldRaw(1,isinf(heightFieldRaw(1,:))) = NaN;
heightFieldRaw(2,isinf(heightFieldRaw(2,:))) = NaN;
xMean = nanmean(heightFieldRaw(1,:));
yMean = nanmean(heightFieldRaw(2,:));

xC = heightFieldRaw(1,:);
yC = heightFieldRaw(2,:);
xC = xC(~isnan(xC));
yC = yC(~isnan(yC));

[fx,xx] = ecdf(xC);
[fy,xy] = ecdf(yC);

xFitLims = 2000*deltax/2;
yFitLims = 2000*deltay/2;
xxfit = xx(abs(xx - xMean) < xFitLims);
xyfit = xy(abs(xy - yMean) < yFitLims);
% [fx,xx] = ecdf(xC(abs(xC - yMean) < yFitLims

fxfit = fx(abs(xx - xMean) < xFitLims);
fyfit = fy(abs(xy - yMean) < yFitLims);
px = polyfit(xxfit,fxfit,1);
py = polyfit(xyfit , fyfit,1);
% maxXerr =  max(abs(fxfit - polyval(px , xxfit)));

% undershoot by 30 points. This cuts out some, but it should be fine. This
% translates to cutting out about 3 mm per edge.
xEdges = [(-px(2)./px(1)+30*deltax) ((1-px(2))./px(1)-30*deltax)];
yEdges = [(-py(2)./py(1)+30*deltay) ((1-py(2))./py(1)-30*deltay)];
% recompute.


% % if camSep < 750
%     % then we're in Tall mode
%     xEdges = xMean + [-160 160];
%     yEdges = yMean + [-160 160];
% else
%     xEdges = xMean + 2*[-170 170];
%     yEdges = yMean + 2*[-170 170];
% end

outsideX = (heightFieldRaw(1,:) > xEdges(2)) | (heightFieldRaw(1,:) < xEdges(1));
outsideY = (heightFieldRaw(2,:) > yEdges(2)) | (heightFieldRaw(2,:) < yEdges(1));


nanInds = isnan(heightFieldRaw(3,:));
infInds = isinf(heightFieldRaw(3,:));
disallowedInds = (nanInds | infInds | outsideX | outsideY);
heightFieldCleaned = heightFieldRaw(:,~disallowedInds);

%create new axes for regridding
% DO: this notation is terrible.
xMin = min(heightFieldCleaned(1,:));
xMax = max(heightFieldCleaned(1,:));

yMin = min(heightFieldCleaned(2,:));
yMax = max(heightFieldCleaned(2,:));

% s=min(xnew2(1,:));
% s1=max(xnew2(1,:));
% s2=min(xnew2(2,:));
% s3=max(xnew2(2,:));

% Define a new grid for the regularly sampled image
xReg = xMin:deltax:xMax;
yReg = yMin:deltay:yMax;

% xx=s:deltax:s1;
% yy=s2:deltax:s3;
%number of pixels for the new grid
numPointsXReg =size(xReg,2);
numPointsYReg =size(yReg,2);
% nyy=size(yy,2);
[xRegGrid,yRegGrid]=meshgrid(xReg,yReg);
% xres=[X;Y];
% clear ext Pnl z0 id torectify nx1 ny1 nx ny Q
% clear s s1 s2 s3 xx yy rot ZI ZZ
% clear FM matches A1 b ab med ran idx A

% MN used griddata to interplate. Matlab suggest using the updated
% TriScatteredInterp class.

% Create an interpolant.

% interpolant = TriScatteredInterp(double(heightFieldCleaned(1,:)).',...
%     double(heightFieldCleaned(2,:)).',double(heightFieldCleaned(3,:)).');
% evaluate the interpolant on the regular grid.

% heightMapFinal = interpolant(double(xRegGrid),double(yRegGrid));
heightMapFinal = griddata( double(heightFieldCleaned(1,:)).',...
    double(heightFieldCleaned(2,:)).',- double(heightFieldCleaned(3,:)).',...
    double(xRegGrid),double(yRegGrid),'natural');
% ZI=griddata(double(xnew2(1,:)),double(xnew2(2,:)),double(xnew2(3,:)),double(xres(1,:)),double(xres(2,:)));  %regrid by calling an executable similar to griddata.m called griddata.exe
% heightMapFinal = reshape(heightMapFinal,numPointsXReg,numPointsYReg);

X = xReg;
Y = yReg;
Z = heightMapFinal;

% get rid of NaNs in the most humane way possible:
nanZ = isnan(Z);

numNans = sum(nanZ(:));

% zExtrap = griddata(X , Y , Z , 

% GET RID OF columns and rows that are mostly nan;

% nanC = all(logical(isnan(Z)) , 2);
% nanR = all(logical(isnan(Z)) , 1);
nanR = sum(nanZ , 1) > size(Z,1)/4;
nanC = sum(nanZ , 2) > size(Z,2)/4;
Zc1 = Z(~nanC , ~nanR);
Xc1 = X(~nanR);
Yc1 = Y(~nanC);

% first crop in direction with the fewest number of nans
nanZ = isnan(Zc1);
inZ = logical(~nanZ);
fprintf('Searching for largest rectangle to crop using slow code.\n');
fprintf('This very inefficient search will take ~10 min.\n')

[~,~,~,M] = FindLargestRectangles(inZ,[0 0 1],[500 500]);

% [maxVal maxInd] = max(C(:));
% [row col] = find(C == maxVal)
% [start1 start2] = ind2sub(size(C) , maxInd);
% 
% stop2 = start2 + W(start1,start2);
% stop1 = start1 + H(start1,start2);
dim1Mask = any(M,2);
dim2Mask = any(M,1);
Zc = Zc1(dim1Mask,dim2Mask);
Xc = Xc1( dim2Mask);
Yc = Yc1( dim1Mask);

% sear

% nanR = sum(nanZ, 1);
% nanC = sum(nanZ, 2);
% 
% numNanR = sum(nanR);
% numNanC = sum(nanC);
% % take care of the dimension with the least amount of nans first
% if numNanR > numNanC
%     Zcc = Zc(~nanC , :);
%     % then take care of the other dimension
%     nanR = any(isnan(Zcc),1);
%     Zcc = Zcc(: , ~nanR);
% else
%     Zcc = Zc(:, ~nanR);
%     % then take care of the other dimension
%     nanC = any(isnan(Zcc),2);
% %     poo
%     Zcc = Zcc(~nanC,:);
% end
% 
% % imagesc(Zcc)
% finalNumNans = sum(isnan(Zcc(:)));
% fprintf('There are now %02d NaNs in the height field.\n',finalNumNans)
% Zc = Zcc;
% 
% Xc = X(1:size(Zcc,2));
% Yc = Y(1:size(Zcc,1));

status = 1;
end


