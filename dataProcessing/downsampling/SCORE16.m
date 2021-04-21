% convert .flac to .wav and downsample to 10 kHz and 1 kHz

clear all
clc
warning('off')

path='E:\sg639\Acoustics\';
cd(path);
path_out1='HE:\sg639-125\';
mkdir(path_out1);
path_out2='E:\sg639-10\';
mkdir(path_out2);
path_out3='E:\sg639-1\';
mkdir(path_out3);

fs1=10000;
fs2=1000;

files=dir('*.flac');

for f=1:length(files)
    try
        [data,fs] = audioread(files(f,1).name);
        
        data1=resample(data,fs1,fs);
        data2=resample(data,fs2,fs);
        
        audiowrite([path_out1 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data,fs);
        audiowrite([path_out2 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data1,fs1);
        audiowrite([path_out3 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data2,fs2);
        
        % disp([datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' processed']);
    catch
        disp(['Attention: ' datestr(now) ' file: ' files(f,1).name ' corrupt']);
    end
end