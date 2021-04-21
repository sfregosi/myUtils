%rename WISPR files for 2015/2016 issue
clear all
cd('X:\Gliders\2015_12_21_SCORE_sg158\SG158\')

%get all the files in the folder
files=dir('*.flac');

%loop through each
for f=1:length(files)
    % get the file name
    oldName=files(f).name;
    % example: wispr_150101_000704
    newName=(['wispr_16' oldName(9:end)]);
    movefile(oldName,newName);
end
%% Remove WISPR 
% I already ran rename_files_dave.m to make dashes instead of _

cd('H:\score\2016\sg158_score_Dec15_wav\');

files=dir('*.wav');

for f=1:length(files)
    oldName=files(f).name;
    newName=oldName(7:end);
    movefile(oldName,newName);
end
