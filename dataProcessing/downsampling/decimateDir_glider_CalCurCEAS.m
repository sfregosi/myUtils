% script for decimating 2024 CalCurCEAS glider data
% 
% sg639 and sg680 used WISPR3, sample rate 200 kHz
% sg679 had WISPR2, sample rate 180 kHz
%
% resample vs decimate: this code uses 'resample' (allows any rate for
% downsampled data). Alternatively can use 'decimate' which is used by
% Triton but requires integer decimation factors (e.g., new sample rate
% must divide evenly into original sample rate)

clear all
% clc
warning('off')

% set glider mission string (for assembling file/folder names)
missionStr = 'sg639_CalCurCEAS_Sep2024';

% set original and desired sample rates (numeric and as string)
fs0 = 200000; % original sample rate
fs1 = 10000;	fs1Str = '10kHz';
fs2 = 1000;		fs2Str = '1kHz';

% set input and output paths
path_in = fullfile('E:\', missionStr, 'flac');
path_out1 = fullfile('E:\', missionStr, ['flac_' fs1Str]);
mkdir(path_out1);
path_out2 = fullfile('E:\', missionStr, ['flac_' fs2Str]);
mkdir(path_out2);

% read in original files - set extension (wav or flac)
files = dir(fullfile(path_in, '*.flac'));
fsTable = [];

for f = 1:length(files)
    try
        [data, fs] = audioread(fullfile(path_in, files(f,1).name));
        fsTable(f,1) = fs;
        
                data1 = resample(data, fs1, fs);
                data2 = resample(data, fs2, fs);
        
		[~, name, ext] = fileparts(fullfile(path_out1, files(f,1).name));
                audiowrite(fullfile(path_out1, [name, '_', fs1Str, ext]), ...
					data1, fs1);
                audiowrite(fullfile(path_out2, [name, '_', fs2Str, ext]), ...
					data2, fs2);
        
        fprintf(1, '%s - file #%i: %s processed\n', datestr(now), f, files(f,1).name);
    catch
        fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), ...
			f, files(f,1).name);
    end
end

% save('sampleRatePerFile_sg639.mat','fsTable');