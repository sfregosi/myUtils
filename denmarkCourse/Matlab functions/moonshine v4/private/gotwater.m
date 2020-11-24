% seg = signal segment containing the call on all channels
% modelchanne = modelchannel
% cross_thr = how far below highest hilber(cross) to accept additional
% peaks i.e. peakval/cross_thr


function [time] = gotwater(seg,modelchannel,cross_thr)


for m = 1:length(seg(1,:))
    cross = xcorr(seg(:,modelchannel),seg(:,m));
modelcross = xcorr(seg(:,modelchannel),seg(:,modelchannel));
autocross = xcorr(seg(:,m),seg(:,m));


cross_env = abs(hilbert(cross));
modelcross_env = abs(hilbert(modelcross));
autocross_env = abs(hilbert(autocross));

[peakval peaksample(m)] = max(cross_env);

te = find(cross_env > max(cross_env)/cross_thr);
modelte = find(modelcross_env > max(modelcross_env)/cross_thr);
autote = find(autocross_env > max(autocross_env)/cross_thr);


[pks,locs] = findpeaks(cross_env(te));
[modelpks,modellocs] = findpeaks(modelcross_env(modelte));
[autopks,autolocs] = findpeaks(autocross_env(autote));

auto_indicator(m) = length(autopks);
indicator(m) = length(pks);

if length(modelpks) > 3
    [tjo tjo] = sort(modelpks,'descend');
    tjo = sort(tjo(1:3));
    modelpks = modelpks(tjo);
    modellocs = modellocs(tjo);
else    
end

if length(autopks) > 3
    [hmm hmm] = sort(autopks,'descend');
    hmm = sort(hmm(1:3));
    autopks = autopks(hmm);
    autolocs = autolocs(hmm);
else
end

if length(autopks) < 3 && length(modelpks) < 3
    [v l] = max(pks);
    Peaksample_math(m) = te(locs(l));
    opt(m) = 1;
elseif length(pks) < 3
    [v l] = max(pks);
    Peaksample_math(m) = te(locs(l));
    opt(m) = 2;
elseif length(pks) == 3
    Peaksample_math(m) = te(locs(2));
    opt(m) = 3;
elseif length(pks) >= 4 && length(modelpks) < 3
    [v l] = max(pks);
    Peaksample_math(m) = te(locs(l));
    opt(m) = 4;
elseif length(pks) >= 4 && length(autopks) < 3
    [v l] = max(pks);
    Peaksample_math(m) = te(locs(l));
    opt(m) = 5;
elseif length(pks) == 4
    auto_time = autote(autolocs) - autote(autolocs(1));
    correlation_time = te(locs) - te(locs(1));
    [val ind] = min(abs(correlation_time - auto_time(2)));
    Peaksample_math(m) = te(locs(ind));
    opt(m) = 6;
elseif length(pks) > 4
    [tja tja] = sort(pks,'descend');
    tja = sort(tja(1:4));
    if abs((te(locs(tja(4))) - te(locs(tja(1)))) - ((autote(autolocs(2)) - autote(autolocs(1))) + (modelte(modellocs(2))) - modelte(modellocs(1)))) < 10
        auto_time = autote(autolocs) - autote(autolocs(1));
        correlation_time = te(locs) - te(locs(1));
        [val ind] = min(abs(correlation_time - auto_time(2)));
        Peaksample_math(m) = te(locs(ind));
        opt(m) = 7;
    else
        [v l] = max(pks);
        Peaksample_math(m) = te(locs(l));
        opt(m) = 8;
    end
end
end
time = Peaksample_math;