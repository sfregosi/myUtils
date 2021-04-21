% convert .flac to .wav and downsample to 10 kHz and 1 kHz

% need a couple versions of this for different DASBR file formats
% Black DASBRs/SM3M's file format is:
% SM3M-1_0+1_20160717_174310
% so
% fileOut = [files(f,1).name(14:19) '-' files(f,1).name(21:26) '.wav'];
%

clear all
clc
warning('off')

dasbr = true;
glider = false;
tic

path = 'G:\AFFOGATO-1\DASBR Data - 1\B-4 DASBR\Card-N 512GB\';
cd(path);
path_out1 = 'E:\BD4-1\BD4-1-256kHz\';
mkdir(path_out1);
path_out2 = 'E:\BD4-1\BD4-1-10kHz\';
mkdir(path_out2);
path_out3 = 'E:\BD4-1\BD4-1-1kHz\';
mkdir(path_out3);

fs1 = 10000;
fs2 = 1000;

if (glider)
    files = dir('*.flac');
    ch = 1;
else
    files = dir('*.wav');
    ch = 2;
end

for f = 1:length(files)
    %     fileOut = [files(f,1).name(7:12) '-' files(f,1).name(14:19) '.wav'];        % WISPR
%     fileOut = [files(f,1).name(14:19) '-' files(f,1).name(21:26) '.wav']; % B1 DASBR
        fileOut = [files(f,1).name(13:18) '-' files(f,1).name(20:25) '.wav']; % B2 DASBR

    try
        [data,fs] = audioread(files(f,1).name);
        
        data1 = resample(data,fs1,fs);
        data2 = resample(data,fs2,fs);
        
        audiowrite([path_out1 fileOut],data(:,ch),fs);
        audiowrite([path_out2 fileOut],data1(:,ch),fs1);
        audiowrite([path_out3 fileOut],data2(:,ch),fs2);
        
        
        % disp([datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' processed']);
    catch
        disp(['Attention: ' datestr(now) ' file: ' files(f,1).name ' corrupt']);
    end
    if rem(f,10) == 0;
        disp([num2str(f) ' files done'])
    end
end

toc