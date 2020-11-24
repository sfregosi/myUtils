function [y, yf, SLcal, SLfcal, bw, fr, tr] = ...
    filterThirdOBL(fName,centerFreq,win,overlap,filtOrder,sysSensFile,plotOn)
% 
% DONT USE IN PRACTICE!!!!
%
% Apply third-octave band pass specified-order butter filter on a single
% file and calculate spectrum levels of filtered signal
% uses speclev_wispr to get levels
%
% pay attention to target center frequency compared to sampling rate and
% filter order because the filter may be too tight for high sampling 
% rate data. 
%
%   Inputs:
%           fName = sound file;
%           centerFreq = center frequency for 1/3 octave band
%           win = window size
%           overlap = overlap samples
%           filtOrder = filter order
%           sysSensFile = link to system sensitivity file if you want
%           calibrated levels in output. 
%           plotOn = 1 for plot, 0 for no plot
%
%   Outputs:
%           yf = filtered signal
%           SLfcal = spectrum levels of filtered signal, calibrated (if
%           sysSensFile exists)
%           f = frequency bands
%           bw = octave bandwidth
%           fr = frequency resolution
%           tr = time resolution

%
% % for testing
% centerFreq = 40; % Hz
% fName = 'G:\score\2015\data\sg158-LF-1kHz\160102-060428.wav';
% win = 512;
% overlap = win*0.5;

if nargin < 7
    plotOn = 0;
end

if nargin <6
    sysSensFile 
%
lowerF = centerFreq/sqrt(2^(1/3)); %1/3 octave band
upperF = centerFreq*sqrt(2^(1/3)); % 1/3 octave band
bw = [lowerF centerFreq upperF];

nfft = win;

[y, fs] = audioread(fName);
t = (1:length(y))/fs;
fr = fs/win; % in Hz
tr = win/fs; % in s

[SL,SLcal,f] = speclev_wispr(y,nfft,fs,win,overlap,sysSensFile); % not sure I want these as an output

% filter to 1/3 octave band - butterworth.
% I did this setting to downsampled data 1 kHz. PICK BANDS. 
f_low10 = lowerF;
f_high10 = upperF;
% 4-pole butterworth
[b1,a1] = butter(filtOrder,[f_low10,f_high10]/(fs/2));
% apply the filter
yf = filter(b1,a1,y);

% calculate the spectrum level of the filtered signal
[SLf,SLfcal,f] = speclev_wispr(yf,nfft,fs,win,overlap,sysSensFile);

if plotOn == 1
    figure
    hold on
    % subplot(121)
    plot(f,SLcal,'r')
    % subplot(122)
    plot(f,SLfcal,'b')
    grid
    set(gca,'XScale','log')
    legend('unfiltered',sprintf('butterworth\n cF: %iHz',centerFreq))
    xlabel('frequency, kHz')
    ylabel('power, dB re V^2/Hz')
    title('spectrum levels')
    xlim([10 fs/2])
    hold off
    
    figure;
    subplot(211)
    spectrogram(y,win,overlap,win,fs,'yaxis')
    subplot(212)
    spectrogram(yf,win,overlap,win,fs,'yaxis')
end

end
