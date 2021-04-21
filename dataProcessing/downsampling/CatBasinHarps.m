% downsample HARP xwavs from Catalina, but keep as only 30 min files (they
% downsampled but merged into 1 day files and they are too big for ishmael

clear all
clc
warning('off')

instr = 'SOCAL_CB_01_02';
path_in = ['G:\Catalina\data\xwavs\Full bandwidth\' instr '\'];
path_out1 = ['G:\Catalina\data\xwavs\downsampled\' instr '\10kHz\'];
mkdir(path_out1);
path_out2 = ['G:\Catalina\data\xwavs\downsampled\' instr '\1kHz\'];
mkdir(path_out2);

fs1 = 10000;
fs2 = 1000;

folderList = dir(path_in);
for fldr = 3:length(folderList)
    
    fileList = dir([path_in folderList(fldr).name '\*.wav']);
    ch = 1;
    
    for f = 1:length(fileList)
        tic
        fileOut1 = [fileList(f,1).name(1:end-6) '_10k.wav']; % gets rid of the .x.wav part
        fileOut2 = [fileList(f,1).name(1:end-6) '_1k.wav']; % gets rid of the .x.wav part
        try
            [s,fs] = audioread([path_in folderList(fldr).name '\' fileList(f,1).name]);
            
            s1 = resample(s,fs1,fs);
            s2 = resample(s,fs2,fs);
            
            audiowrite([path_out1 fileOut1],s1(:,ch),fs1);
            audiowrite([path_out2 fileOut2],s2(:,ch),fs2);
        catch
            disp(['Attention: ' datestr(now) ' file: ' fileList(f,1).name ' corrupt']);
        end
        clear s s1 s2
        toc
    end
    fprintf(1,'%s done\n',folderList(fldr).name);
end
