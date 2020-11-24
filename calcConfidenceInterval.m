function [lb, ub] = calcConfidenceInterval(D, cv)

% calculate a 95% confidence interval from a density estimate and
% correspond cv. lb and ub are lower bound and upper bound

% confidence interval
C = exp(1.96*sqrt(log(1 + (cv).^2)));

% subtract and add to mean
lb = D./C;
ub = D.*C;

end