function brightPixelCounts = countPunctaAreaInROIs(image2D, roiMask, thresh)
% countBrightPixelsInROIs
% Counts the number of bright pixels inside each ROI.
%
% INPUTS:
%   image2D  - 2D grayscale image (double or uint)
%   roiMask  - Labeled ROI mask: same size as image2D.
%              Pixels = 0 are background.
%              Pixels = 1,2,3,... are region IDs.
%   thresh   - Pixel intensity threshold for bright pixels (scalar)
%
% OUTPUT:
%   brightPixelCounts - struct with fields:
%       .counts     -> number of bright pixels per ROI
%       .totalBright -> total bright pixels in image

    % --------- 1. Threshold the image ---------
    bw = image2D > thresh;

    % Optional: remove small noise pixels
    bw = bwareaopen(bw, 3);

    % --------- 2. Count bright pixels per ROI ---------
    maxROI = max(roiMask(:));
    counts = zeros(maxROI,1);

    for r = 1:maxROI
        counts(r) = sum(bw(roiMask == r));
    end

    % --------- 3. Return structured output ---------
    brightPixelCounts.counts = counts;
    brightPixelCounts.bw = bw;
end
