% Convert file names from DASBR Soundtrap recordings for LTSA in Triton
% file names are 201883689.160720173948.wav

path_in='D:\AFFOGATO-1\DASBR Data\W-2 DASBR\Soundtrap\';
path_out=[path_in 'LTSA\'];
[~,~,~] = mkdir(path_out);	% the return args prevent an error msg


%**sound files are in last folder, name not a date
folder = '201883689\';

files = dir([path_in folder '*.wav']);

for i=1:length(files)
    if rem(i,100)==0;
        disp(i);
    end
    try
        [y,Fs] = audioread([path_in folder files(i,1).name]);
        fname_new=[files(i,1).name(11:16) '-' files(i,1).name(17:end-4) '.wav'];
        audiowrite([path_out fname_new],y,Fs);
    catch
        disp(files(i,1).name);
    end
end
    
