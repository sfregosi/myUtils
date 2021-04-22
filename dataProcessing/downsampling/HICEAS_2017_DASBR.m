% downsample HICEAS 2017 DASBR data for baleen whale analysis
% original sample rate


clear all
% clc
warning('off')

% start with single DASBR at a time...could likely loop through all
% eventually
dasbrNum = 'DS18_ST-K';
serial = '1543770129'; %inner folder name and prefix of all wave filenames

path_raw = ['Q:\HICEAS_2017_DASBR\Recordings\' dasbrNum '\' serial '\'];
% cd(path_raw);

wavFiles = dir([path_raw '*.wav']);
% get original sample rate
info = audioinfo([path_raw wavFiles(1,1).name]);
info.SampleRate % 288 kHz

% define new sample rates. **Make sure a evenly divide into full SR**
fs0 = info.SampleRate;
fs1 = fs0/60; % 4.8 kHz
fs2 = fs0/288; % 1 kHz

% path_out1='F:\SoCal2020\sg639_downsampled\sg639-180kHz\';
% mkdir(path_out1);
% path_out2='E:\SoCal2020\sg639_downsampled\sg639-10kHz\';
% mkdir(path_out2);
path_out1 = 'Q:\HICEAS_2017_DASBR\Recordings\decimated\DS18_ST-K_4.8kHz\';
mkdir(path_out1);
path_out2 = 'Q:\HICEAS_2017_DASBR\Recordings\decimated\DS18_ST-K_1kHz\';
mkdir(path_out2);

for f = 1:length(wavFiles)
    try
        [data, fs] = audioread([path_raw wavFiles(f,1).name]);
        
        data1 = resample(data, fs1, fs);
        data2 = resample(data, fs2, fs);
        
        audiowrite([path_out1 wavFiles(f,1).name(1:end-4) '_4.8kHz.wav'], data1, fs1);
        audiowrite([path_out2 wavFiles(f,1).name(1:end-4) '_1kHz.wav'], data2, fs2);
        
        fprintf(1, '%s - file #%i: %s processed\n', datestr(now), f, wavFiles(f,1).name);
    
    catch
        fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), f, wavFiles(f,1).name);
    end
end

