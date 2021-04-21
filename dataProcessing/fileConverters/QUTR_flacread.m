%converting sg158 flac files

clear all
clc
glider='SG158';
lctn='score';
dplymnt='Dec15

path='G:\SeagliderMay2015Newport\';
path_out1=['G:\SeagliderMay2015Newport\' glider '_wav\'];

% fs1=10000;
% fs2=1000;

% folder=dir(path);
folder(1).name=glider;

for i=1; %3:length(folder)
    files=dir([path folder(i,1).name '\*.flac']);
    for j=1:length(files)
        try
            [data,fs,bits] = flacread([path folder(i,1).name '\' files(j,1).name]);
            t1=datenum(files(j,1).name(6:end-5),'yymmdd_HHMMSS');
            chk=files(j,1).bytes/length(data);
            
            if chk>1.5
                disp(['Problem reading file: ' folder(i,1).name '\' files(j,1).name]);
            end
            
%             data1=resample(data,fs1,fs);
%             data2=resample(data,fs2,fs);
            
            wavwrite(data,fs,bits,[path_out1 files(j,1).name(1:end-5) '.wav']);
%             wavwrite(data1,fs1,bits,[path_out2 files(j,1).name(1:end-5) '.wav']);
%             wavwrite(data2,fs2,bits,[path_out3 files(j,1).name(1:end-5) '.wav']);
            
            disp([datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' processed']);
        catch
            disp(['Attention: ' datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' corrupt']);
        end
    end
end