%sig is the signal segment
%interval if 'h' 95% is used otherwise 75% is used
function [rms Int dur] = rms95_multi(sig,interval)
csig = cumsum(sig.^2);
for n = 1:length(sig(1,:))
    int95 = [];
csig(:,n) = csig(:,n)/max(csig(:,n));
if interval == 'h'
int95 = find(csig(:,n)>0.025 & csig(:,n)< 0.975);
else
int95 = find(csig(:,n)>0.05 & csig(:,n)< 0.875);
end
Rms(n) = sqrt(mean((sig(int95,n)).^2));
dur(n) = length(int95);
end
[val loc] = max(Rms);
if interval == 'h'
int = find(csig(:,loc)>0.025 & csig(:,loc)<0.975);
else
    int = find(csig(:,loc)>0.05 & csig(:,loc)<0.875);
end
for n = 1:length(sig(1,:))
rms = sqrt(mean((sig(int,:)).^2));
end
Int = int*ones(1,length(sig(1,:)));