% Convert file names from DASBR recordings for LTSA in Triton
% specific to B Dasbrs - check numbering of old name for W dasbrs)
% path_in='E:\DASBR Data - 1\B-1 DASBR\Card-A 512GB\';
% path_in='E:\DASBR Data - 1\B-1 DASBR\Card-B 512GB\';
path_in='J:\B1\';

path_out='J:\B1\forLTSA\';

files = dir([path_in '*.wav']);
cd(path_in)

for f=1:length(files)
    fprintf(1,'.')
    if rem(f,80) == 0; fprintf(1, '\n%3d ',floor((length(files)-f)/80));end
    try
        oldName = files(f).name;
        newName = [path_out oldName(end-18:end-11) '-' oldName(end-9:end)];
        if (~strcmp(oldName,newName)), movefile(oldName, newName); end
        
    catch
        disp(oldName);
    end
end

% check sample rate of all files and move 96kHz files into own folder
cd(path_out)
files = dir([path_out '*.wav']);

for f = 1:length(files)
    try
    wavInfo = audioinfo(files(f).name);
    if wavInfo.SampleRate == 96000
        movefile(files(f).name,[path_out '96kHzFiles\' files(f).name]);
    end
    catch
    disp(files(f).name)
    end
end



