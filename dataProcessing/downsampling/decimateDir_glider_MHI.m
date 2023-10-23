% script for decimating 2022 and 2023 MHI Glider data
% 
% PMAR sample rate 180260 Hz
% WISPR sample rate (sg679 only) 180 kHz

clear all
% clc
warning('off')

missionStr = 'sg639_MHI_Apr2023';

path = fullfile('F:\', missionStr, 'recordings', 'wav');
% cd(path);
% path_out1='F:\SoCal2020\sg639_downsampled\sg639-180kHz\';
% mkdir(path_out1);
path_out2 = fullfile('E:\glider_MHI', missionStr, 'recordings', 'wav_10kHz');
mkdir(path_out2);
path_out3 = fullfile('E:\glider_MHI', missionStr, 'recordings', 'wav_1kHz');
mkdir(path_out3);

fs1 = 180260;
fs2 = 10000;	fs2Str = '10kHz';
fs3 = 1000;		fs3Str = '1kHz';

files = dir(fullfile(path, '*.wav'));
fsTable = [];

for f = 1:length(files)
    try
        [data, fs] = audioread(fullfile(path, files(f,1).name));
        fsTable(f,1) = fs;
        
        %         data1 = resample_PMARXL(data, fs1, fs);
                data2 = resample(data, fs2, fs);
                data3 = resample(data, fs3, fs);
        
        %         audiowrite([path_out1 files(f,1).name],data,fs1);
		[~, name, ext] = fileparts(fullfile(path_out2, files(f,1).name));
                audiowrite(fullfile(path_out2, [name, '_', fs2Str, ext]), ...
					data2, fs2);
                audiowrite(fullfile(path_out3, [name, '_', fs3Str, ext]), ...
					data3, fs3);
        
        fprintf(1, '%s - file #%i: %s processed\n', datestr(now), f, files(f,1).name);
    catch
        fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), ...
			f, files(f,1).name);
    end
end

% save('sampleRatePerFile_sg639.mat','fsTable');