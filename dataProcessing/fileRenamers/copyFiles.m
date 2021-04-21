% copying files for christina to check. based off the csv i made by
% randomizing the 5 min periods

clear all
clc

% for 2015 data. 
randList = 'C:\Users\selene\OneDrive\projects\AFFOGATO\finWhaleDetectionsComparison\manualMarking\finDetectorPerformanceCheck_2015_20180115.csv';
copyFileDir = 'E:\M3R_randPeriods_downsampled\';

r = readtable(randList);
tic
for f = 1:height(r);
    %     tic
    if ~isnan(r.phone(f));
        randDate = datetime(r.year(f),r.month(f),r.day(f),r.hour(f),r.min(f),0);
        randDateEnd = randDate + minutes(5);
        fldr = [num2str(r.phone(f)) '\'];
        
        if r.phone(f) >= 900;
            origFileDir = 'E:\M3R_flac_2015_900s\';
        else 
            origFileDir = 'D:\M3R_flac_2015_100sto800s\';
        end
        
        fileList = dir([origFileDir fldr '\']);
        for g = 3:length(fileList); % start at 3 to skip the two blanks
            fileDates(g) = datetime(fileList(g).name(23:37),...
                'InputFormat','yyyyMMdd''T''HHmmss');
        end
        idxStart = find(fileDates < randDate,1,'last');
        idxEnd = find(fileDates > randDateEnd,1,'first');
        copyIdxs = idxStart:idxEnd-1;
        
        for h = copyIdxs
            copyfile([origFileDir fldr fileList(h).name],copyFileDir)
        end
        printf('%i periods done, %i files copied',f,length(copyIdxs))
    else printf('%i is Nan',f)
    end
    %     toc
end
toc

%% for 2016 data. 
randList = 'C:\Users\selene\OneDrive\projects\AFFOGATO\finWhaleDetectionsComparison\manualMarking\finDetectorPerformanceCheck_2016_20180116.csv';
origFileDir = 'E:\M3R_flac_2016\';
copyFileDir = 'E:\M3R_randPeriods_downsampled\';

r = readtable(randList);
tic
for f = 1:height(r);
    %     tic
    if ~isnan(r.phone(f));
        randDate = datetime(r.year(f),r.month(f),r.day(f),r.hour(f),r.min(f),0);
        randDateEnd = randDate + minutes(5);
        fldr = [num2str(r.phone(f)) '\'];
        
        fileList = dir([origFileDir fldr]);
        for g = 3:length(fileList); % start at 3 to skip the two blanks
            fileDates(g) = datetime(fileList(g).name(23:37),...
                'InputFormat','yyyyMMdd''T''HHmmss');
        end
        idxStart = find(fileDates < randDate,1,'last');
        idxEnd = find(fileDates > randDateEnd,1,'first');
        copyIdxs = idxStart:idxEnd-1;
        
        for h = copyIdxs
            copyfile([origFileDir fldr fileList(h).name],copyFileDir)
        end
        printf('%i periods done, %i files copied',f,length(copyIdxs))
    else printf('%i is Nan',f)
    end
    %     toc
end
toc

