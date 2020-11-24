function [snd,npts,nsec,box,t] = snrPrep(snd, box, sRate, m)
%snrPrep	Auxiliary function for snrTonal, snrWhistle and snrClick
%
% Prepare arguments for snrTonal,snrWhistle, and snrClick.  
%The most important return value is
% t, which has columns of 
%        [noiseStart  noiseEndCallStart  callEndNoiseStart  callEnd]
%
% Dave Mellinger

if (isnumeric(snd) && size(snd,2) ~= 1)
  snd = snd(:);					% make into column vector
end
npts = size(box,1);				% number of points to compute
if (isnumeric(snd))
  nsec = length(snd) / sRate;			% number of seconds
else
  [dummy1,dummy2,nsam] = soundIn(snd, 0, 0);
  nsec = nsam / sRate;
end

% Arrange box chronologically.
[dummy,idx] = sort(box(:,1));
box = box(idx,:);

% Set up t to have bounds of signals [as t(2:3,:)] and surrounding noise [as 
% t(:,1:2) and t(:,3:4)].  Includes endpoints from median inter-call duration.
if (isnan(m))					% user might specify m
  if (npts > 1)
    m = median(box(2:end,1) - box(1:end-1,2));	% median inter-call duration
  else
    m = diff(box(1,1:2)) * 3;			% only 1 call: use its len * 3
  end
end
t = [[max(0,box(1,1)-m); box(1:end-1,2)] ...	% col 1: noise start
	box(:,1) ...				% col 2: noise end, call start
	box(:,2) ...				% col 3: call end, noise start
	[box(2:end,1); min(nsec,box(end,2)+m)]];% col 4: noise end

