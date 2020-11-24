function [sampledelay] = rcorr(segment,mdlch,thr)
% Determine the time-delay "sampledelay" of sound between multiple channels on a recording containing reflections. 
%
% [sampledelay] = rcorr(segment,mdlch,thr)
%
%
%       segment - contains the sound on different channels
%
%       mdlch - is the channel used as a model to determine the time delay e.g. 2
%
%       thr - is the threshold used for finding multiple peaks in the
%       crosscorrelation, it referes to the fraction below the level of the peak,
%       i.e. a thr of 3 means that peaks as low as maxpeak / 3 are included
mcseg = abs(hilbert(xcorr(segment(:,mdlch),segment(:,mdlch))));
[v,mdlloc] = max(mcseg);

[mdlpks mdlpkloc] = findpeaks(mcseg);
mpks = mdlpkloc(find(mdlpks > v/thr));

if length(mpks) == 1
    for n = 1:length(segment(1,:))
        cseg = abs(hilbert(xcorr(segment(:,n),segment(:,mdlch))));
        [v,l] = max(cseg);
        sampledelay(n) = l-mdlloc;
    end
else
    delay = mean(diff(mpks));
    pks = NaN(4,length(segment(1,:)));

    for n = 1:length(segment(1,:))
        cseg = abs(hilbert(xcorr(segment(:,n),segment(:,mdlch))));
        [v,l] = max(cseg);
        [vp,vl] = findpeaks(cseg);
        if  length(vl(find(vp > v/thr))) > 4
            pks(1:4,n) = l;
        else
            pks(1:length(find(vp > v/thr)),n) = vl(find(vp > v/thr));
        end
        clear vp vl
    end
    sumpks = cumsum(diff(pks));

    [peakval peaklocation] = min(abs(sumpks-delay));

    peaklocation = peaklocation+1;

    for n = length(segment(1,:)):-1:1
        sampledelay(n) = pks(peaklocation(n),n)-mdlloc;
    end

end