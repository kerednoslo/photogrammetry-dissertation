function status = saveHeightField(baseDir,imageFileName,X,Y,Z,Xc,Yc,Zc,fitParams,winSize) %#ok<INUSD>
%
%USAGE: status = saveHeightMap(X,Y,Z);
% THis function saves the heightmap in the heightData directory

heightDataDir = fullfile(baseDir,'heightData');
if ~exist(heightDataDir , 'file')
    mkdir(heightDataDir)
end
underscoreLocs = strfind(imageFileName,'_');
imageFileName = imageFileName(underscoreLocs(end):end - 4);

heightDataFileName = ['heightData_' imageFileName '_blockSize_' sprintf('%02d', winSize)];

heightDataFileNameFull = fullfile(heightDataDir,heightDataFileName);

save(heightDataFileNameFull,'X','Y','Z','fitParams');
save([heightDataFileNameFull '_cropped'],'Xc','Yc','Zc','fitParams');
status = 1;
% meanZ = mean(-Z(:));
% stdZ = std(-Z(:));
underscoreLocs = strfind(imageFileName , '_');
if ~isempty(underscoreLocs)
    imageFileName(underscoreLocs) = [];
end
h = figure(1);
set(gcf,'Visible','off');
clf
imagesc(X , Y , Z);
% axis ij
xlabel('X [mm]')
ylabel('Y [mm]');
title(['Height Field [mm]  ' imageFileName])
colorbar
colormap(jet(2^10))
% caxis(meanZ +2.*[stdZ - stdZ])
fixfig(h)
print(h,'-dpng' , heightDataFileNameFull)

figure(1)
set(gcf,'Visible','off');
clf
imagesc(Xc , Yc , Zc);
xlabel('X [mm]')
ylabel('Y [mm]');
title(['Height Field cropped [mm]  ' imageFileName])
colorbar
colormap(jet(2^10))
% caxis(meanZ +2.*[stdZ - stdZ])
fixfig(h)
print(h,'-dpng' , [heightDataFileNameFull '_cropped']);

end