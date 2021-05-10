% downsample WHICEAS 2020 DASBR data for baleen whale analysis
% original sample rate


clear all
% clc
warning('off')

drive = 'R:\';
cruise = 'WHICEAS_2020';
% start with single DASBR at a time...could likely loop through all
% eventually
dasbrNum = 'DS2';
stNum = 'ST-2';
serial = '1208766495'; %inner folder name and prefix of all wave filenames

path_raw = [drive cruise '_DASBR\Recordings\' dasbrNum '\' stNum '\' ...
    serial '\'];
% cd(path_raw);

wavFiles = dir([path_raw '*.wav']);
% get original sample rate
info = audioinfo([path_raw wavFiles(1,1).name]);
info.SampleRate % 288 kHz

% define new sample rates. **Make sure a evenly divide into full SR**
fs0 = info.SampleRate;
fs1 = fs0/60; % 4.8 kHz
fs2 = fs0/288; % 1 kHz

path_out1 = [drive cruise '_DASBR\Recordings\decimated\' dasbrNum '_4.8kHz\'];
mkdir(path_out1);
path_out2 = [drive cruise '_DASBR\Recordings\decimated\' dasbrNum '_1kHz\'];
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

