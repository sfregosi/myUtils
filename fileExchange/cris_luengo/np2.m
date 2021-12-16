function p = np2(n)
%NP2 Next higher power of 2.
%   NP2(N) works the same as NEXTPOW2, except that it can work
%   on arrays.

% (c)2000 by Cris Luengo

[f,p] = log2(abs(n));

% Check if n is an exact power of 2.
N = (f == 0.5);
p(N) = p(N)-1;

% Check for infinities and NaNs
k = ~isfinite(f);
p(k) = f(k);
