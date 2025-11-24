function roiMask = loadFijiROIZip(zipFilename, imageSize)
% loadFijiROIZip
% Reads Fiji .roi files from a ZIP and converts them to a labeled mask.
%
% Inputs:
%   zipFilename : string, path to .zip exported from Fiji
%   imageSize   : [H W] size of image the ROIs belong to
%
% Output:
%   roiMask     : HxW labeled mask (0 = background, 1..N = ROIs)

    % Create empty mask
    roiMask = zeros(imageSize);

    % Read zip contents
    z = unzip(zipFilename);
    numROIs = numel(z);

    for i = 1:numROIs
        roi = ReadImageJROI(z{i});   % requires readImageJROI.m
        % ROI coordinates from Fiji are (x,y)
        x = roi.mnCoordinates(:,1);
        y = roi.mnCoordinates(:,2);
        
        BW = poly2mask(x, y, imageSize(1), imageSize(2));

        roiMask(BW) = i;  % assign unique label
    end

    % delete temporary extracted ROI files
    for i = 1:numROIs
        delete(z{i});
    end
end
