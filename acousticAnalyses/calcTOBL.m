function [Lxf, SLf, f, bw, fr, tr,] = calcTOBL(fName,centerFreq,win,overlap,plotOn)
% Calculate 1/3 octave band noise levels RMS over duration of signal (need
% to audioread in the file already - this is diff from calcThirdOBL.m
%
%   Inputs:
%           sig = signal
%           fs = sampling rate
%           centerFreq = center frequency for 1/3 octave band
%           win = window size
%           overlap = overlap samples
%           plotOn = 1 for plot, 0 for no plot
%
%   Outputs:
%           Lxf = RMS noise level of filtered signal
%           SLf = spectrum levels of filtered signal
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

if nargin < 5
    plotOn = 0;
end

%
lowerF = centerFreq/nthroot(2,3); %1/3 octave band
upperF = centerFreq*nthroot(2,3); % 1/3 octave band
bw = [lowerF centerFreq upperF];

nfft = win;

[x, fs] = audioread(fName);
t = (1:length(x))/fs;
fr = fs/win; % in Hz
tr = win/fs; % in s

[SL,f] = speclev(x,win,fs); % not sure I want these as an output

% filter to 1/3 octave band - butterworth.
f_low10 = lowerF;
f_high10 = upperF;
% 4-pole butterworth
[b1,a1] = butter(4,[f_low10,f_high10]/(fs/2));
% apply the filter
xf = filter(b1,a1,x);

% calculate the spectrum level of the filtered signal
[SLf,f] = speclev(xf,win,fs);

% measure RMS noise level of the full signal and the filtered signal
Lxf = 20*log10(std(xf));
Lx = 20*log10(std(x));

if plotOn == 1;
    figure
    hold on
    % subplot(121)
    plot(f,SL,'r')
    % subplot(122)
    plot(f,SLf,'b')
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
    spectrogram(x,win,overlap,win,fs,'yaxis')
    subplot(212)
    spectrogram(xf,win,overlap,win,fs,'yaxis')
end

end
