function muValues = fitGaussianMixtureToImage(filename, numComponents, makePlot)
% fitGaussianMixtureToImage
% Loads a multi-plane TIFF, extracts channel 2, downsamples,
% fits a Gaussian mixture model, and returns the means (mu).
%
% Inputs:
%   filename       - string, path to TIFF file
%   numComponents  - number of Gaussian components (e.g. 2)
%   makePlot       - optional true/false to plot GMM (default = false)
%
% Output:
%   muValues       - vector of mean values from gmModel.mu

    if nargin < 3
        makePlot = false;
    end

    % --- Load TIFF metadata ---
    info = imfinfo(filename);
    numImages = numel(info);

    % --- Read image stack ---
    imgStack = [];
    for k = 1:numImages
        imgStack(:,:,k) = imread(filename, k);
    end

    % --- Extract channel 2 ---
    if numImages < 2
        error('This TIFF does not contain a second channel.');
    end

    channel2 = double(imgStack(:,:,2));

    % --- Downsample ---
    scaleFactor = sqrt(1/50);  % ≈ 0.1414 (same as your 0.1)
    downsampled = imresize(channel2, scaleFactor, 'bilinear');

    % --- Convert to vector for GMM ---
    pixelVector = downsampled(:);

    % --- Fit Gaussian mixture ---
    gmModel = fitgmdist(pixelVector, numComponents, ...
        'RegularizationValue', 1e-5, ...
        'Replicates', 20, ...
        'Options', statset('MaxIter',1000));

    % --- Output means ---
    muValues = gmModel.mu;

    % ------------------------ Plot (optional) ------------------------
    if makePlot
        figure;
        histogram(pixelVector, 100, 'Normalization', 'pdf', 'EdgeColor', 'none');
        hold on;

        x = linspace(min(pixelVector), max(pixelVector), 1000)';

        % Mixture PDF
        y = pdf(gmModel, x);
        plot(x, y, 'k-', 'LineWidth', 2);

        % Individual components
        for k = 1:numComponents
            yk = gmModel.ComponentProportion(k) * ...
                 normpdf(x, gmModel.mu(k), sqrt(gmModel.Sigma(:,:,k)));

            plot(x, yk, '--', 'LineWidth', 2);

            % vertical line for mean
            xline(gmModel.mu(k), '-', sprintf('Mean %.2f', gmModel.mu(k)), ...
                  'Color', 'r', 'LineWidth', 1.5, 'LabelOrientation', 'horizontal');
        end

        xlabel('Pixel intensity');
        ylabel('PDF');
        title('Gaussian Mixture Fit to Pixel Intensities');
        legend('Data histogram', 'Mixture model');
    end
end