% convert .flac to .wav and downsample to 10 kHz and 1 kHz
% don't need to convert to wav. going to try to just do it in .flac format

clear all
clc
warning('off')

folderList = dir('H:\M3R_flac_2016\');
for fldr = [4:82]
    scorePhone = str2num(folderList(fldr).name);

path_in=['H:\M3R_flac_2016\' num2str(scorePhone) '\'];
% cd(path);
% path_out1='H:\score\2016\q001-125\';
% mkdir(path_out1);
% path_out2='H:\score\2016\q001-10\';
% mkdir(path_out2);
path_out3=['E:\1kHzData\' num2str(scorePhone) '\'];
mkdir(path_out3);
fprintf('Phone %i\n', scorePhone);

% fs1=10000;
fs2=1000;

files=dir([path_in '*.flac']);

for f=1:length(files)
    try
        [data,fs] = audioread([path_in files(f,1).name]);
        
        %         data1=resample(data,fs1,fs);
        data2=resample(data,fs2,fs);
        
        %         audiowrite([path_out1 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data,fs);
        %         audiowrite([path_out2 files(f,1).name(7:end-12) '-' files(f,1).name(14:19) '.wav'],data1,fs1);
        audiowrite([path_out3 files(f,1).name(1:7) '01' files(f,1).name(10:end-5) '.wav'],data2,fs2);
        fprintf(1, '.');
        if (rem(f,80) == 0), fprintf(1, '\n%3d ', floor((length(files)-f)/80)); end
        % disp([datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' processed']);
    catch
        fprintf(1,'\n Attention: %s file: %s corrupt', datestr(now),files(f,1).name);
    end
end

end