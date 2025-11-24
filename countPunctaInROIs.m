function punctaCounts = countPunctaInROIs(image2D, roiMask)
% countPunctaInROIs
% Counts puncta inside each ROI using thresholding + connected components.
%
% INPUTS:
%   image2D  - 2D grayscale image (double or uint)
%   roiMask  - Labeled ROI mask: same size as image2D.
%              Pixels = 0 are background.
%              Pixels = 1,2,3,... are region IDs.
%   thresh   - Pixel intensity threshold for puncta (scalar)
%
% OUTPUT:
%   punctaCounts - struct with fields:
%       .counts     -> number of puncta per ROI
%       .totalPuncta -> total puncta in image
%       .centroids   -> puncta centroid coordinates
%       .labels      -> which ROI each punctum belongs to
%
% EXAMPLE:
%   thresh = max(fitGaussianMixtureToImage('myfile.tif',2,false));
%   counts = countPunctaInROIs(channel2, roiMask, thresh);


    se = strel('disk', 3);                  % smooth by creating small disks over each high point (puncta size)
    bw2 = imopen(image2D, se);            % create bw image over smoothed points
    B = imextendedmax(bw2, 0.015);

    CC = bwconncomp(B, 8);
    stats = regionprops(CC, 'Centroid');

    numPuncta = CC.NumObjects;

    % Centroid list (Nx2)
    centroids = vertcat(stats.Centroid);

    % --------- 3. Determine which ROI each punctum belongs to ---------
    roiLabels = zeros(numPuncta,1);

    for i = 1:numPuncta
        x = round(centroids(i,1));
        y = round(centroids(i,2));

        % bound safety
        if x >= 1 && x <= size(roiMask,2) && ...
           y >= 1 && y <= size(roiMask,1)
            roiLabels(i) = roiMask(y,x);
        end
    end

    % Only count puncta inside labeled ROIs (label > 0)
    validPuncta = roiLabels > 0;

    roiLabels = roiLabels(validPuncta);

    % --------- 4. Count puncta per ROI ---------
    maxROI = max(roiMask(:));
    counts = zeros(maxROI,1);

    for r = 1:maxROI
        counts(r) = sum(roiLabels == r);
    end

    % --------- 5. Return structured output ---------
    punctaCounts.punctaCounts = counts;
    punctaCounts.totalPuncta = sum(counts);
    punctaCounts.centroids = centroids(validPuncta,:);
    punctaCounts.labels = roiLabels;
end
