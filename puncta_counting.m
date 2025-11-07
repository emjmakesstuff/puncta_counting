%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- Puncta Counting Program --- %%
% EmJ Rennich 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Requirements:
%   - Fiji installed with Bio-Formats
%   - MIJ.jar and ij.jar on MATLAB path
%   - ReadImageJROI downloaded

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- Reading in Data --- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear all persisting variables
clear; close all force; clc;

% Read inputs from cellpose (TIF and a zip file of cell ROIs)
% zip_filename = ('example_data/101_A4_fov5_20x__2025_09__RGB_maxproj_rois.zip');
% tif_filename = ('MAX_101_A4_fov5_20x__2025_09_30__15_11_46.tif');
% zip_filename = ('Stack_RGB_rois.zip');
tif_filename = ('synchrony29_c1-2_image034.tif');

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

% % Read ROIs into a 1xnum_cells cell array
% [cvsROIs] = ReadImageJROI(zip_filename);
% [sRegions] = ROIs2Regions(cvsROIs, vnImageSize);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% --- Plotting Base Cells and ROIs --- %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % --- Select base grayscale image (e.g., DAPI or brightfield channel) ---
% baseChannel = 4;  % Change this if needed
% img_gray = mat2gray(imageData(:,:,baseChannel));
% 
% % --- Display grayscale background ---
% figure;
% imshow(img_gray, []); hold on;
% title('Cell ROIs overlaid on grayscale image');
% colormap(gray);
% 
% % --- Overlay ROI boundaries ---
% numCells = numel(sRegions.PixelIdxList);
% % colors = hsv(numCells);  % Distinct color per ROI
% 
% for i = 1:numCells
%     idx = sRegions.PixelIdxList{i};
%     if isempty(idx)
%         continue
%     end
%     % Convert linear indices to coordinates
%     [x, y] = ind2sub(vnImageSize, double(idx));
% 
%     % Get convex boundary of the region (or use boundary() for irregular)
%     try
%         k = boundary(x, y);
%         plot(x(k), y(k), '-', 'Color', 'y', 'LineWidth', 0.25);
%     catch
%         % If boundary() fails (too few points), just scatter them
%         plot(x, y, '.', 'Color', 'y', 'MarkerSize', 0.25);
%     end
% end
% 
% % hold off;
% axis image;
% set(gca, 'YDir', 'reverse');
% title('Cell ROIs overlaid on grayscale image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- Puncta Counting --- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

puncta_img = imageData(:,:,2);
intensity = 0.25; % Ideally use same value for all images in dataset

% Create binary image for calculating puncta area
puncta_bw = mat2gray(puncta_img);
puncta_binary = imbinarize(puncta_bw, intensity); % using int threshold, make binary puncta img
figure;
imshowpair(puncta_img,puncta_binary,'montage')

% Count puncta
se = strel('disk', 1);                  % smooth by creating small disks over each high point (puncta size)
bw2 = imopen(puncta_bw, se);            % create bw image over smoothed points
% figure;
% surf(bw2, 'EdgeColor','none');
B = imextendedmax(bw2, 0.015);           % set relative height
cc = bwconncomp(B);
stats = regionprops(cc, 'Centroid');    % find centroids
centroids = cat(1, stats.Centroid);

% Plot puncta points over bw image
figure;
imshow(puncta_bw, []);
hold on;
plot(centroids(:,1), centroids(:,2), 'r.', 'MarkerSize', 5, 'LineWidth', 1);
title('Detected puncta');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- Formatting Puncta Outputs --- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


