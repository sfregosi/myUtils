% Computes calibrated acoustic spectra from (lossless) digital audio files.

% This code accompanies the manuscript: 

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright © 2014 The Authors.

% Author: Nathan D. Merchant. Last modified 22 Sep 2014


function [A] = PG_Func(ifile,path,atype,plottype,envi,calib,ctype,Fs,Si,Mh,G,vADC,r,N,winname,lcut,hcut,tstring,metadir,writeout,disppar,welch,chunksize,batch,linlog)


    
%% READ TIME STAMP IF PROVIDED

if nargin > 17 && ~isempty(tstring)
    if ~isempty(tstring)             %if time stamp provided
    y = str2double((ifile(tstring == 'y')));    %year
    m = str2double((ifile(tstring == 'm')));    %month
    d = str2double((ifile(tstring == 'd')));    %day
    H = str2double((ifile(tstring == 'H')));    %hour
    M = str2double((ifile(tstring == 'M')));    %minute
    S = str2double((ifile(tstring == 'S')));    %second
    MS = str2double((ifile(tstring == 'F')))/1000;  %millisecond
    if isnan(MS)                    %if no milliseconds defined, MS = 0
        MS = 0;
    end
    try
        tstamp = datenum(y,m,d,H,M,S+MS);               %date in datenum format
        if disppar == 1,disp(['Time stamp start time: ' datestr(tstamp,'dd mmm yyyy, HH:MM:SS')]),end
    catch
        tstamp = [];               %date in datenum format
        disp('***ERROR: TIME STAMP FAILED***. Check tstring format and refer to Appendix 1. Proceeding with no time stamp...')
    end
    end
elseif nargin <= 17 || isempty(tstring)
    tstamp = [];
end

%% LOAD INPUT FILE

% if isempty(chunksize)
% if disppar == 1 && isempty(metadir),fprintf('Loading input file...'),end
% tic                             %Start file-read timer
% try                             %Read user-defined audio file, which MATLAB
%                                 % normalises to +/-1
%     [xbit,Fs] = audioread(fullfile(path,ifile));
% catch
%     try                         %for older MATLAB versions
%         [xbit,Fs] = wavread(fullfile(path,ifile));  
%     catch
%         disp('MATLAB could not read this as an audio file.'),return
%     end
% end
% 
% xbit = xbit(:,1);               %In case of multichannel input, selects 
%                                 %1st channel (use xDIG(:,2) for 2nd, etc.)
% tock = toc;                     %Stop file-read timer
% if disppar == 1 && isempty(metadir),fprintf([' loaded ''' ifile ''' in ' num2str(tock) ' s.\n']),end
% 
% else
%     try                         %Get sample rate
%     info = audioinfo(fullfile(path,ifile));
%     Fs = info.SampleRate;
%     xl = info.TotalSamples;
%     nchunks = ceil(xl/(Fs*chunksize));
%     for q = 1:nchunks
%         if q < nchunks
%             xbit = audioread(fullfile(path,ifile),[(q-1)*chunksize*Fs q*chunksize*Fs-1])
%         elseif q == nchunks
%             xbit = audioread(fullfile(path,ifile),[(q-1)*chunksize*Fs xl])
%         end
%     catch
%     try                         %for older MATLAB versions
%         [~,Fs] = wavread(fullfile(path,ifile));
%         xl = wavread(fullfile(path,ifile),'size');
%         xl = xl(1);
%         nchunks = ceil(xl/(Fs*chunksize));
%     for q = 1:nchunks
%         if q < nchunks
%             xbit = wavread(fullfile(path,ifile),[(q-1)*chunksize*Fs q*chunksize*Fs-1])
%         elseif q == nchunks
%             xbit = wavread(fullfile(path,ifile),[(q-1)*chunksize*Fs xl])
%         end
%     catch
%         disp('MATLAB could not read this as an audio file.'),return
%     end
%     end
% 

% end


%% USER-DEFINED SETTINGS
    % default values are for Wildlife Acoustics SM2+, though gain (G) will
    % be deployment specific

if nargin<3 || isempty(atype),
   atype = 'PSD';               %Analysis type. Options: 'PSD', 'PowerSpec' 
end                             % 'TOL', 'TOLf', 'Broadband', 'Waveform'
                                % See line 200 for definitions.
if nargin<4 || isempty(plottype),
   plottype = 'Both';           %plot RMS level instead of spectrogram 
end                             % 1 = yes, 0 = no (default = 0)                               
if nargin<5 || isempty(envi),
   envi = 'Air';                %Specify air or underwater: 'Air' or 'Wat'
end
if nargin<6 || isempty(calib),
   calib = 0;                  %Specify calibrated or uncalibrated
end
if nargin<7 || isempty(Si),
   Si = [];                     %User-defined system sensitivity
end
if nargin<8 || isempty(Mh),     %Transducer (microphone or hydrophone)
    Mh = -36;                   % sensitivity in dB re 1 V/Pa (micro), e.g.
end                             %  -36, or dB re 1 V/uPa (hydro), e.g. -165
if nargin<9 || isempty(G),
   G = 0;                       %Pre-amplifier gain in dB (default = 0)
end
if nargin<10 || isempty(vADC),
   vADC = sqrt(2);             %Zero-to-peak voltage across analog to 
end                             % digital converter (ADC) in volts, e.g. 1
if nargin<11 || isempty(r),
   r = 0.5;                     %Overlap of data segments,  e.g. 0.75 = 75%
end                             % (default = 0.5)
if nargin<12 || isempty(N),
   N = Fs;                      %Duration of data segments in samples (e.g.
end                             %  Fs/10 = 0.1 s; default = Fs = 1 second)
if strcmp(atype,'TOL') || strcmp(atype,'TOLf') && N < Fs
    N = Fs;                     %set minimum of 1 s window for TOL analysis
end
if nargin<13 || isempty(winname),
   winname = 'Hann';            %Window function name (default = 'Hann', 
end                             % also 'None','Hamming','Blackmann')
if nargin<14 || isempty(lcut),
   lcut = Fs/N;                 %low-frequency cut-off (default = lowest 
end                             % frequency bin in DFT = Fs/N)
if nargin<15 || isempty(hcut),
   hcut = Fs/2;                 %high-frequency cut-off (default = maximum 
end                             % frequency bin (Nyquist) = Fs/2)

    


%% PRINT SETTINGS TO COMMAND LINE
if disppar == 1
disp(['Analysis type: ' atype])
disp(['Plot type: ' plottype])

if calib == 0
    disp('Uncalibrated analysis. Output in relative units.')
else
    switch envi
    case 'Air'
        disp('In-air measurement.')
    case 'Wat'
        disp('Underwater measurement.')
    end
if strcmp(ctype,'EE')                %if end-to-end sensitivity selected
    disp(['End-to-end system sensitivity = ' num2str(Si) ' dB'])
elseif strcmp(ctype,'RC')            %if recorder sensitivity plus Mh is given
    disp(['System sensitivity of recorder (excluding transducer) = ' num2str(Si) ' dB'])
    switch envi
        case 'Air'
            disp(['Microphone sensitivity, Mh = ' num2str(Mh) ' dB re 1 V/Pa'])
        case 'Wat'
            disp(['Hydrophone sensitivity, Mh = ' num2str(Mh) ' dB re 1 V/uPa'])
    end
elseif strcmp(ctype,'TS')            %if manufacturer's specifications are given
    switch envi
        case 'Air'
            disp(['Microphone sensitivity, Mh = ' num2str(Mh) ' dB re 1 V/Pa'])
        case 'Wat'
            disp(['Hydrophone sensitivity, Mh = ' num2str(Mh) ' dB re 1 V/uPa'])
    end
    disp(['Preamplifier gain, G = ' num2str(G) ' dB'])
    disp(['ADC peak voltage, vADC = ' num2str(vADC) ' V'])
end
end
disp(['Sampling frequency, Fs = ' num2str(Fs) ' Hz'])
disp(['Time segment length: ' num2str(N) ' samples = ' num2str(N/Fs) ' s'])
disp(['Window function: ' winname])
disp(['Time segment overlap: ' num2str(r*100) ' %'])
if ~isempty(welch)
   fprintf(['Welch factor = ',num2str(welch),'x\nNew time resolution = ',num2str(welch),' (Welch factor) x ',num2str(N/Fs),' s (time segment length) x ',num2str(r*100),' %% (overlap) = ',num2str(welch*r*N/Fs),' s\n'])
end
end
if strcmp(envi,'Air')
    Mh = Mh - 120;              %convert to dB re 1 V/uPa
end

%% DEFINE SYSTEM SENSITIVITY if selected-----------------------------------

if calib == 1
if strcmp(ctype,'EE')           %if end-to-end sensitivity is given
	S = Si;
elseif strcmp(ctype,'RC')       %if recorder sensitivity plus Mh is given
    S = Si + Mh;
elseif strcmp(ctype,'TS')       %if manufacturer's specifications are given
    S = Mh + G + 20*log10(1/vADC);
end                             %EQ. 4. Last term omitted as MATLAB 
                                % normalises amplitude to +/-1 (see Section
                                % 3 of Appendix S1)
if disppar == 1,disp(['System sensitivity correction factor, S = ' sprintf('%.01f',S) ' dB']),end
else
    S = 0;
end



%% COMPUTE USER-SPECIFIED SOUND LEVEL METRIC
if ~isempty(metadir),disppar = 0;end

if isempty(chunksize)           %if reading whole file at once
    
if disppar == 1 && isempty(metadir),fprintf('Loading input file...'),end
tic                             %Start file-read timer
try                             %Read user-defined audio file, which MATLAB
                                % normalises to +/-1
    [xbit,Fs] = audioread(fullfile(path,ifile));
catch
    try                         %for older MATLAB versions
        [xbit,Fs] = wavread(fullfile(path,ifile));  
    catch
        disp('MATLAB could not read this as an audio file.'),return
    end
end

xbit = xbit(:,1);               %In case of multichannel input, selects 
                                %1st channel (use xDIG(:,2) for 2nd, etc.)
tock = toc;                     %Stop file-read timer
if disppar == 1 && isempty(metadir),fprintf([' loaded ''' ifile ''' in ' num2str(tock) ' s.\n']),end
    
switch atype
    case 'Waveform'             %pressure waveform
        [A] = PG_Waveform(xbit,Fs,S,tstamp,calib,disppar);
    case 'PSD'                  %power spectral density
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstamp,disppar);
    case 'PowerSpec'            %power spectrum (for tonal amplitudes)
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstamp,disppar);
    case 'TOLf'                  %standard TOL implementation using filters
        [A] = PG_TOL(xbit,S,Fs,N,envi,lcut,hcut,tstamp);
    case 'TOL'                 %fast TOL implementation using DFT
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstamp,disppar);
    case 'Broadband'            %broadband level
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstamp,disppar);
    otherwise                   %catch typos
        fprintf('\n ''atype'' not recognised: cehck spleling. PAMGuide aborted.\n')
        return
end

elseif ~isempty(chunksize)      %if reading file piecewise
    try                         
    info = audioinfo(fullfile(path,ifile));
    Fs = info.SampleRate;
    xl = info.TotalSamples;
    nchunks = ceil(xl/(Fs*chunksize));
    vers = 0;
    catch
    try                         %for older MATLAB versions
        [~,Fs] = wavread(fullfile(path,ifile));
        xl = wavread(fullfile(path,ifile),'size');
        xl = xl(1);
        nchunks = ceil(xl/(Fs*chunksize));
        vers = 1;
    catch
        disp('MATLAB could not read this as an audio file.'),return
    end
    end
    for q = 1:nchunks
        if q < nchunks
            if vers == 0
                xbit = audioread(fullfile(path,ifile),[(q-1)*chunksize*Fs+1 q*chunksize*Fs]);
            elseif vers == 1
                xbit = wavread(fullfile(path,ifile),[(q-1)*chunksize*Fs+1 q*chunksize*Fs]);
            end
        elseif q == nchunks
            if vers == 0
                xbit = audioread(fullfile(path,ifile),[(q-1)*chunksize*Fs+1 xl]);
            elseif vers == 1
                xbit = wavread(fullfile(path,ifile),[(q-1)*chunksize*Fs+1 xl]);
            end
        end
        if ~isempty(tstamp)
            tstampchunk = tstamp + datenum(0,0,0,0,0,(q-1)*chunksize);
        else
            tstampchunk = [];
        end
    xbit = xbit(:,1);           %In case of multichannel input, selects 1st channel
    switch atype
    case 'Waveform'             %pressure waveform
        [A] = PG_Waveform(xbit,Fs,S,tstampchunk,calib,0);
    case 'PSD'                  %power spectral density
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstampchunk,0);
    case 'PowerSpec'            %power spectrum (for tonal amplitudes)
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstampchunk,0);
    case 'TOLf'                  %standard TOL implementation using filters
        [A] = PG_TOL(xbit,S,Fs,N,envi,lcut,hcut,tstampchunk);
        r = 0;                  %overlapping time segments not supported for this analysis
    case 'TOL'                 %fast TOL implementation using DFT
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstampchunk,0);
    case 'Broadband'            %broadband level
        [A] = PG_DFT(xbit,Fs,S,N,r,winname,envi,lcut,hcut,atype,tstampchunk,0);
    otherwise                   %catch typos
        fprintf('\n ''atype'' not recognised: cehck spleling. PAMGuide aborted.\n')
        return
    end
    
    if q == 1
        newA = A;
        fprintf([num2str(nchunks) ' chunks. Analysing chunk 1'])
    elseif q > 1
        if isempty(tstamp)
            A(:,1) = A(:,1) + (q-1)*chunksize;
        end
        newA = [newA;A(2:length(A(:,1)),:)];
        fprintf([' ' num2str(q)])
    end

    end
    fprintf('\n')
    A = newA;
end
clear xbit newA

%% REDUCE TIME RESOLUTION BY WELCH METHOD IF SELECTED

% Welch method (corresponds to EQUATION 20)
if ~isempty(welch)
[rA,cA] = size(A);                               %number of rows in array
lout = ceil(rA/welch)+1;                        %length of output array                                
AWelch = zeros(lout,cA);                        %initialize output array
AWelch(1,:) = A(1,:);                           %initialize freq. column 
tint = A(3,1) - A(2,1);                         %time window interval

if lout == 2
    if batch == 1
        AWelch(2,:) = 10*log10(mean(10.^(A(2:rA,:)./10)));
    elseif batch == 0
        disp('Reduction in time resolution longer than 1/2 the file. Reduce factor or deselect ''Reduce time resolution''.')
        return
    end
else
for i = 2:lout
        stt = A(2,1) + (i-2)*tint*welch;            %start time
        ett = stt + welch*tint;                     %end time
        sti = find(A(2:rA,1) >= stt,1,'first')+1;    %find start index
        eti = find(A(2:rA,1) < ett,1,'last')+1;      %find end index
        nowA = 10.^(A(sti:eti,2:cA)./10);          %data in linear units
        if length(nowA(:,1))>1
            AWelch(i,2:cA) = 10*log10(mean(nowA));     %write mean to new array
        elseif length(nowA(:,1)) == 1
            AWelch(i,2:cA) = 10*log10(nowA);        %if only one window in range
        else
            AWelch(i,2:cA) = NaN;
        end
        AWelch(i,1) = stt;                      %stamp with start time
end
end
A = AWelch(~isnan(AWelch(:,2)),:);                                     %reassign output as Welch array
clear AWelch
end

% Scale relative analyses to 0 dB
if calib == 0
    [rA,cA] = size(A);
    if strcmp(atype,'Waveform')
        A(:,2) = A(:,2)./max(abs(A(:,2)));       %if uncalibrated, scale relative pressure to +/- 1
    else
        A(2:rA,2:cA) = A(2:rA,2:cA) - max(max(A(2:rA,2:cA)));
    end
end

%% ENCODE TIME-DOMAIN ARRAY WITH ANALYSIS METADATA

aid = 0;
switch atype
    case 'PSD',aid = aid + 1;
    case 'PowerSpec',aid = aid + 2;
    case 'TOL',aid = aid + 3;
    case 'Broadband',aid = aid + 4;
    case 'Waveform',aid = aid + 5;
    case 'TOLf',aid = aid + 3;
end
if calib == 1,aid = aid + 10;else aid = aid + 20;end
if strcmp(envi,'Air'), aid = aid + 100;else aid = aid + 200;end
if ~isempty(tstamp), aid = aid + 1000;else aid = aid + 2000;end
A(1,1) = aid;


%% PLOT DATA, INCLUDING STATS IF SELECTED

PG_Viewer(A,plottype,ifile,linlog)


%% OUTPUT TIME-DOMAIN ARRAY IN CSV FORMAT



if writeout == 1
if disppar == 1,fprintf('Writing output file...'),end
tic
if strcmp(atype,'Waveform')
    ofile = [ifile(1:length(ifile)-4) '_' atype '.csv'];
else
    ofile = [ifile(1:length(ifile)-4) '_' atype '_' num2str(N/Fs) 's' ...
    winname 'Window_' num2str(round(r*100)) 'PercentOverlap.csv'];
end
if isempty(metadir)        %if not batch processing
    if ~isempty(tstamp)
        dlmwrite(fullfile(path,ofile),A,'precision',15,'delimiter',',');
    else
        dlmwrite(fullfile(path,ofile),A,'precision',9,'delimiter',',');
    end
else
    if ~isempty(tstamp)
        dlmwrite(fullfile(path,metadir,ofile),A,'precision',15,'delimiter',',');
    else
        dlmwrite(fullfile(path,metadir,ofile),A,'precision',9,'delimiter',',');
    end
end
tock = toc;
if disppar == 1,fprintf(['''' ofile ''' written in ' num2str(tock) ' s.\n']),end
end

return                                  %END PAMGuide


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Supplement: Impulse metrics, sound exposure level, and the Welch method

%correct for system sensitivity
x = xbit/(10^(S/20));                           %EQUATION 21

% Peak-to-peak SPL
SPLpp = 10*log10((1/(pref^2))*(max(x)+abs(min(x))).^2);  
                                                %EQUATION 22

% Zero-to-peak SPL
SPL0p = 10*log10((1/(pref^2))*max(x.^2));       %EQUATION 23


% Broadband SEL
SEL = 10*log10((1/(pref^2))*sum(sum(Pss)))-S;  	%EQUATION 25

