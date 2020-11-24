function [BL, bw] = calcBandLevel(psdNoise,lowerFreq,upperFreq)

% calculate band levels for noise on calibrated data (from a calibrated PSD) 
%
%   Inputs:
%           psdNoise - a psd matrix (used calcPSD to get calibrated values)
%                       in units dB re 1 uPa/Hz
%           lowerFreq - define for band of interest
%           upperFreq - define for band of interest
%
%   Outputs:
%           BL - band level noise in dB re 1 uPa
%           bw - bandwidth of [lowerFreq upperFreq]


% back calculate pressure from PSD
noisePres = 10.^(psdNoise/10);
% sum levels at 1Hz resolution between band limits
presSum = sum(noisePres(lowerFreq+1:upperFreq+1); % +1 bc freq starts at 0.
% back to dB
BL = 10*log10(presSum);

bw = [lowerFreq upperFreq];

end
