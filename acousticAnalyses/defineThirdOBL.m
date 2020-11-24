function [lowerF upperF] = defineThirdOBL(centerFreq)
% Calculate the upper and lower limits of a third octave band with a given
% center frequency

%
lowerF = centerFreq/sqrt(2^(1/3)); %1/3 octave band
upperF = centerFreq*sqrt(2^(1/3)); % 1/3 octave band
bw = [lowerF centerFreq upperF];

end
