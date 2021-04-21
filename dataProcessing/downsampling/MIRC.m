clear all
clc
warning('off')

path='H:\GoA_Jul15\sg203\PAM\';
path_out1='I:\sg203-HF-194kHz\';
path_out2='I:\sg203-MF-10kHz\';
path_out3='I:\sg203-LF-1kHz\';

fs1=10000;
fs2=1000;

folder=dir(path);

for i=3:length(folder)
    files=dir([path folder(i,1).name '\*.flac']);
    
    parfor j=1:length(files)
         try
            [data,fs,bits] = flacread([path folder(i,1).name '\' files(j,1).name]);
            t1=datenum(files(j,1).name(6:end-5),'yymmdd_HHMMSS');
            chk=files(j,1).bytes/length(data);
            
            if chk>1.5
                disp(['Problem reading file: ' folder(i,1).name '\' files(j,1).name]);
            end
            
            data1=resample(data,fs1,fs);
            data2=resample(data,fs2,fs);
            
            wavwrite(data,fs,bits,[path_out1 files(j,1).name(6:end-12) '-' files(j,1).name(13:end-5) '.wav']);
            wavwrite(data1,fs1,bits,[path_out2 files(j,1).name(6:end-12) '-' files(j,1).name(13:end-5) '.wav']);
            wavwrite(data2,fs2,bits,[path_out3 files(j,1).name(6:end-12) '-' files(j,1).name(13:end-5) '.wav']);
            
            disp([datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' processed']);
         catch
             disp(['Attention: ' datestr(now) ': ' folder(i,1).name ' file: ' files(j,1).name ' corrupt']);
         end
    end
end