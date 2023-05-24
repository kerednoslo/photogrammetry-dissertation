function fileExists = checkForSavedCorrelationResults(baseDir,imgNameFullL,avgWin)
%
% USAGE: fileExists = checkForSavedCorrelationResults(baseDir,imgNameFullL)
% THis function checks to see if the correlation data has already been
% saved or not.
correlationDataPath = fullfile(baseDir,'disparityData');

correlationFiles = dir(correlationDataPath);

% strip . and .. from the struct
if isempty(correlationFiles)
    fileExists = 0;
    return
end
% disparityDataFileName = ['disparityMap_' sprintf('%2d', avgWin) '_' imgFileName '.mat'];

if (strcmpi(correlationFiles(1).name,'.') && strcmpi(correlationFiles(2).name,'..'))
    correlationFiles = correlationFiles(3:end);
end

underscoreLocs = strfind(imgNameFullL,'_');
imgNumberString = imgNameFullL(underscoreLocs(end) +1:end-4);
imgNumberString = [sprintf('%2d', avgWin) '_' imgNumberString];
isMatched = 0;
fileExists = 0;
for ii = 1 : length(correlationFiles)
    currentFile  = correlationFiles(ii).name;
    underscoreLocs = strfind(currentFile , '_');
    if ~isempty(underscoreLocs)
        correlationFileName = currentFile(underscoreLocs(1)+1 : end -4);
    
    
        isMatched = strcmp(correlationFileName, imgNumberString);

        if isMatched
            fileExists = 1;
            break
        end
    end
end
% if nothing found


end

    

