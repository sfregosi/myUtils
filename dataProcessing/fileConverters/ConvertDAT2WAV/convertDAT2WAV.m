clear all;
clc;

inDir = 'C:\Users\fregosi\Documents\MATLAB\ConvertDAT2WAV\';
outDir = 'C:\Users\fregosi\Documents\MATLAB\ConvertDAT2WAV\';

% Get geo location (East, West, etc.)
geoLoc = 'RWM1';

% parpool command is in parallel commputing toolbox. Check if you ahve that
% ver
% look for it, loook at which version. 
% parpool started in 2013b, prior to that it was matlabpool
% im running 2013a, so im going to use that. 

% parpool(4)
%matlabpool(4)
%i got admin warnings but I just clicked ok and it went through

files = dir([inDir '*.DAT']);

for i = 1 : length(files)
% parfor i = 1 : length(files)
  [sams,nChans,sampleSize,sRate,nLeft,dt,endDt] = ...
  haruIn([inDir '/' files(i).name]);
  % note: endDt seems to be wrong!
  sams2=sams-median(sams);
  sams3=sams2/(2^16/2);
  [yr,mon,day,hr,mn,sec] = datevec(dt);

  outfile = sprintf('%s%s-%02d%02d%02d-%02d%02d%02d.wav', outDir, geoLoc, ...
  mod(yr,100), mon, day, hr, mn, round(sec));

  audiowrite(outfile, sams3, sRate);
  disp([datestr(now) ': file ' num2str(i) ' out of ' num2str(length(files)) ' analyzed']);
end
