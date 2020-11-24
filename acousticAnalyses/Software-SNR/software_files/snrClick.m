function rDB = snrClick(snd, box, freqs, sRate, m)
%SNR		Compute band-limited time-domain SNR of clicks
%
% Calculate the signal-to-noise ratio of selected animal calls as described at
% the Boston detection/classification conference in July 2007. The basic idea
% is to band-pass filter the sound, then measure the loudest part relative to 
% the RMS level.
%
% For a description of the input/output arguments and return value, see snr.m.
% The return value is in decibels.
%
% See also snr, snrPrep.
%
% Dave Mellinger

% Prepare arguments.  The most important here is t.
if (nargin < 5), m = NaN; end
[snd,npts,nsec,box,t] = snrPrep(snd, box, sRate, m);

f0 = freqs(1);
f1 = freqs(2);

filterOrder = 512;
nyq = sRate/2;
if (f1 < nyq/1.15)
  % Top freq is substantially less than nyquist. Roll off to -60 dB above top
  % freq, then decline to -inf.
  B = fir2(511, [0 f0*0.9 f0 f1 f1*1.1 nyq]/nyq, ...
      10.^([-60 -60 0 0 -60 -inf]/20));
  A = 1;			% for FIR filters this is just the vector [1]

  % Old code:
  %[B,A] = designFilter('fir2', sRate, [0 f0*0.9 f0 f1 f1*1.1 nyq], ...
      %10.^([-60 -60 0 0 -60 -inf]/20), 511);

elseif (f1 < nyq/1.05)
  % Top freq is only slightly less than nyquist.  Roll off to -60 dB at nyquist.
  B = fir2(511, [0 f0*0.9 f0 f1 nyq]/nyq, 10.^([-60 -60 0 0 -60]/20))
  A = 1;			% for FIR filters this is just the vector [1]

  % Old code:
  %[B,A] = designFilter('fir2', sRate, [0 f0*0.9 f0 f1 nyq], ...
      %10.^([-60 -60 0 0 -60]/20), 511, 1);
else
  % Top freq is nyquist, or nearly so.  Don't roll off at all at top end.
  B = fir2([0 f0*0.9 f0 nyq]/nyq, 10.^([-60 -60 0 0]/20));
  A = 1;			% for FIR filters this is just the vector [1]

  % Old code:
  %[B,A] = designFilter('fir2', sRate, [0 f0*0.9 f0 nyq], ...
      %10.^([-60 -60 0 0]/20), 511, 1);
end
%disp('Press any key to continue'); pause

r = zeros(npts,1);			% return value
for i = 1:npts
  % Each call is extracted as a "short" piece, covering the time span that
  % includes just the signal, and a "long" piece that includes ONLY the 
  % surrounding noise.  (This is different from snr.m.)

  % Get the whole sound, including some buffer space for filter warmup/down.
  samNo = round(t(i,:) * sRate);	% [s1 s2 s3 s4]
  n = length(B);			% same as filterOrder
  offI = min(n, samNo(1));
  if (isnumeric(snd))			% is it a sample vector...
    whole = snd(samNo(1)-offI+1 : min(samNo(4)+n, length(snd)));
  else					% or a filename?
    whole = soundIn(snd, samNo(1)-offI, samNo(4) + n - (samNo(1) - offI));
  end
  wFilt = filter(B, A, whole);
  samWFilt = samNo - samNo(1) + offI + n/2 + 1;	% convert samNo to wFilt index
  samWFilt = max(1, min(length(wFilt), samWFilt));

  % Extract "short" and compute its maximum absolute sample value.
  short = wFilt(samWFilt(2) : samWFilt(3)-1);
  maxval = max(abs(short));		% max sample value

  % Extract "long" and compute its RMS value.
  long = [wFilt(samWFilt(1) : samWFilt(2)-1); wFilt(samWFilt(3) : samWFilt(4))];
  rms = sqrt(mean(long.^2));

  %subplot(211); plot(short)
  %subplot(212); plot(long); drawnow
  r(i) = maxval / rms;
end

rDB = 10 * log10(r); disp('Using 10log10() for dB; should it be 20log10()?')
