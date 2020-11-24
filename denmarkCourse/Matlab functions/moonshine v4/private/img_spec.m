% sig is the wavfile
% n is the window size
% o is the overlap
% f is the vector
% fs is the samplerate
% range is range


function img_spec(sig,n,o,f,fs,range)

[B,f,t]=spectrogram(sig,n,o,f,fs);
bmin=max(max(abs(B)))/range;
imagesc(t,f,10*log10(max(abs(B),bmin)/bmin));
set(gca,'YDir','normal');
colormap(flipud(hot))