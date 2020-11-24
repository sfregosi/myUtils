function    k = choosewindow(x,lev,Np) ;

%    k = choosewindow(x,lev,[Np])
%    Find the most compact closed interval of x that contains
%    at least lev fraction of the energy.
%    Optionally removes Np noise power from the instantaneous input power
%    before computing the signal energy. This is important when the signal-
%    to-noise ratio is low.
%
%    Returns k, the indices of the interval.
%    This is a brute-force method and so is not efficient for long signals.
%
%    Example:
%     n = randn(10000,1) ;
%     s = [zeros(5000,1);sin(2*pi*0.05*(1:2000)');zeros(3000,1)] ;
%     % high SNR - don't need the noise power
%     r = s+0.1*n ;            % signal with a little noise
%     k = choosewindow(r,0.9);
%     length(k)            % signal duration estimate
%     sqrt(mean(r(k).^2))  % RMS signal estimate
%
%     % low SNR - use an estimate of the noise power e.g., from the
%     % signal recorded just before the signal of interest
%     r = s+n ;            % signal with a lot of noise
%     np = cov(n) ;        % noise power estimate
%     k = choosewindow(r,0.9,np);
%     length(k)            % signal duration estimate
%     sqrt(mean(r(k).^2-np))  % RMS signal estimate
%
%    markjohnson@st-andrews.ac.uk
%    last modified: 15 May 2006

k = [] ;
if nargin<2,
   help choosewindow
   return
end

if nargin<3,
   Np = 0 ;
end

if lev>1 | lev<=0,
   fprintf(' Energy fraction must be between 0 and 1\n')
   return
end

% cumulative energy of transient based on prior measurement of 
% the noise power
cs = cumsum(abs(x).^2-Np) ;

% find latest start point in cs that still gives lev energy
kmax = max(find(cs<(cs(end)*(1-lev)))) ;
if isempty(kmax),
   kkk = min(find(cs>=cs(end)*lev)) ;
   k = (1:kkk)' ;
   return
end
   
n = NaN*ones(kmax,1) ;

% test each starting point from 1 to kmax for window length
for kk=1:kmax,
   kkk = min(find((cs-cs(kk))>=cs(end)*lev)) ;
   if ~isempty(kkk),
      n(kk) = kkk ;
   end   
end

% choose smallest window that covers the energy
[p,m] = min(n-(1:kmax)') ;
k = (m:n(m))' ;
