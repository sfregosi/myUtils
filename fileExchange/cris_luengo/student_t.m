%STUDENT_T   Right-critical values of the Student distribution
%   T = STUDENT_T(V) returns the right-critical value of the
%   Student distribution for a=0.025 and V degrees of freedom.
%
%   See also CONFIDENCEINTERVAL

% (c)2005 by Cris Luengo, 25 January 2005
% Data from J. van Soest, "Elementaire Statistiek", 7th printing,
%    Delftse Uitgevers Maatschappij, Delft, 1992.

function t = student_t(v)
data025 = [
  12.706
   4.303
   3.182
   2.776
   2.571
   2.447
   2.365
   2.306
   2.262
   2.228
   2.201
   2.179
   2.160
   2.145
   2.131
   2.120
   2.110
   2.101
   2.093
   2.086
   2.080
   2.074
   2.069
   2.064
   2.060
   2.056
   2.052
   2.048
   2.045
   2.042 ];
data025XY = [
   30 2.042
   40 2.021
   60 2.000
  120 1.980
  1e5 1.960 ];
if any(mod(v(:),1)~=0)
   error('Illegal input value');
end
t = zeros(size(v));
for ii=1:prod(size(v))
   if v(ii)<=0
      t(ii) = NaN;
   elseif v(ii)<=30
      t(ii) = data025(v(ii));
   elseif v(ii)>=data025XY(end,1)
      t(ii) = data025XY(end,2);
   else
      t(ii) = interp1(data025XY(:,1),data025XY(:,2),v(ii),'linear');
   end
end
