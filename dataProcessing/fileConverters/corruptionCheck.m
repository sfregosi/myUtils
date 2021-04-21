% M3R file corruption check.

clear all
clc

% drive 1 - seagate backup 5 TB
% path_in = 'D:\M3R_flac_2015_100sto800s\';
% path_in = 'E:\M3R_flac_2015_900s\';
path_in = 'E:\M3R_flac_2016\';
folderList = dir(path_in);

for f = 3:length(folderList);
    fileList=dir([path_in folderList(f,1).name '\*.flac']);
    fprintf(1,'\n%s - %s (%d files):\n', datestr(now), [path_in folderList(f,1).name '\'], length(fileList));
    for g = 1:length(fileList)
        try
            info = audioinfo([path_in folderList(f,1).name '\' fileList(g,1).name]);
%             [s,fs] = audioread([path_in folderList(f,1).name '\' fileList(g,1).name]);
            fprintf(1, '.');
        if (rem(g,80) == 0), fprintf(1, '\n%3d ', floor((length(fileList)-g)/80)); end
        catch
            fprintf(1,'\n Attention: %s file: %s corrupt', datestr(now),fileList(g,1).name);
        end
    end
%     fprintf(1,'%s done',folderList(f,1).name);  
end
