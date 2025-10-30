% MATLAB + FIJI pipeline
% Requirements:
%   - Fiji installed with Bio-Formats
%   - MIJ.jar and ij.jar on MATLAB path
%   - Masks available (binary mask images per channel, same size as raw data)

addpath('/Applications/MATLAB_R2024b.app/java/jar'); % adjust path to Fiji scripts folder
javaaddpath '/Applications/MATLAB_R2024b.app/java/jar/mij.jar';
javaaddpath '/Applications/MATLAB_R2024b.app/java/jar/ij.jar';
javaaddpath '/Applications/MATLAB_R2024b.app/java/jar/bfmatlab/bioformats_package.jar';
javaaddpath '/Applications/Fiji.app/jars/bfmatlab/bioformats_package.jar';
% javaaddpath 'C:\Fiji.app\plugins\loci_tools.jar';   % if present

javaaddpath '/Applications/Fiji.app/jars/bio-formats';

% Start MIJ
MIJ.start();
inputDir = pwd;
% Folder that contains images and masks
% inputDir = 'C:\Users\Owner\OneDrive - Stanford\Amira computer cellpose\MATLAB processing\79';
maskDir  = inputDir;    % your masks folder (optional)
%Folder to save all measurements in
outputDir = fullfile(inputDir, 'measurements');
if ~exist(outputDir,'dir')
    mkdir(outputDir);
end

% Collect files
files = dir(fullfile(inputDir, '*.tif'));  % or *.czi, *.nd2, etc.
masksfiles = dir(fullfile(inputDir, '*.zip'));  % or *.czi, *.nd2, etc.
%assumes masks are saved with the same file name +  '_rois.zip'; can change
%this if needed

for i = 1:length(files)
    fname = fullfile(files(i).folder, files(i).name);
    fprintf('Processing %s...\n', fname);
    
    %     % Output CSV per file
    [~, baseName, ~] = fileparts(files(i).name);
    %     outputCSV = fullfile(outputDir, [baseName '_measurements.csv']);
    %     fid = fopen(outputCSV,'w');
    %     fprintf(fid,'Channel,Mean,Median,StdDev,IntegratedDensity\n');
    
    % Open image in Fiji
    %     MIJ.run('Bio-Formats Importer', sprintf('open=%s autoscale color_mode=Default view=Hyperstack stack_order=XYCZT', fname));
    p = strrep(fname,'\','/');
    MIJ.run('Open...', sprintf('path=[%s]', p));
    % opts = sprintf('open=[%s] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT', fname);
    % ij.IJ.runPlugIn('loci.plugins.LociImporter', opts);
    
    %         maskName = fullfile(maskDir,  [files(i).name(1:end-9), '_rois.zip']);
    matches = masksfiles(contains({masksfiles.name}, files(i).name(1:15)));
%     maskName = matches.name;
%     if contains(matches.name, 'maxproj')
    maskName = fullfile(maskDir,matches.name); %might have to readjust this number
%     else
%             maskName = fullfile(maskDir,[matches.name(1:end-24) 'RGB_rois.zip']); %might have to readjust this number
%     end
%     %    outputFile = [folder, inputFile(1:end-25), '_RGB_maxproj.tif'];
    
    
    % Get number of channels
     imp = ij.IJ.getImage();

    MIJ.run("Make Composite", "display=Composite");
    imp = ij.IJ.getImage();
    %%%%%%%%%%%%%%% ATTENTION SET TO 4 MANUALLY
    nChannels = imp.getNChannels();
    MIJ.run('Split Channels');
    
    for c = 1:nChannels
        
        % By default, channel windows will be named like "C1-..."
        channelTitle = sprintf('C%d-%s', c, files(i).name);
        %         channelTitle = strrep(channelTitle, '.tif', '');
        
        % Activate this channel
        ij.IJ.selectWindow(channelTitle);
        
        % Load corresponding mask (optional, assumes mask named "mask_C1_filename.tif")
        if exist(maskName, 'file')
            MIJ.run('Open...', ['path=[' maskName ']']);
            
            %             MIJ.run('Open...', sprintf('%s', maskName));
            maskImp = ij.IJ.getImage();
            MIJ.run( 'ROI Manager...');
            %             MIJ.run('Show All with labels');
            rm = ij.plugin.frame.RoiManager.getInstance();
            rm.runCommand('Show All with labels');
            %             rm = ij.plugin.frame.RoiManager();
            rm.runCommand('Set Measurements...', 'area mean standard min centroid center median redirect=None decimal=3');
            rm.runCommand('Measure');
            
            
            % Get results
            results = MIJ.getResultsTable;
            rm = ij.plugin.frame.RoiManager.getInstance();
            %             MIJ.run('Clear Results');
            %             rm.runCommand('Clear Results');
            %             rm.runCommand('Deselect');
            
            ij.IJ.selectWindow('Results');
            MIJ.run('Close');
            
            %             MIJ.run( 'ROI Manager...');
            %             MIJ.run('Close');
            
            
            % Write to CSV
            
            outputCSV = fullfile(outputDir,[baseName '_C' num2str(c) '.csv']);
            writematrix(results,outputCSV);
            clear results
            pause(0.1);
            
            
            %             fprintf(fid,'%d,%.4f,%.4f,%.4f,%.4f\n', ...
            %                 c, results(1,1), results(1,2), results(1,3), results(1,4));
            
            % Close mask
            ij.IJ.run("Close");
        else
            warning('Mask not found: %s', maskName);
        end
        
        % Close channel image
        %         ij.IJ.run('Close');
    end
    
    % Close original image
    ij.IJ.run('Close All');
    
    %     fclose(fid);
end

% Quit Fiji
MIJ.exit;
