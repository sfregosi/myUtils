%ampresp is the amplitude response of the transmissionloss, ampresp assumes
%an even signal length

function hmin = amprespsig(ampresp)

H1=ampresp(:);
hh = [H1; flipud(H1(2:end-1))]; %if the signal length is odd this should be hh = [H1; flipud(H1(2:end))];
m=length(hh);
w=[1;2*ones(m/2-1,1);1;zeros(m/2-1,1)];
ceps=ifft(log(hh));
ceps1=ceps.*w;
hmin=ifft(exp(fft(ceps1)));

