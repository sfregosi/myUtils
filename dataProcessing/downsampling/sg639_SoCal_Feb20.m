% convert downsample to 180 kHz 10 kHz and 1 kHz

clear all
% clc
warning('off')

path='E:\SoCal2020\sg639wav\';
% cd(path);
% path_out1='F:\SoCal2020\sg639_downsampled\sg639-180kHz\';
% mkdir(path_out1);
% path_out2='E:\SoCal2020\sg639_downsampled\sg639-10kHz\';
% mkdir(path_out2);
% path_out3='E:\SoCal2020\sg639_downsampled\sg639-1kHz\';
% mkdir(path_out3);
path_out4='E:\SoCal2020\sg639_downsampled\sg639-5kHz\';
mkdir(path_out4);

% fs1 = 180260;
% fs2 = 10000;
% fs3 = 1000;
fs4 = 5000;

files=dir([path '*.wav']);
fsTable = [];

for f=1:length(files)
    try
        [data,fs] = audioread([path files(f,1).name]);
        fsTable(f,1) = fs;
        
        %         data1 = resample_PMARXL(data, fs1, fs);
        %         data2 = resample(data, fs2, fs);
        %         data3 = resample(data, fs3, fs);
        data4 = resample(data, fs4, fs);
        
        %         audiowrite([path_out1 files(f,1).name],data,fs1);
        %         audiowrite([path_out2 files(f,1).name],data2,fs2);
        %         audiowrite([path_out3 files(f,1).name],data3,fs3);
        audiowrite([path_out4 files(f,1).name], data4, fs4);
        
        fprintf(1, '%s - file #%i: %s processed\n', datestr(now), f, files(f,1).name);
    catch
        fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), f, files(f,1).name);
    end
end

% save('sampleRatePerFile_sg639.mat','fsTable');