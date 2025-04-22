function output = wav2flac(flacDir, inDir, outDir)
% WAV2FLAC	One-line description here, please
%
%   Syntax:
%       OUTPUT = WAV2FLAC(FLACDIR, INDIR, OUTDIR)
%
%   Description:
%       Detailed description here, please
%   Inputs:
%       flacDir   describe, please
%       inDir   describe, please
%       outDir   describe, please
%
%	Outputs:
%       output  describe, please
%
%   Examples:
%
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   2025 April 22
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ADD IN ARGUMENT CHECKS

% set input folder containing wav files
inDir = 'F:\CalCurCEAS2024_glider_data\flac_tests\test_wavs';
cd(inDir)
% set output directory to put new files - VERY IMPORTANT TO HAVE FINAL SLASH \
outDir = 'F:\CalCurCEAS2024_glider_data\flac_tests\output_flacs\';

% set location of FLAC program
fullPathFlac = 'C:\Users\selene.fregosi\programs\flac-1.5.0-win\Win64\flac';

% process

tic

% build out command line string
encodeStr = '%s --keep-foreign-metadata-if-present --output-prefix=%s %s';

% make output directory if it doesn't exist
if ~isfolder(outDir)
    mkdir(outDir)
end

% loop through all files and convert
fileList = dir(fullfile(inDir, '*.wav'));
if isempty(fileList)
    return
end
cd(inDir)
nFiles = length(fileList);
for iFile = 1:length(fileList)
    myCMD = sprintf(encodeStr, fullPathFlac, outDir, fileList(iFile).name);
    [status, cmdout] = system(char(myCMD));
    fprintf('Done with file %0.0f of %0.0f - %s\n', ...
        iFile, nFiles, fileList(iFile).name)
end

fprintf(' Done processing %s\n Elapsed time %.0f seconds\n', inDir, toc)

end