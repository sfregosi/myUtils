%output is in samples
%env = envelope of the channel used for peak detection
%threshold = threshold measured on env
%min_ipi = minimum time between calls in ms.
%fs = samplerate
%min_time in ms.
%max_time in ms.

function [peaktime] = peak_detection(env,threshold,min_ipi,fs,min_time,max_time)
I = (find(env > threshold));                             
i = [0,I',0];
for n = 2:length(i);
    if i(n-1) + fs*min_ipi/1000 > i(n);
        x(n) = 0;
    else x(n) = i(n);
    end
end
index = find(x);
X = x(index);                                                 
XX = X(find(X < max_time*fs/1000 & X > min_time*fs/1000));
peaktime = XX;                                                
end
