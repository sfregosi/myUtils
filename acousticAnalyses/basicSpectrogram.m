% basic spectrogram plotting

[sig, fs] = audioread('200211-145309.833.wav');


win = 2048;
novr = round(win*.95);
nfft = win;
[SC,FC,TC,PC] = spectrogram(sig,win,novr,nfft,fs);

imagesc(TC,FC,10*log10(PC)); % axes here make no sense - must fill them in
set(gca,'YDir','normal'); xlabel('time (secs)'); ylabel('frequency (Hz)');
ylim([5 80]);
xlim([360 600]);
colorbar
caxis([-90 -60])
cmap = cmocean('gray');
cmap = flipud(cmap); 
colormap(cmap)