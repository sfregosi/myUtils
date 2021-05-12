function mySpec(sig, fs, xlims, ylims, clims, win_novr)
% basic spectrogram plotting with my preferred settings/style grayscale


% TO DO:
% do better job of building in defaults
% plot kHz instead of Hz on y? 

% example for testing
% [sig, fs] = audioread('200211-145309.833.wav');

if nargin < 6
    % default spec settings
    win = 2048;
    novr = round(win*.95);
    nfft = win;
else
    win = win_novr(1);
    novr = win_novr(2);
    nfft = win;
end

[SC,FC,TC,PC] = spectrogram(sig, win, novr, nfft, fs);

imagesc(TC,FC,10*log10(PC)); % axes here make no sense - must fill them in
set(gca,'YDir','normal'); xlabel('time (secs)'); ylabel('frequency (Hz)');
ylim([ylims]);
xlim([xlims]);
colorbar
caxis([clims])
cmap = cmocean('gray');
cmap = flipud(cmap);
colormap(cmap)