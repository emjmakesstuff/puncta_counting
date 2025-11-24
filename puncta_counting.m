%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- Puncta Counting Program --- %%
% EmJ Rennich 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Requirements:
%   - Fiji installed with Bio-Formats
%   - MIJ.jar and ij.jar on MATLAB path
%   - ReadImageJROI downloaded

clear all; close all;

% Load files
zipPath = '101_A4_fov5_20x__2025_09__RGB_maxproj_rois.zip';
tifPath = 'MAX_101_A4_fov5_20x__2025_09_30__15_11_46.tif';

info = imfinfo(tifPath);
numFrames = numel(info);

stack = zeros(info(1).Height, info(1).Width, numFrames, 'uint16');
for k = 1:numFrames
    stack(:,:,k) = imread(tifPath, k);
end

% Extract channel 2 (adjust if your stack is 3D)
channel2 = stack(:,:,2);

% Build ROI mask
roiMask = loadFijiROIZip(zipPath, size(channel2));

% Compute GMM threshold
mu = fitGaussianMixtureToImage('MAX_101_A4_fov5_20x__2025_09_30__15_11_46.tif', 2, false);
thresh = max(mu);

% Count puncta inside those ROIs
counts = countPunctaInROIs(channel2, roiMask);
punctaAreas = countPunctaAreaInROIs(channel2, roiMask, thresh);
counts.punctaAreas = punctaAreas.counts;
counts.totalArea = punctaAreas.bw;

% Convert puncta area from pixels to um
xRes = info(1).XResolution;
yRes = info(1).YResolution;
pixelArea = xRes * yRes;  % µm² per pixel
counts.punctaAreas = counts.punctaAreas .* pixelArea;

%% ---- Plot ROIs + puncta count overlay ---- %%
figure;
imshow(channel2, [], 'InitialMagnification', 'fit'); 
hold on;

% --- ROI overlay ---
roiRGB = label2rgb(roiMask, 'jet', 'k', 'shuffle');
h = imshow(roiRGB);
set(h, 'AlphaData', 0.25);   % Transparency so image shows underneath

% --- ROI boundaries (optional but very useful for visual QC) ---
boundaries = bwboundaries(roiMask > 0);
for b = 1:length(boundaries)
    boundary = boundaries{b};
    plot(boundary(:,2), boundary(:,1), 'w-', 'LineWidth', 1.5);
end

% --- Puncta markers ---
if ~isempty(counts.centroids)
    plot(counts.centroids(:,1), counts.centroids(:,2), 'r.', 'MarkerSize', 2);
end

title('ROIs + boundaries + puncta centroids');
hold off;

%% ---- Plot ROIs + puncta area overlay ---- %%
figure;
imshow(channel2, [], 'InitialMagnification', 'fit'); 
hold on;

% --- ROI overlay ---
roiRGB = label2rgb(roiMask, 'jet', 'k', 'shuffle');
h = imshow(roiRGB);
set(h, 'AlphaData', 0.25);   % Transparency so image shows underneath

% --- Puncta bw area ---
i = imshow(counts.totalArea);
set(i, 'AlphaData', 0.5);

% --- ROI boundaries (optional but very useful for visual QC) ---
boundaries = bwboundaries(roiMask > 0);
for b = 1:length(boundaries)
    boundary = boundaries{b};
    plot(boundary(:,2), boundary(:,1), 'w-', 'LineWidth', 1.5);
end

title('ROIs + boundaries + puncta area');
hold off;

%% ---- Delete all but useful outputs ---- %%

% clearvars -except counts

