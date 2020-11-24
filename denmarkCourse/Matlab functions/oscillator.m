function wave = oscillator(varargin)
%OSCILLATOR generates a standard waveform, click train, or noise
% OSCILLATOR(wavetype,duration,frequency)
%
% Input arguments:
%
%   wavetype (case insensitive string):
%    'Sinusoid'
%    'Triangle'
%    'Square'
%    'Sawtooth'
%    'Reverse Sawtooth'
%    'Linear Sweep'
%    'Log Sweep'
%    'FM signal'        or 'fm'
%    'Click Train'      or 'click'
%    'White Noise'      or 'white'
%    'Octave Band'      or 'octave'
%    'Half Octave'      or 'half'
%    'Third Octave'     or 'third'
%    'Quarter Octave'   or 'quarter'
%    'Brown Noise'      or 'brown'
%    'Pink Noise'       or 'pink'
%    'Blue Noise'       or 'blue'
%    'Violet Noise'     or 'violet'
%    'Grey Noise'       or 'grey'
%    'Speech Noise'     or 'speech'
%
%   duration (in seconds)
%
%   frequency (in Hz)
%       NOTE: linear and log sweeps require [start stop] frequency vector
%             'fm signals' require a num_samples-long vector of frequencies.
%
% Optional input arguments:
%  OSCILLATOR(wavetype,duration,frequency,gate,phase,sample_freq)
%   gate (in seconds): duration of a raised cosine on/off ramp
%   phase (in radians): starting phase of the waveform.
%   sample_rate (in samples): 44100 is default, custom rates are possible
%
% Examples:
%
%   wave = OSCILLATOR('Sinusoid',1,1000); % simple pure tone at 1000 Hz.
%   wave = OSCILLATOR('Sawtooth',2,440); % 2 second sawtooth at 440 Hz.
%   wave = OSCILLATOR('Pink Noise',1); % 1 second of pink (1/F) noise
%   wave = OSCILLATOR('Linear Sweep',2,[440 880]); % linear sweep from 440 to 880 Hz.
%   wave = OSCILLATOR('Log Sweep',2,[20 20000],.01); % ramped on/off log sweep.
%   wave = OSCILLATOR('FM',1,freq_vector); % signal changing in freq over time
%   wave = OSCILLATOR('White Noise',1,[],0.1); %ramped on and off noise
%   wave = OSCILLATOR('Half Octave',1,440); %half octave noise, 440 Hz centre.
%   wave = OSCILLATOR('Sinusoid',1,220,0,pi/2,48000); %pure tone with a
%            starting phase of 90 degrees and sample rate set to 48000.
%
% Omitting 'wavetype' sets it to sinusoid, omitting 'duration' sets it to
% one second, and omitting 'frequency  sets it to 440 Hz. Gate is set to 0,
% phase to 0 and sample rate to 44100; All output waves are scaled to a
% peak absolute value of 1.0
%
% For the 'FM signal' option, the function should be provided with a vector
% of frequencies (in Hz) that is the same duration and sample frequency as
% the desired signal. Failing this, the function will *attempt* to resample
% the frequency vector using spline interpolation. YMMV.
%
% Note that the 'grey noise' is *generic* grey and is based the ISO 66-phon
% Equal-loudness contour.

% (c) W. Owen Brimijoin - MRC Institute of Hearing Research
% Tested on Matlab R2011b and R14
%
% Version 1.0 18/05/12 - original
% Version 1.1 29/06/12 - added pink and speech-shaped noise options
% Version 1.2 26/06/13 - added swept sine and brown and grey noise options
% Version 1.3 05/07/13 - added blue and violet and changed noise generation
%                          to a slower but more accurate ifft method. 
% Version 1.4 06/05/14 - added octave band (and 1/4 band, etc) options
% Version 1.5 07/05/14 - added the capacity to generate frequency modulated
%                          signals of arbitrary trajectory.

%input handling:
switch nargin,
    case 0, wavetype='Sinusoid';duration=1;frequency=440;gate=0;phase=0;sample_rate=44100;
    case 1, wavetype=varargin{1};duration=1;frequency=440;gate=0;phase=0;sample_rate=44100;
    case 2, wavetype=varargin{1};duration=varargin{2};frequency=440;gate=0;phase=0;sample_rate=44100;
    case 3, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=0;phase=0;
        sample_rate=44100;
    case 4, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=varargin{4};
        phase=0;sample_rate = 44100;
    case 5, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=varargin{4};
        phase=varargin{5};sample_rate = 44100;
    case 6, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=varargin{4};
        phase=varargin{5};sample_rate = varargin{6};
    otherwise, error('incorrect number of input arguments');
end

%for noise, frequency is likely omitted or 0, set to default to avoid error:
if isempty(frequency(:)) || any(frequency(:)==0), frequency=1;end

%start input checking:
if ~ischar(wavetype),
    error('1st argument ''wavetype'' must be a string.')
end

if ~isnumeric(duration) || numel(duration) ~= 1 || duration < 0 || ~isreal(duration),
    error('2nd argument ''duration'' must be a single positive number.')
end

if ~isnumeric(frequency(:)) || sum(frequency(:)<= 0) || ~isreal(frequency(:)) || sum(frequency(:)>sample_rate/2) || numel(frequency)~=length(frequency),
    error('3rd argument ''frequency'' must be a number or vector less than or equal to the Nyquist.')
end

if ~isnumeric(gate) || numel(gate) ~= 1 || gate < 0  || ~isreal(gate) || 2*gate>duration,
    error('optional 4th argument ''gate'' must be a positive number less than or equal to half the duration.')
end

if ~isnumeric(phase) || numel(phase) ~= 1 || ~isreal(phase) || max(abs(phase))> 2*pi,
    error('optional 5th argument ''phase'' should be a real number between -2pi and 2pi.')
end

if ~isnumeric(sample_rate) || numel(sample_rate) ~= 1 || sample_rate < 0 || ~isreal(sample_rate),
    error('optional 6th argument ''sample_rate'' must be a single positive number.')
end

switch numel(frequency),
    case 1,
        if any(strcmpi(wavetype,{'fm signal','fm'})),
            error('For FM signals, ''frequency'' must have >1 elements.')
        end
        if any(strcmpi(wavetype,{'log sweep','linear sweep'})),
            error('For FM sweeps, ''frequency'' must be 2 positive numbers.')
        end
    case 2,
        if ~any(strcmpi(wavetype,{'log sweep','linear sweep','fm signal','fm'})),
            error('For non-FM signals, ''frequency'' must be 1 positive number.')
        end
    otherwise
        if ~any(strcmpi(wavetype,{'fm signal','fm'})),
            error('For non-FM signals, ''frequency'' must be 1 positive number.')
        end
end
%end input checking

num_samples = floor(sample_rate*duration);%duration in samples
phase = mod(phase,2*pi)/(2*pi); %phase rescaled from 2*pi to 1

switch lower(wavetype), %generate the chosen waveform:
    case 'sinusoid',
        % use in-built sine function, offset by the phase argument:
        wave = sin((2*pi*phase)+(2*pi*frequency*linspace(0,duration,num_samples)))';
        
    case 'triangle',
        % use modulo to fold a line from 0 to frequency, sign-reverse positive values and rescale:
        wave =  2*mod(phase+.25+linspace(0,duration*frequency,num_samples)',1)-1;
        wave(wave>0) = -wave(wave>0);wave = 2*(wave+0.5);
        
    case 'square',
        % same as sinusoid...
        wave = sin((2*pi*phase)+(2*pi*frequency*linspace(0,duration,num_samples)))';
        % all positive values set to 1 and all negative values to -1:
        wave(wave>=0) = 1;wave(wave<0)=-1;
        
    case 'sawtooth',
        % simple modulo with phase added linearly:
        wave =  2*mod(phase+.5+linspace(0,duration*frequency,num_samples)',1)-1;
        
    case 'reverse sawtooth',
        % same as sawtooth...
        wave =  2*mod(phase+.5+linspace(0,duration*frequency,num_samples)',1)-1;
        % but sign-reversed:
        wave = -wave;
        
    case 'linear sweep',
        % generate a vector of frequencies:
        freq_vector = linspace(frequency(1),frequency(2),num_samples);
        %send this to the arbitrary fm signal generator:
        wave = fm_signal_generator(freq_vector,duration,phase,sample_rate);
        
    case 'log sweep',
        % generate a vector of frequencies:
        freq_vector = logspace(log10(frequency(1)),log10(frequency(2)),num_samples);
        %send this to the arbitrary fm signal generator:
        wave = fm_signal_generator(freq_vector,duration,phase,sample_rate);
        
    case {'fm signal','fm'},
        %check that the frequency vector is the correct length:
        if numel(frequency)~=num_samples,
            warning('''frequency'' should be duration*sample_rate in length... resampling!')
            freq_vector = spline(linspace(0,duration,length(frequency)),frequency,linspace(0,duration,num_samples));
        else
            freq_vector = frequency;
        end
        %send the frequency vector to the fm signal generator:
        wave = fm_signal_generator(freq_vector,duration,phase,sample_rate);
        
    case {'click train','click'},
        % change phase argument to a fraction of the signal period:
        phase_vals = mod(round(-phase/frequency*sample_rate),round(1/frequency*sample_rate));
        % use the index 'phase offset' to specify location of 1 values:
        wave(phase_vals+round(1:1/frequency*sample_rate:num_samples)) = 1;
        % ensure that the signal is the correct duration:
        wave(1+num_samples)=0; wave = wave(1:num_samples)';
        
    case {'white noise','white','noise'},
        % use rand to create noise, wave is then normalized to a max of 1:
        wave = 2*(rand(num_samples,1)-0.5);wave = wave./max(abs(wave));

    case {'octave','octave band'},
        bandwidth = 1; %set bandwidth value
        %send this to the arbitrary fm signal generator:       
        wave = band_noise_generator(bandwidth,frequency,num_samples,sample_rate);
        
    case {'half','half octave'},
        bandwidth = 0.5; %set bandwidth value
        %send this to the arbitrary fm signal generator:       
        wave = band_noise_generator(bandwidth,frequency,num_samples,sample_rate);
        
    case {'third','third octave'},
        bandwidth = 1/3; %set bandwidth value
        %send this to the arbitrary fm signal generator:       
        wave = band_noise_generator(bandwidth,frequency,num_samples,sample_rate);
        
    case {'quarter','quarter octave'},
        bandwidth = 0.25; %set bandwidth value
        %send this to the arbitrary fm signal generator:       
        wave = band_noise_generator(bandwidth,frequency,num_samples,sample_rate);
                
    case {'pink noise','pink'},
        beta = -1; %set beta value
        %send this to the colored noise generator:       
        wave = color_noise_generator(beta,num_samples);
        
    case {'brown noise','brown'},
        beta = -2; %set beta value
        %send this to the colored noise generator:       
        wave = color_noise_generator(beta,num_samples);
        
	case {'blue noise','blue'},
        beta = 1; %set beta value
        %send this to the colored noise generator:       
        wave = color_noise_generator(beta,num_samples);
        
  	case {'violet noise','violet'},
        beta = 2; %set beta value
        %create frequency vector folded at center:
        %send this to the colored noise generator:       
        wave = color_noise_generator(beta,num_samples);
        
    case {'grey noise','grey'},
        %values from the ISO 66-phon Equal-loudness contour (adjusted for
        %optimal spline interpolation):
        freqs = [1 5 15 36 75 138 235 376 572 835 1181 1500 2183 2874 3718 ...
            4800 5946 7377 9051 10996 13239 15808 18735 22050].*sample_rate/44100;
        dB_vals = [61 61 56 40 25 17 11 7 5 4 6 8 3 1 1 4 9 14 17 16 10 5 2 1];
        
        %create level vector for use in inverse Fourier transform:
        freq = linspace(0,sample_rate/2*duration/2,floor(num_samples/2));
        spl = spline(freqs,dB_vals,freq); %upsample 
        levels = [spl,fliplr(spl)]; %reflect vector
        levels = 10.^(levels'./10); %change to power
        levels(levels==inf) = 0; %remove infinite values
        phase_vals = rand(length(levels),1); %generate random phase vals
        %now apply an inverse fft:
        wave = real(ifft(sqrt(levels).*(cos(2*pi*phase_vals)+1i*sin(2*pi*phase_vals))));
        wave = wave./max(abs(wave));
        
    case {'speech noise','speech'},
        %values from Byrne et al (1994) JASA manuscript (adjusted for
        %optimal spline interpolation):
        freqs = [1 10 50 80 100 125 160 200 250 315 400 500 630 800 1000 1250 ...
            1600 2000 2500 3150 4000 5000 6300 8000 10000 12000 18000 22050].*sample_rate/44100;
        dB_vals = [35 36 38.6 43.5 54.4 57.7 56.8 60.2 60.3 59.0 62.1 62.1 60.5 ...
            56.8 53.7 53.0 52.0 48.7 48.1 46.8 45.6 44.5 44.3 43.7 43.4  43  41 38];
        
        %create level vector for use in inverse Fourier transform:
        freq = linspace(0,sample_rate*duration/2,floor(num_samples/2));
        spl = spline(freqs,dB_vals,freq);
        levels = [spl,fliplr(spl)]; %reflect vector
        levels = 10.^(levels'./10); %change to power
        levels(levels==inf) = 0; %remove infinite values
        phase_vals = rand(length(levels),1); %generate random phase vals
        %now apply an inverse fft:
        wave = real(ifft(sqrt(levels).*(cos(2*pi*phase_vals)+1i*sin(2*pi*phase_vals))));
        wave = wave./max(abs(wave));
        
    otherwise,
        display('Unrecognized waveform type');wave = [];return
end

if gate>0,
    % create the raised cosine ramp:
    t = linspace(0,pi/2,floor(sample_rate*gate))';
    gate = (cos(t)).^2;
    % ramp the beginning of the signal on:
    wave(1:length(gate)) = wave(1:length(gate)).*flipud(gate);
    % ramp the end of the signal off:
    wave(end-length(gate)+1:end) = wave(end-length(gate)+1:end).*gate;
end

function wave = fm_signal_generator(freq_vector,duration,phase,sample_rate)
%this handles the various FM signals such as linear, log, arbitrary, etc

%set time base:
t = linspace(0,duration,floor(duration*sample_rate))';
%use the centre of the requested frequencies as the carrier frequency:
carrier = mean([min(freq_vector) max(freq_vector)]);
%determine normalize max frequency:
norm_maxfreq = (max(freq_vector) - carrier)/sample_rate*2*pi;
%normalize the frequency range to -1.0 to 1.0:
freq_vector = freq_vector(:) - min(freq_vector);
freq_vector = (freq_vector./max(freq_vector)*2)-1;
%generate the fm signal:
wave = sin(2*pi*carrier*t + norm_maxfreq*cumsum(freq_vector)+2*pi*phase);
wave = wave./max(abs(wave)); %normalize to +/- 1.

function wave = band_noise_generator(bandwidth,frequency,num_samples,sample_rate)
%this handles the various noise band signals like octave, third octave, etc

wave = 2*(rand(num_samples,1)-0.5); % use rand to create noise
%compute second order butterworth coefficients:
[B,A] = butter(2,frequency.*[1/(sqrt(2^bandwidth)) sqrt(2^bandwidth)]./sample_rate*2);
wave = filter(B,A,wave); %filter the noise
wave = wave./max(abs(wave)); %normalize to +/- 1.

function wave = color_noise_generator(beta,num_samples)
%this handles the various colors of noise like pink, brown, blue, etc

%create frequency vector folded at center:
freqs = [linspace(0,.5,floor(num_samples/2)),fliplr(linspace(0,.5,ceil(num_samples/2)))]';
freqs = (freqs.^2).^(beta/2);
freqs(freqs==inf) = 0; %to prevent inf errors
phase_vals = rand(num_samples,1);
%now apply an inverse fft:
wave = real(ifft(sqrt(freqs).*(cos(2*pi*phase_vals)+1i*sin(2*pi*phase_vals))));
wave = wave./max(abs(wave)); %normalize to +/- 1.
