%converting glider flac files

clear all
clc
gldr='sg639';
lctn='GoMex';
dplymnt='Jun19';

path_flac='E:\GoMex2018\flac\';
% path_out1=[path gldr '_' lctn '_' dplymnt '_wav\'];
path_out1 = 'E:\GoMex2018\wav\sg639-125kHz\';
mkdir(path_out1);

% fs1=10000;
% fs2=1000;

% folder=dir(path);
folder(1).name=gldr;
n_good=0;
n_corrupt=0;

for i=1 %3:length(folder)
        files=dir([path_flac folder(i,1).name '\*.flac']);
%     files = dir([path_flac '\*.flac']);
    for j=1:length(files)
        try
            [data,fs,bits] = audioread([path_flac folder(i,1).name '\' files(j,1).name]);
            t1=datenum(files(j,1).name(6:end-5),'_yymmdd_HHMMSS');
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
            n_good=n_good+1
        catch
            disp(['Attention: ' datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' corrupt']);
            n_corrupt=n_corrupt+1
        end
    end
end