function [decdeg] = degminsec2decdeg(degminsec)
% Convert degree minutes seconds to decimal degrees
%
% Inputs:
%       degminsec should be N-by-3 matrix of coordinates in degree minutes
%           i.e. degminsec=[30 29 36; -118 58 16];
% Output:
%       decdeg will be N-by-1 vector of coordinates in decimal degrees
%           i.e. decdeg =
%                   30.4933
%                   -118.9711
%
% Inverse fucntion is decdeg2degminsec(decdeg)
%
% Created 9/10/2021 by S. Fregosi

decdeg=zeros(length(degminsec(:,1)),1);

for f = 1:length(degminsec(:,1))
    secDec = degminsec(f,3)/60;
    minDec = (degminsec(f,2) + secDec)/60;
    deg = degminsec(f,1);
    if deg > 0
        decdeg(f,1) = deg + minDec;
    else
        decdeg(f,1) = deg - minDec;
    end
end
