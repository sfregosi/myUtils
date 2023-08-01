function [sig, fs] = stitchWavs(wavFiles)
% STITCHWAVS	Combine multiple wav files into a single variable
%
%   Syntax:
%       [SIG, FS] = STITCHWAVS(WAVFILES)
%
%   Description:
%       Read in multiple wav files sequentially and combine them into a
%       single 'sig' variable for plotting, etc. 
%
%       BE CAREFUL!!! Don't try to do this with too many files with high
%       sample rates or will max out memory. Have reasonably read in 30
%       mins of data at 96 kHz with 16 GB machine.
% 
%   Inputs:
%       wavFiles   [STRUCT] output of a dir command containing fields
%       'folder' and 'name'
%
%	Outputs:
%       sig  [matrix] N-by-1 matrix of signal values
%       fs   [integer] sampling rate as read by audioinfo
%
%   Examples:
%       wavFiles = dir('sounds\*.wav');
%       [sig, fs] = stitchWavs(wavFiles(1:5));
%
%   See also DIR AUDIOREAD AUDIOINFO
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   FirstVersion:   31 July 2023
%   Updated:
%
%   Created with MATLAB ver.: 9.10.0.1739362 (R2021a) Update 5
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


sig = [];
if ~isempty(wavFiles)
    for f = 1:length(wavFiles)
        try
            [y, fs] = audioread(fullfile(wavFiles(f).folder, wavFiles(f).name));
            sig = [sig; y];
        catch
            fprintf(1, '%s is corrupt\n', wavFiles(f).name);
        end
    end

end