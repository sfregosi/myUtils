function [fpsd, frqF, wpsd, frqW] = calcMultiNoise(fname, sysSensFile)

% same as plotMultiNoise but DOESN't plot it. 
% adjusts for sensitivity and creates psd and pwelch spectral densities. 


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

%% FFT PSD
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
    frqF(k)=inc_f*(k-1); % frqI for interpolate
end

%% System sensitivity
load(sysSensFile);
sysSensI = interp1(frqSysSens(:,1),frqSysSens(:,2),frqF,'pchip');

%% Continue with FFT power spectrum

%plot FFT power spectrum
Psp=10*log10(smPxx);
fpsd = Psp-sysSensI;
% subplot(2,3,4);
% plot(frqI,fpsd, 'LineWidth', 2.5);
% axis([0 fs/2 20 120]);
% strn=sprintf('Raw FFT PSD, Total Energy = %f V^2', enrg);
% ylabel('Spectrum Level in dB re 1V^2/Hz');
% xlabel('Frequency [Hz]');
% title(strn);
% grid on;

%% welch's spectrum
% h = spectrum.welch('Hann',window, noverlap/window); %Create a Welch spectral estimator.
% hpsd=psd(h,x,'Fs',fs); %Calculate and plot the one-sided PSD.
% %hpsd = psd(h,x,'ConfLevel',0.9); % PSD with confidence level
nfft = window; 
[Wpsd,frqW,WpsdC] = pwelch(x,hanning(window),noverlap,nfft,fs); 

% winL=length(sysSensI)/length(Wpsd);
% WL=fix(winL);
% k=0;
% lastj=length(sysSensI)-WL;

% for j=1:WL:lastj
%     k=k+1;
%     smSysSens(k)=sum(sysSensI(j:j+WL-1)/winL);
% end
% 
sysSensI = interp1(frqSysSens(:,1),frqSysSens(:,2),frqW,'pchip');
wpsd = 10*log10(Wpsd)-sysSensI;

% 
% subplot(2,3,5);
% h=plot(hpsd);
% set(h,'linewidth',2.5);
% str = sprintf('Welch PSD Estimate');
% title(str);
% grid on;

% noise=Psp-sysSensI;
% Sm_window=1; %in Hz
% wl=frqI(end)/length(frqI);
% window=Sm_window/wl;
% SMQNoise=moving_average(noise,window); %smoothed noise spec
% subplot(2,3,6);
% frqW=         [100. 200. 300. 500. 700. 1000. 2000. 5000. 10000. 20000. 50000.];
% SeaSt0_Wenz = [41. 45.  47.  47.  45. 43.   38.   32.   28.    25.    20.];
% Sm_Wenz=moving_average(SeaSt0_Wenz,1.5);
% hold on;
% plot(frqI,SMQNoise,'LineWidth',2,'Color','k');
% plot(frqW,SeaSt0_Wenz,'--');
% text(2000,34,'SS 0','FontSize',16);
% SeaSt1_Wenz=[50. 54.  56.  56.  54. 52.   47.   41.   36.    31.    24.];
% plot(frqW,SeaSt1_Wenz,'--');
% text(2000,44,'SS 1','FontSize',16);
% SeaSt2_Wenz=[ 63.  66.  67.  66.  65. 63.   57.5  50.5  45.5    40.    33.5];
% plot(frqW,SeaSt2_Wenz,'--');
% text(2000,54,'SS 3','FontSize',16);
% SeaSt6_Wenz=[71.   72.5 73.7  73.0 71.5 68.5  64.   57.   52.    47.    40.];
% plot(frqW,SeaSt6_Wenz,'--');
% text(2000,64,'SS 6','FontSize',16);
% title('Ambient noise');

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

% set(gca,'XScale','log');
% axis([10 fs/2 20 120]);
% strn=sprintf('%s noise spectral density %s');
% ylabel('Spectral Level in dB re 1\muPa^2/Hz');
% xlabel('Frequency [Hz]');
% title(strn);
% grid on;
% hold off;

