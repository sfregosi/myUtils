%path_in='H:\score\2016\sg158-LF-1kHz\';
path_in='H:\score\2016\sg158-MF-10kHz\';
%path_in='H:\score\2016\sg158-HF-125kHz\';

cd(path_in);
files=dir([path_in '\*.wav']);

data=[];

for f=1:650; %length(files);
    [y,Fs]=audioread(files(f).name);
    data(f,1)=length(y);
    data(f,2)=Fs;
end

for g=2:length(data(:,1));
    data(g-1,3)=data(g,1)-data(g-1,1);
end