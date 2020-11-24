function rDB = snrTonal(snd, box, freqs, sRate, m)
%SNRTONAL	Compute band-limited signal-to-noise ratio (SNR) of calls
%
% rDB = snrTonal(snd, box, freqs, sRate [,bufferTime])
%
% Calculate the signal-to-noise ratio of selected animal calls as described in
% Mellinger & Clark, "MobySound: A reference archive for studying automatic
% recognition of marine mammal sounds", Applied Acoustics 67:1226-1242 (2006).
%
% This method is meant for sounds that last an appreciable length of time.  
% For short-duration click-like sounds, see snrClick.m.
%
% SND is a vector representing a sound signal sampled at the rate SRATE. 
% BOX is a 4-column array with start- and end-times (in seconds) and low-
% and high-frequencies (in Hertz) of a set of animal calls, with one call
% per row.  These times are measured relative to the start of SND.
% Each row of BOX is for one signal, and the columns of BOX are
% [t0 t1 f0 f1].
%
% For each row i of BOX, the call power is measured in the time from
% BOX(i,1) to BOX(i,2), and the frequency region between BOX(i,3) and
% BOX(i,4).  Noise power is computed in the times between adjacent calls
% and the frequencies between FREQS(1) and FREQS(2); these frequencies 
% are the same for all noise measurements.
%
% The return value rDB is a column vector with the SNR, in decibels, of 
% each transient signal specified by each row of BOX.
%
% How the endpoints are handled: 
% For computing the noise environment of the endpoint calls, the time span
% used is given by BUFFERTIME.  If this argument is not supplied, the 
% default value is the median of the inter-call interval of all calls.
%
% One problem in measuring SNR:
% In measuring signal power, the tactic is to sum the energy in a T/F
% box.  This box necessarily includes noise power also.  The question
% is, should the average noise power (measured in background sound) be
% subtracted from the average power in the T/F box to get just the
% signal power?  If the background noise were stationary, this would be
% fine.  However, in many whale recordings, the noise is definitely
% non-stationary; subtracting noise power from the signal power can
% even produce a negative number, which is silly (and which can't be
% converted to dB).  Because of this problem, the background noise
% level is NOT subtracted from the signal power.  This effectively
% defines the "signal" as ALL sound in the given T/F box, and the
% "noise" as what's outside the box.
%
% This routine was changed in 10/04 so that if box has four columns of
% [t0 t1 f0 f1], then the signal power comes from just the frequencies
% inside the box, not from the entire range of frequencies given in freqs.
% (Before this only [t0 t1] was passed, not the whole [t0 t1 f0 f1]
% box, so the call frequencies weren't even available.  It still works
% this way if box has only two columns.)  Noise power still includes
% the whole of freqs.  With this change, power measurement was changed to
% be power per Hertz (i.e., signal power per Hz, and noise power per
% Hz), so the measurement makes sense intuitively.  Stuff before this
% change is called 'old way' in comments below, stuff after it 'new
% way'.  The 'new way' is the method described in the Applied Acoustics
% article.
%
% But this raises another issue:
% What about harmonic sounds?  NE Pacific blue whales, for instance,
% sometimes have a loud harmonic at 17 Hz, or one at 51 Hz, or both.
% If only one harmonic is present, and you measure signal power in its
% band (say 16-18 Hz), then the average signal power per Hertz is
% relatively high.  If both harmonics are present, and you measure the
% power in the full 17-51 Hz band, then the average signal power per
% Hertz is relatively low because the band is so wide.  Possible
% solutions:
%   (1) Accept it.  This leads to very different SNR estimates for 
%       very similar-looking calls.
%   (2) Always measure the same band -- in the blue whale example,
%       always 17-51 Hz.  This is how things were done up until
%       Oct. 2004.  This results in similar SNR measurements for
%       similar calls, but seems to go against the intuition that the
%       signal should be measured in the frequency band where it
%       occurs, and not elsewhere; measuring elsewhere leads to
%       inclusion of energy from other sources.  For instance,
%       measuring 17-51 Hz for blue whale calls includes a lot of
%       energy (in 18-48 Hz) from things that aren't blue whales.
%   (3) Don't measure signal power per Hertz; just measure signal
%       power.  This is nearly equivalent to choice (2) above, and has
%       the same benefits and problems.
%   (4) Allow the measured frequency band to have multiple disjoint
%       parts, and measure both signal and noise in the same parts for
%       all calls.  For the blue whale example, the parts might be
%       16-18 Hz and 49-53 Hz.  This gets around the problems mentioned
%       above, but seems overly complex.
%
% This routine uses option (1) above.
%
% See also snrClick, snrPrep.
%
% Dave Mellinger

% Prepare arguments.  The most important here is t.
if (nargin < 5), m = NaN; end
[snd,npts,nsec,box,t] = snrPrep(snd, box, sRate, m);

r = zeros(npts,1);				% return value
for i = 1:npts
  % Each call is extracted as a "short" piece, covering the time span that
  % includes just the signal, and a "long" piece that also includes the 
  % surrounding noise.

  % Extract "short" and compute its energy.
  short = snd(round(t(i,2)*sRate)+1 :  round(t(i,3)*sRate)+1);
  if (size(box,2) > 2 && 1)
    Eshort = sigenergy(short, sRate, box(i,3), box(i,4));	% MobySound way
  elseif (size(box,2) > 2)
    Eshort = sigenergy(short, sRate, box(i,3), box(i,4), 1);	% new way
  else
    Eshort = sigenergy(short, sRate, min(freqs), max(freqs));	% old way
  end

  % Extract "long" and compute its energy.
  if (1)							% MobySound way
    l0 = max(1,           round(t(i,1)*sRate) + 1);
    l1 = min(length(snd), round(t(i,2)*sRate) + 1);
    longA = snd(l0 : l1);
    ElongA = sigenergy(longA, sRate, min(freqs), max(freqs));
    l2 = max(1,             round(t(i,3)*sRate) + 1);
    l3 = min(length(snd), round(t(i,4)*sRate) + 1);
    longB = snd(l2 : l3);
    ElongB = sigenergy(longB, sRate, min(freqs), max(freqs));
    Pnoise  = (ElongA+ElongB) / (length(longA) + length(longB));% noise power
    long = snd(l0 : l3);					%for plot below
  else								% old way
    l0 = max(1,           round(t(i,1)*sRate) + 1);
    l1 = min(length(snd), round(t(i,4)*sRate) + 1);
    long = snd(l0 : l1);
    if (size(box,2) > 2)					% new way
      Elong = sigenergy(long, sRate, min(freqs), max(freqs), 1);
    else							% old way
      Elong = sigenergy(long, sRate, min(freqs), max(freqs));
    end
    Pnoise  = (Elong - Eshort) / (length(long) - length(short));% noise power
  end

  % Get signal power.  See discussion above about subtracting
  % or not subtracting Pnoise from Psignal.
  Psignal = Eshort / length(short);			% don't subtract noise
  %Psignal = Eshort / length(short) - Pnoise;		% do subtract noise

  if (Psignal > 0)			% near-always true if Pn not subtracted
    r(i) = Psignal / Pnoise;
  else
    r(i) = 10 .^ (-1000 / 20);		% flag value: -1000 dB
  end
  if (0)				
    % Debugging: plot the spectrogram.  Make a new figure window if not present.
    fig = findobj('Tag', 'snrTonal.m: Plotting window');
    if (length(fig) && (gcf ~= fig(1))), figure(fig(1));
    else set(fig, 'Tag', 'snrTonal.m: Plotting window');
    end
    
    n = 256;
    % Matlab spectrogram function args: nwin,noverlap,nfft,srate
    [sS,fS,tS] = spectrogram(long,n,n/2,n*2,sRate);
    imagesc(tS, fS, abs(sS));
    colormap(flipud(gray))
    set(gca, 'YDir', 'normal')
    fRange = [min(freqs) max(freqs)];
    % Draw solid box around call, dotted boxes around two noise regions.
    drawbox(t(i,2:3) - t(i,1), box(i,3:4), 'Color', 'r', 'LineStyle', '-')
    drawbox(t(i,1:2) - t(i,1), fRange,     'Color', 'r', 'LineStyle', ':')
    drawbox(t(i,3:4) - t(i,1), fRange,     'Color', 'r', 'LineStyle', ':')
    set(gca, 'YLim', max(0, min(sRate/2, fRange * [5 -3;-3 5]/2)))
    title(sprintf('call at %.1f s: SNR=%.1f dB', t(i,2), 10*log10(r(i))))
    drawnow

    %keyboard
    %disp('Type a space to continue.'); pause
    %pause(1)
  end
  %disp(sprintf('[%6.1f%7.1f%7.1f%7.1f] s%9.2e l%9.2e ratio %7.3f dB', ...
      %t(i,1), t(i,2), t(i,3), t(i,4), Eshort, Elong, 20*log10(r(i))))
end
%disp(' ');

rDB = 10 * log10(r);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function E = sigenergy(sig, sRate, f0, f1, normalize)
%
% Compute the energy in a signal.
%
% y = sigenergy(signal)
%    Compute the energy of the signal.  The value returned is useful for
%    comparison with other values returned by this function; it means
%    nothing in absolute terms, since it is uncalibrated.
%
% y = sigenergy(signal, sRate, f0, f1)
%    As above, but return the energy in the given frequency band.
%    sRate, f0, and f1 are in Hz.
%
% y = sigenergy(signal, sRate, f0, f1, normalize)
%    As above, but if the normalize flag is non-zero, correct for the bandwidth
%    of the measurement.  This correction is valid only if you're doing a 
%    signal-to-noise ratio (SNR) measurement, and both signal energy and noise
%    energy are corrected.

if (nargin < 5), normalize = 0; end

sig = sig(:).';
n = length(sig);
n2 = 2 .^ nextpow2(n);
if (nargin >= 4)
  i0 = round(f0 / (sRate/2) * n2/2) + 1;	% index for lower freq bound
  i1 = round(f1 / (sRate/2) * n2/2) + 1;	% ...and upper
else
  i0 = 1;
  i1 = n2/2;
end

padsig = [sig zeros(1, n2 - n)];		% zero-pad to power-of-2 length
f = abs(fft(padsig));
E = (1 / n2) * sum(f(i0 : i1) .^ 2);		% energy
%P = E / n;					% power

if (normalize)
  E = E / ((i1 - i0 + 1) / n2);			% correct for bandwidth
end

if (0)
  % Debugging: plot the spectrum.
  figure(3);
  plot(linspace1(0, sRate/2, n2/2), f(1 : n2/2), 'b-')
  set(gca, 'TickDir', 'out');
  xlims fit
  line([f0 f1;f0 f1], [ylims.' ylims.'], 'Color', 'r', 'LineStyle', ':');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawbox(t, f, varargin)
% Draw a rectangular box on the screen.  varargin has line properties.

line(t([1 2 2 1 1]), f([1 1 2 2 1]), varargin{:})
