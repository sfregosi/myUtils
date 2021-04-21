clear all;
clc;

fin='J:\sg022_HI_194kHz\';
fout1='J:\sg022_HI_10kHz\';
fout2='J:\sg022_HI_1kHz\';

fsg=dir([fin '*.wav']);

for i=1:length(fsg);
    i
    [y,fs,bit]=wavread([fin fsg(i,1).name]);
    di=datenum(fsg(i,1).name(7:end-4),'yyyymmdd-HHMMSS');
    d1=resample(y,10000,fs);
    d2=resample(y,1000,fs);
    wavwrite(d1,10000,16,[fout1 datestr(di,'yymmdd-HHMMSS')]);
    wavwrite(d2,1000,16,[fout2 datestr(di,'yymmdd-HHMMSS')]);
end

    