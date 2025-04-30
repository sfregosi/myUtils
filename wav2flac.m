function wav2flac(path_flac, inDir, outDir)
% WAV2FLAC	Wrapper to convert WAV to FLAC via command line/flac.exe
%
%   Syntax:
%       WAV2FLAC(PATH_FLAC, INDIR, OUTDIR)
%
%   Description:
%       Wrapper function to convert a single directory of WAV files to FLAC
%       format using the command line to call flac.exe. flac.exe can be
%       downloaded from: https://xiph.org/flac/download.html
%
%   Inputs:
%       path_flac   [string] fullfile path to flac.exe but should not
%                   include the '.exe.', e.g.,
%                   'C:\flac-1.5.0-win\Win64\flac'
%       inDir       [string] path to folder containing WAV files to be
%                   converted
%       outDir      [string] path to output folder to store newly created
%                   FLAC files. *THIS PATH MUST ENDED IN A FINAL SLASH!!* A
%                   check will ensure that it does.
%
%	Outputs:
%       None. Creates files in outDir
%
%   Examples:
%       wav2flac('C:\user.name\programs\flac-1.5.0-win\Win64\flac', ...
%                'F:\wavFiles', 'F:\flacFiles\');
%
%   See also FLAC2WAV
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   2025 April 30
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% argument checks

% path to flac.exe (without the .exe)
% e.g., path_flac = 'C:\Users\selene.fregosi\programs\flac-1.5.0-win\Win64\flac';
if ~exist([path_flac, '.exe'], 'file')
    [file, location] = uigetfile('*.exe', 'Select flac.exe', path_flac);
    if ~strcmp(file, 'flac.exe')
        error('flac.exe not properly selected. Exiting.')
    end
    path_flac = fullfile(location, 'flac');
end

% check input directory
% e.g., inDir = 'F:\CalCurCEAS2024_glider_data';
if ~isfolder(inDir)
    inDir = uigetdir('C:\', 'Select folder containing WAV files');
end
    fprintf(1, 'inDir: %s\n', inDir);

% check output directory
% VERY IMPORTANT TO HAVE FINAL SLASH \
% outDir = 'F:\CalCurCEAS2024_glider_data\flac\';
if ~isfolder(outDir)
    outDir = uigetdir(inDir, 'Select folder to save created FLAC files to');
end
% make sure it has an ending slash
if ~endsWith(outDir, filesep)
    outDir = [outDir, filesep];
end
fprintf(1, 'outDir: %s\n', outDir);


% process the files
tic

% % make output directory if it doesn't exist - catch above replaces this
% if ~isfolder(outDir)
%     mkdir(outDir)
% end

% build out command line string
encodeStr = '%s --keep-foreign-metadata-if-present --output-prefix=%s %s';

% loop through all files and convert
fileList = dir(fullfile(inDir, '*.wav'));
if isempty(fileList)
    error('No WAV files found in %s', inDir);
end

cd(inDir)
nFiles = length(fileList);
for iFile = 1:length(fileList)
    myCMD = sprintf(encodeStr, path_flac, outDir, fileList(iFile).name);
    [status, cmdout] = system(char(myCMD));
    fprintf('Done with file %0.0f of %0.0f - %s\n', ...
        iFile, nFiles, fileList(iFile).name)
end

fprintf(' Done processing %s\n Elapsed time %.0f seconds\n', inDir, toc)

end