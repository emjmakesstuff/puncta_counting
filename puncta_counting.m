%% --- Puncta Counting Program --- %%
% EmJ Rennich 2025

% Requirements:
%   - Fiji installed with Bio-Formats
%   - MIJ.jar and ij.jar on MATLAB path
%   - ReadImageJROI downloaded

% Clear all persisting variables
clear; close all force; clc;

% Read inputs from cellpose (TIF and a zip file of cell ROIs)
zip_filename = ('example_data/101_A4_fov5_20x__2025_09__RGB_maxproj_rois.zip');
tif_filename = ('MAX_101_A4_fov5_20x__2025_09_30__15_11_46.tif');

% Get image info
image_info = imfinfo(tif_filename);
numChannels = length(image_info);
firstImage = imread(tif_filename, 1);
[rows, cols] = size(firstImage);
imageData = zeros(rows, cols, numChannels, class(firstImage));

for i = 1:numChannels
    imageData(:,:,i) = imread(tif_filename, i);
    % figure; imagesc(imageData(:,:,i));
end

vnImageSize = [rows, cols];

% Read ROIs into a 1xnum_cells cell array
[cvsROIs] = ReadImageJROI(zip_filename);
[sRegions] = ROIs2Regions(cvsROIs, vnImageSize);


% Place a marker in the center of each ROI (currently marking each cell but
% will use this to mark puncta later
figure; hold on; axis equal
dapi_img = imageData(:,:,4);
image = imrotate(dapi_img,90);
image = flipud(image);
imagesc(image);
for i = 1:numel(sRegions.PixelIdxList)
    % Convert linear indices to subscripts (row, col)
    [r, c] = ind2sub(vnImageSize, sRegions.PixelIdxList{i});
    
    % Compute center (mean row and col)
    rc = mean(r);
    cc = mean(c);
    
    % Plot the centroid
    plot(cc, rc, 'k.', 'MarkerSize', 10)
end
