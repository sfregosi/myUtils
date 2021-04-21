

files=dir('*.flac');
fs_new=1000;
for i=1:length(files)
    [y,fs] = audioread(files(i,1).name);
y_new=resample(y,fs_new,fs);
audiowrite([files(i,1).name(7:12) '-' files(i,1).name(14:19) '.wav'],y_new,fs_new)
end