function spectrumplot(sig,fs)
fsig=abs(fft(sig));
if mod(length(sig),2) == 0;
fsig=fsig (1:length(fsig)/2); 
else
fsig=fsig (1:int32((length(fsig)-1)/2));
end
fax = (0:length(fsig)-1)*fs/(2*length( fsig));
plot(fax/1000,20*log10(fsig)-max(10*log10(fsig)),'k-')
axis([0 max(fax/1000) -70 10])