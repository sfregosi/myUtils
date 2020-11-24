function plotMultiNoise(fname, sysSensFile)

% plot set of plots for single file, 
% including waveform, spectrogram, system sensitivity, raw FFT, Welch PSD, 
% and calibrated levels against ambient noise.


% ******* for testing *********
% single q001 file
% path_data = 'G:\score\2015\data\q001-HF-125kHz\';
% q1wav = [path_data '151228-222520.wav'];
% fname = q1wav;
% sysSensFile = ['C:\Users\selene\OneDrive\projects\AFFOGATO\finComparison\code' ...
%     '\noise\noiseCalibrated\q001_sysSens.mat'];
% *****************************

[dpath, file_i, ext] = fileparts(fname);

bits = 16; vref = 5; % NEED TO CHECK VREF? Or doesnt matter

% ********************
%% Read in file
[sig, fs] = audioread(fname);

sig = vref * sig; %convert to volts
avg=mean(sig); %calc mean
sig=sig-avg; %remove DC

% time vector
time = (1:length(sig))/fs;
time = time*1e6; % usecs

nsamps = length(sig);


%% Generate plots
figure('Color','white');
subplot(2,3,1);
mlast=fs;
m = 1:mlast;
plot(time(m), sig(m));
title(sprintf('%s',file_i),'Interpreter','none');
axis([time(1) time(mlast) -vref vref]);
ylabel('Volts');
xlabel('Time (usec)');
grid on;

subplot(2,3,2);
nfft = fs/2;
noverlap = nfft/2;
win = hanning(nfft);
[S,F,T]=spectrogram(sig(1:nsamps), win, noverlap, nfft, fs);
S=abs(S);
imagesc(S);
set(gca,'YDir','normal') % flip it the right way. 
title('Spectrogram');

tx=[];
tl=[];

for i=80:80:length(T)
    tx=[tx; i];
    tl=[tl; T(i)];
end
set(gca,'XTick',tx);
set(gca,'XTicklabel',{num2str(tl,'%5.1f')});
xlabel('Time s');

fy=[];
fl=[];

xGap = 10000; % Hz to space lables
lm = xGap/2; % label multiplier
for i=1:lm:length(F)
    fy=[fy; i];
    fl=[fl; F(fy(end))/1000];
end
set(gca,'YTick',fy);
set(gca,'YTicklabel',{num2str(fl,'%4.0f')});
ylabel('Frequency kHz');

%% Continue with PSD
fact=1;
freq_smth=1; %Hz
window=fs/freq_smth;
noverlap=window/2;
x=sig(1:nsamps/fact); %fact=1 plot spectrum all

nfft=2^nextpow2(length(x));
ratio=length(x)/nfft;
Pxx=2*ratio*abs(fft(x,nfft)/length(x)).^2; %FFT
enrg=sum(Pxx(1:length(x)/2-1));

%Normalize FFT per Hz
OneHzBin=(length(Pxx)/2-1)/fs; %number of bins per Hz
L=fix(OneHzBin)+1; %bin size per Hz

Hpsd=dspdata.psd(L*Pxx(2:length(Pxx)/2),'Fs',fs); %Power spec density (ALL)

%Normalize to 1 Hz bin
k=0;
for j=1:L:length(Pxx)/2-L;
    k=k+1;
    smPxx(k)=sum(Pxx(j:j+L-1));
end

%adjust the FFT power spectrum because 1-Hz bin size is not exactly 1 Hz.
smPxx=smPxx * OneHzBin/L;
km=k;
inc_f=fs/2/(km-1);

for k=1:km
    frqI(k)=inc_f*(k-1); % frqI for interpolate
end

%% System sensitivity
load(sysSensFile);
sysSensI = interp1(frqSysSens(:,1),frqSysSens(:,2),frqI,'pchip');

%plot system sensitivity
subplot(2,3,3);
plot(frqI, sysSensI, 'LineWidth', 2.5);
strn=sprintf('sensitivity');
xlim([0 fs/2]);
ylabel('System Sensitivity in dB re 1\muPa');
xlabel('Frequency [Hz]');
title(strn);grid on;

%plot FFT power spectrum
Psp=10*log10(smPxx);
subplot(2,3,4);
plot(frqI,Psp-sysSensI, 'LineWidth', 2.5);
axis([0 fs/2 20 120]);
strn=sprintf('Raw FFT PSD, Total Energy = %f V^2', enrg);
ylabel('Spectrum Level in dB re 1V^2/Hz');
xlabel('Frequency [Hz]');
title(strn);
grid on;

nfft = window; 
[Wpsd,frqW,WpsdC] = pwelch(x,hanning(window),noverlap,nfft,fs); 

sysSensW = interp1(frqSysSens(:,1),frqSysSens(:,2),frqW,'pchip');
wpsd = 10*log10(Wpsd)-sysSensW;


subplot(2,3,5);
h=plot(wpsd);
set(h,'linewidth',2.5);
str = sprintf('Welch PSD Estimate');
title(str);
grid on;

% % use FFT psd as noise
% noise=Psp-sysSensI;
% Sm_window=1; %in Hz
% wl=frqI(end)/length(frqI);
% window=Sm_window/wl;
% SMQNoise=moving_average(noise,window); %smoothed noise spec
% subplot(2,3,6);
% hold on;
% plot(frqI,SMQNoise,'LineWidth',2,'Color','k');
% 
% use welches psd as noise
noise = wpsd;
Sm_window=1; %in Hz
wl=frqW(end)/length(frqW);
window=Sm_window/wl;
SMQNoise=moving_average(noise,window); %smoothed noise spec
subplot(2,3,6);
hold on;
plot(frqW,SMQNoise,'LineWidth',2,'Color','k');



% plot sea states
frqW=         [100. 200. 300. 500. 700. 1000. 2000. 5000. 10000. 20000. 50000.];
SeaSt0_Wenz = [41. 45.  47.  47.  45. 43.   38.   32.   28.    25.    20.];
Sm_Wenz=moving_average(SeaSt0_Wenz,1.5);
plot(frqW,SeaSt0_Wenz,'--');
text(2000,34,'SS 0','FontSize',16);
SeaSt1_Wenz=[50. 54.  56.  56.  54. 52.   47.   41.   36.    31.    24.];
plot(frqW,SeaSt1_Wenz,'--');
text(2000,44,'SS 1','FontSize',16);
SeaSt2_Wenz=[ 63.  66.  67.  66.  65. 63.   57.5  50.5  45.5    40.    33.5];
plot(frqW,SeaSt2_Wenz,'--');
text(2000,54,'SS 3','FontSize',16);
SeaSt6_Wenz=[71.   72.5 73.7  73.0 71.5 68.5  64.   57.   52.    47.    40.];
plot(frqW,SeaSt6_Wenz,'--');
text(2000,64,'SS 6','FontSize',16);
title('Ambient noise');

% frqShip=     [10.  20. 50. 100. 200. 500.];
% NL_lightShip=[64.  67. 66. 58.  46.  30. ];
% plot(frqShip,NL_lightShip,'--');
% text(500,30,'light','FontSize',16);
% NL_moderate= [72.5 76. 75. 69.  58.  42.];
% plot(frqShip,NL_moderate, '--');
% text(500,41,'moderate','FontSize',16);
% NL_heavy   = [81.5 85. 85. 79.  69.  53.5];
% plot(frqShip,NL_heavy,'--','Color',[96 95 115]./255);
% text(500,52,'heavy','FontSize',16);

set(gca,'XScale','log');
axis([10 fs/2 20 120]);
strn=sprintf('%s noise spectral density %s');
ylabel('Spectral Level in dB re 1\muPa^2/Hz');
xlabel('Frequency [Hz]');
title(strn);
grid on;
hold off;

