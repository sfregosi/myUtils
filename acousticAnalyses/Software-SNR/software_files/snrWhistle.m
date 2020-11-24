function rDB = snrWhistle(snd, box, freqs, sRate, bufferTime, clickDur)
%SNR		Compute band-limited signal-to-noise ratio (SNR) of calls
%
% rDB = snrWhistle(snd, box, freqs, sRate, bufferTime, clickDur)
%
% Calculate the signal-to-noise ratio of tonal animal calls that may have
% interfering click sounds.  This method is an extension of the method in
% snrWhistle.m (and uses that function); it basically removes the click sounds 
% and then calculates the signal energy and noise energy.  Arguments are 
% similar. This method is meant for sounds that last an appreciable length of 
% time. For click-like sounds, see snrClick.m; for tonal calls that don't have
% interfering clicks, see snrWhistle.m.
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
% bufferTime specifies the amount of time before and after each whistle in
% which to measure the noise.  If it's NaN, use the median inter-call time.
%
% clickDur specifies how long a click of this species is, in seconds.  It's
% used in the process of removing clicks.  It must be specified.
%
% The return value rDB is a column vector with the SNR, in decibels, of 
% each transient signal specified by each row of BOX.
%
% How the endpoints are handled: See snrWhistle.m.
%
% See also snrTonal snrClick, snrPrep.
%
% Dave Mellinger

% Prepare arguments.  The most important here is t.
if (nargin < 5), bufferTime = NaN; end
[snd,npts,nsec,box,t] = snrPrep(snd, box, sRate, bufferTime);

r = zeros(npts,1);				% return value
for i = 1:npts
  % Each call is extracted as a "short" piece, covering the time span that
  % includes just the signal, and a "long" piece that also includes the 
  % surrounding noise.

  % Extract "short", remove clicks in it, and compute its energy.
  short = snd(round(t(i,2)*sRate)+1 :  round(t(i,3)*sRate)+1);
  short1 = remclicks(short, sRate, clickDur, [min(freqs) max(freqs)]);
  if (size(box,2) > 2 && 1)
    Eshort = sigenergy(short1, sRate, box(i,3), box(i,4));	% MobySound way
  elseif (nCols(box) > 2)
    Eshort = sigenergy(short1, sRate, box(i,3), box(i,4), 1);	% new way
  else
    Eshort = sigenergy(short1, sRate, min(freqs), max(freqs));	% old way
  end

  % Extract "long" and compute its energy.
  if (1)	% MobySound way
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
  else		% old way
    l0 = max(1,           round(t(i,1)*sRate) + 1);
    l1 = min(length(snd), round(t(i,4)*sRate) + 1);
    long = snd(l0 : l1);
    if (nCols(box) > 2)						% new way
      Elong = sigenergy(long, sRate, min(freqs), max(freqs), 1);
    else							% old way
      Elong = sigenergy(long, sRate, min(freqs), max(freqs));
    end
    Pnoise  = (Elong - Eshort) / (length(long) - length(short1));% noise power
  end

  % Get signal power.  See discussion above about subtracting
  % or not subtracting Pnoise from Psignal.
  Psignal = Eshort / length(short1);			% don't subtract noise
  %Psignal = Eshort / length(short1) - Pnoise;		% do subtract noise

  if (Psignal > 0)			% near-always true if Pn not subtracted
    r(i) = Psignal / Pnoise;
  else
    r(i) = 10 .^ (-1000 / 20);		% flag value: -1000 dB
  end
  if (1)				
    % Debugging: plot the spectrogram.  Make a new figure window if not present.
    fig = findobj('Tag', 'snrWhistle.m: Plotting window');
    if (length(fig) && (gcf ~= fig(1))), figure(fig(1));
    else set(fig, 'Tag', 'snrWhistle.m: Plotting window');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sig = remclicks(sig, sRate, clickDur, freqLims)
% Remove clicks of duration clickDur from sig.

% Parameters:
pctile = 0.90;		% percentile for thresholding (in [0,1])
clickFrac = 0.5;	% if this many bins are lit up in one gram slice, it's
			%    a click

% Get some basics.
clickNSam = max(2, round(clickDur * sRate));
clickNfft = nextpow2(clickNSam);
nHop = clickNfft / 2;
nyq = sRate/2;

% Find gram bin numbers to look for clicks in.
ix = round(freqLims / nyq * clickNfft/2) + 1;

% Calculate gram, extract frequencies of interest.
spect = spectrogram(sig, hamming(clickNfft), nHop, sRate);
ix = min(ix, nRows(spect));
spect1 = spect(ix(1) : ix(2),:);

% Find noise level (= 'pctile' level in each frequency bin).
p = percentile(spect.', pctile).';	% column vector

% Find which gram cells are above noise level. These are indicated with a '1'.
loud = (spect1 > repmat(p, 1, nCols(spect1)));	% same shape as spect1

% Find which slices have clickFrac or more cells above noise level.
clkIndic = (sum(loud, 1) >= clickFrac * nCols(spect1));	% col indicators (0/1)
clkIx = find(clkIndic);					% col indices in spect1

% Figure out which signal indices these slice numbers came from.
kill0 = (clkIx-1) * nHop + 1;
killAll = repmat(kill0, nHop, 1) + ...
    repmat((0 : nHop-1)', 1, length(clkIx));

% Remove these samples from the signal.
sig(killAll(:)) = [];
