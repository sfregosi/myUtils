function [noise, noiseCI, frq] = createPSD(fname)
% function to read in single sound file and export PSD, NOT adjusted for
% system sensitivity. Basically just run's pwelch with my "standard"
% settings 
% 
% modified from Haru's
%
% inputs:
%       instrument = i.e. q1, q2, sg
%       fname = filename of sound file, ideally build this to loop through
%       ALL files for an instrument
%               If fname is not included when function is called, it will
%               prompt you to choose a file.
%
% outputs:
%       meta = metadata for file - time, location, depth, instrument
%       noise = PSD values in dB re 1\muPa^2/Hz
%       frq = frequencies in Hz
%       output = single vector (horizontal) with levels + info
%                   I will eventually vertcat these into a single matrix,
%                   so perhaps could build that in here later, but for now
%                   do one row at a time

% config
%       inputs I need for writing the function
% instrument = 'q1';
% fname = 'F:\score\2015\data\q001\wispr_151230_212400.flac';

if nargin<1
    % if exist('fname','var') == 0
    [fileExt, dpath, filterindex] = uigetfile('G:\score\2015\data\*.wav', ...
        'Pick a sound file');
    fname = fullfile(dpath,fileExt);
    [~,file,~] = fileparts(fname);
else
    [~,file,~] = fileparts(fname);
end

% load sound file
[sig, fs] = audioread(fname); % sig is normalized from -1 to 1 in VOLTS

% adjust by vref and remove DC offset
% vref = 5.0; % Haru's setting
% sig = vref * sig;
avg=mean(sig);
sig=sig-avg; %remove DC

% *** CONFIGURE PWELCH ***
freq_res = 1; %Hz % Haru's setting = 50
window = (fs/freq_res); % Haru's setting
noverlap = 0; %window/2; % Haru's setting?
nfft = window; 
% *** END PWELCH CONFIGUREATION ***


% cacluate Welch's power spectral density estimate
[pxx,frq,pxxc] = pwelch(sig,hanning(window),noverlap,nfft,fs,'ConfidenceLevel',0.9);
% [pxx,frq,pxxc] = pwelch(sig,rectwin(window),noverlap,nfft,fs,'ConfidenceLevel',0.9);

noise = 10*log10(pxx); % 10*log10 because its POWER
noiseCI = 10*log10(pxxc);

