% convert .flac to .wav and downsample to 10 kHz and 1 kHz

clear all
clc
warning('off')

path_in ='E:\GoMex2018\flac\';
% cd(path_in);
path_out1='E:\GoMex2018\wav\sg639-125kHz\';
mkdir(path_out1);
path_out2='E:\GoMex2018\wav\sg639-10kHz\';
mkdir(path_out2);
path_out3='E:\GoMex2018\wav\sg639-1kHz\';
mkdir(path_out3);

fs1=10000;
fs2=1000;

files=dir([path_in '*.flac']);
fprintf(1, '%i files:\n',length(files));
for f=1:length(files)
    try
        [data,fs] = audioread([path_in files(f,1).name]);
        
         data1=resample(data,fs1,fs);
         data2=resample(data,fs2,fs);
        
%         audiowrite([path_out1 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data,fs);
         audiowrite([path_out2 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data1,fs1);
         audiowrite([path_out3 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data2,fs2);
        
        % disp([datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' processed']);
    catch
        disp(['Attention: ' datestr(now) ' file: ' files(f,1).name ' corrupt']);
    end
    fprintf(1,'.')
    if rem(f,80) == 0; fprintf(1,'\n%3d ',floor((length(files)-f)/80)); end
end