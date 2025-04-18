% script modified by J. Haxel May 2015 to calculate the long-term time
% averaged spectra of acoustic signals at NRS
% system response = (preAmp + instResp)  is removed and energy values are
% normalized to dB re 1uPa @ 1m
%
% CF2 data - need to use *CF2*.m for all subroutines 
%
% data info
%c
if (1)
  datadir = 'E:\sg639\wav\sg639-1kHz\';
  locname = 'GoMex';
  fnums = 1:49999;                  
  chan = 1;
  frameSize = 1000;    
  fdates = 'E:\sg639\wav\sg639-1kHz\file_dates-sg639_GoMex_May18-1kHz.txt'; 
  sRate = 1000;
elseif(0)
    
end
  %
% Parameters for time averaging and start/stop times
period =  1/86400; %5/1440 %1/24 %5/1440   %hourly =1/24 %600/(60*60*24);	% 600 sec in days
baseyear = 'auto';         % auto means get it from first day of data
zeroPad = 0;            % zero-pad the signal
nOverlap = 0;           % overlap data points
%
%%%%%%%%%%%%%%%%%%%%%%% Configure data Grab %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
hIndex = readHarufileDateIndex(fdates);
if (0)      %change for the old format of datafile
  fn0 = sprintf('%sdatafile.%03d', datadir, fnums(1));
  fn1 = sprintf('%sdatafile.%03d', datadir, fnums(end));
elseif (0)
  fn0 = sprintf('%s%08d.DAT', datadir, fnums(1));
  fn1 = sprintf('%s%08d.DAT', datadir, fnums(end));
else
    fn0 = [datadir hIndex.hname{1}(3:end)];
    fn1 = [datadir hIndex.hname{end}(3:end)];
end
% NOT NEEDED FOR WORKING WITH WAV FILES
% [dtv0,yr,jd,hr,mn,sc,sRate,t,y]=readCF2hdr(fn0,0);
% [dtv1,yr,jd,hr,mn,sc,sRate,t,y]=readCF2hdr(fn1,0);
dtv0 = hIndex.time(1);
dtv1 = hIndex.time(end);
%
if (ischar(baseyear) && strcmp(baseyear, 'auto'))
%   baseyear = sub(datevec(dtv0), 1);	% new dt encoding from soundIn
baseyear = sub(datevec(hIndex.time(1)), 1);
end
%
% Get start and stop times that include only whole intervals.
dt0 =  ceil(dtv0/period) * period;	% get start of first whole period
dt1 = floor(dtv1/period) * period;	% get end   of last  whole period
%
% get the system response to subtract out of power vaues later
%[SR] = get_sys_response(PA_rev,gain,filt_sw,sRate,frameSize);
%[SR] = get_sys_response(9,0,4,double(sRate),frameSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%% Start the loop for calculating LTSpect %%%%%%%%%%%%%%
%
if (1)
  gram = zeros((frameSize+zeroPad)/2, round((dt1-dt0)/period));
  fRate = sRate / (frameSize - nOverlap);
  printf('%d bins:\n', nCols(gram))
  for i = 1 : nCols(gram)
      fprintf(1,'.%s', iff(mod(i,60) == 0, char(10), ''));
    dt = dt0 + (i-1) * period;
% Do around 1 million samples at a time.
    t0 = dt;
    gSum = zeros((frameSize+zeroPad)/2, 1);
    ng = 0;
%    while (t0 < dt + period)
      %t1 = min([dt+period double(t0+1e6/sRate/24/60/60)]); %for big AVG's
      t1 = dt + period;
      %xt = haruSoundAtTime_CF2_2channel([t0 t1], hIndex, datadir, chan);
%       xt = haruSoundAtTime_CF2([t0 t1], hIndex, datadir);   %note - calling CF2 specific routine
      xt = haruSoundAtTime_sf([t0 t1], hIndex, datadir);  

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %xt_2 = xt{1}; %xt_3 = xt_2(:,1); %extra step do to 2 channel data 
      %x_mn = xt_3 - mean(xt_3);     %have to do this in 2 steps now because 2 channel data
      x_mn = xt{1} - mean(xt{1});  %remove the sample mean from the chunk of data for 16bit
      x = (2.5/(2^16)).*x_mn;     % convert to Volts by (Voltrange/bitrange)- for 16bit 
      %x = (4/(2^12)).*x_mn;     %convert to Volts -12bit
      g = joespect_LTacoustic(x, frameSize, nOverlap, zeroPad, 'hann', sRate); %5000 for sample rate
      
%       [g,f,t] = spectrogram(x,hann(frameSize),nOverlap,frameSize,sRate); 
%       g = abs(g(2:end));
      % last input on line above is sample rate
      if (nCols(g) == 0), break; end   % skip partial frame at end of day
      gSum = gSum + mean(g,2);   % sum up the energy - will divide later
      ng = ng + nCols(g);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %t0 = t0 + nCols(g)/.9765624 / 24/60/60; %have to change this to make it run m10 hickup - 
      t0 = t0 + nCols(g) / fRate / 24/60/60;  %change back to this
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%    end
    grm = 10*log10(gSum);    %to convert power to dB
    % 
      %GRAM = grm - SR';
    %
    %gram(:,i) = GRAM;  %must add this in to get system response removed   
    gram(:,i) = grm;
    %
%
  end
  fprintf(1, '\n');
end
% remove the system gain from the spectra
%LTgram = gram - repmat(SR',1,length(gram(1,:)));

%%
save([datadir 'sg639_GoMex_May18-1kHz-LTSA_1Hz1s.mat'],'gram','dt0','dt1','frameSize','sRate');

%