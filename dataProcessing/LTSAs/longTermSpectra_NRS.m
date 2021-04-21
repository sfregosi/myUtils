% script modified by J. Haxel May 2015 to calculate the long-term time
% averaged spectra of acoustic signals at NRS
% system response = (preAmp + instResp)  is removed and energy values are
% normalized to dB re 1uPa @ 1m
%
% CF2 data - need to use *CF2*.m for all subroutines 
%
% data info
%c
if(1)
  datadir = '\\ACOUSTIC\data\ONRSN\Samoa\2016-2017\';
  locname = 'NRS10';
  fnums = 1:49999;                  
  chan = 1;a
  frameSize = 5000;    
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS10-2016-2017.txt'; 
elseif(0)
  datadir = '\\ACOUSTIC\data\ONRSN\NRS09\2016-2017\';
  locname = 'NRS09';
  fnums = 1:1750;                  
  chan = 1;
  frameSize = 5000;    
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS09-2016-2017.txt'; 
elseif(0)
  datadir = '\\BIOAC3\datasilo\GLBA\2015\HC-07-Bruise-East\';
  locname = 'HC-07-Bruise-East';
  fnums = 1:3782;                   % Haru-file numbers
  chan = 1;
  frameSize = 10000;         % for 1Hz resolution @ 5000Hz sample rate
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\file_dates-HC-07-Bruise-East-2015.txt'; 
elseif(0)
  datadir = '\\ACOUSTIC\data\ONRSN\NRS04\2015-2016\'; %'\\ACOUSTIC\data\ONRSN\NRS02\2014-2015'; %'T:\ONRSN\NRS10\2015-2016\' ; 
  locname = 'NRS04';
  fnums = 1:3136;                   % Haru-file numbers
  chan = 1;
  frameSize = 5000;         % for 1Hz resolution @ 5000Hz sample rate
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS04-2015-2016.txt'; 
elseif(0)
  datadir = '\\ACOUSTIC\data\ONRSN\NRS11\2015-2017\'; %'\\ACOUSTIC\data\ONRSN\NRS02\2014-2015'; %'T:\ONRSN\NRS10\2015-2016\' ; 
  locname = 'NRS11';
  fnums = 0:4335;                   % Haru-file numbers
  chan = 1;
  frameSize = 5000;         % for 1Hz resolution @ 5000Hz sample rate
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS11-2015-2017.txt'; %C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS02-2014-2015.txt';
elseif(0)
  datadir = 'V:\NRS11\2015-2017\'; %V:\NRS11\2015-2017' %'\\ACOUSTIC\data\ONRSN\NRS02\2014-2015'; %'T:\ONRSN\NRS10\2015-2016\' ; 
  locname = 'NRS11';
  fnums = 0:4335;                   % Haru-file numbers
  chan = 1;
  frameSize = 5000;         % for 1Hz resolution @ 5000Hz sample rate
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS11-2015-2017.txt'; %C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS02-2014-2015.txt';
elseif(0)
  datadir = 'T:\ONRSN\NRS06\2014-2015\' %'\\ACOUSTIC\data\ONRSN\NRS02\2014-2015'; %'T:\ONRSN\NRS10\2015-2016\' ; 
  locname = 'NRS06';
  fnums = 1:3552;                   % Haru-file numbers
  chan = 1;
  frameSize = 5000;         % for 1Hz resolution @ 5000Hz sample rate
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS06-2014-2015.txt'; %C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS02-2014-2015.txt';
elseif(0)
  datadir = '\\ACOUSTIC\data\ONRSN\NRS10\2015-2016\'; %'T:\ONRSN\NRS10\2015-2016\' ; 
  locname = 'NRS10';
  fnums = 0:1775;                   % Haru-file numbers
  chan = 1;
  frameSize = 5000;         % for 1Hz resolution @ 5000Hz sample rate
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS10-2015-2016.txt';
elseif (0)
  datadir = '\\ACOUSTIC\data\ANT\RossSea2014\H-11\';
  locname = 'RossSea';
  fnums = 0:739;                   % Haru-file numbers
  frameSize = 1000;         % for 1Hz resolution @ 1000Hz sample rate
  fdates = 'C:\haxel\DATAFILE_INDEX\ROSS_SEA\file_dates-H-11-RossSea2014.txt';
elseif (0)
  datadir = '\\ACOUSTIC\gloc\Oregon_Coast\SETS_lander\REEF_AprJul2014\';
  locname = 'reef';
  sRate = 32000;             % sample rate
  fnums = 0:5552;            % Haru-file numbers
  frameSize = 32000;         % for 1Hz resolution @ 32000Hz sample rate
  fdates = 'C:\haxel\DATAFILE_INDEX\PMEC_SETS\file_dates-SETSreef-Lander2014.txt';
elseif (0)
  datadir = 'E:\sg639\wav\sg639-1kHz\';
  locname = 'GoMex';
  fnums = 1:49999;                  
  chan = 1;
  frameSize = 1000;    
  fdates = 'C:\Users\haver\Documents\DATAFILE_INDEX\ONRSN\file_dates-NRS10-2016-2017.txt'; 
end
  %
% Parameters for time averaging and start/stop times
period =  5/1440 %1/24 %5/1440   %hourly =1/24 %600/(60*60*24);	% 600 sec in days
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
else
  fn0 = sprintf('%s%08d.DAT', datadir, fnums(1));
  fn1 = sprintf('%s%08d.DAT', datadir, fnums(end));
end
[dtv0,yr,jd,hr,mn,sc,sRate,t,y]=readCF2hdr(fn0,0);
[dtv1,yr,jd,hr,mn,sc,sRate,t,y]=readCF2hdr(fn1,0);
%
%
if (ischar(baseyear) && strcmp(baseyear, 'auto'))
  baseyear = sub(datevec(dtv0), 1);	% new dt encoding from soundIn
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
  printf('%d dots:', nCols(gram))
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
      xt = haruSoundAtTime_CF2([t0 t1], hIndex, datadir);   %note - calling CF2 specific routine
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %xt_2 = xt{1}; %xt_3 = xt_2(:,1); %extra step do to 2 channel data 
      %x_mn = xt_3 - mean(xt_3);     %have to do this in 2 steps now because 2 channel data
      x_mn = xt{1} - mean(xt{1});  %remove the sample mean from the chunk of data for 16bit
      x = (2.5/(2^16)).*x_mn;     % convert to Volts by (Voltrange/bitrange)- for 16bit 
      %x = (4/(2^12)).*x_mn;     %convert to Volts -12bit
      g = joespect_LTacoustic(x, frameSize, nOverlap, zeroPad, 'hann', 5000);  %5000 for sample rate
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
%
%cd E:\ROSS_SEA-2014
%cd C:\haxel\OCEAN_NOISE\YAQ_HEAD\
%cd C:\haxel\LAU_BASIN\ANALYSIS\MATAS
%%
cd C:\Users\haver\Documents\NRS\NRS10\LTSA

save NRS10_20162017_5minAvgSpect_cal070118 gram dt0 dt1 frameSize sRate

%