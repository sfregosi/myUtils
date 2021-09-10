function [decdeg] = degmin2decdeg(degmin)
% Convert degree minutes to decimal degrees
%
% Inputs:
%       degmin should be N-by-2 matrix of coordinates in degree minutes
%           i.e. degmin=[30 29.2020;-118 58.9980];
% Output:
%       decdeg will be N-by-1 vector of coordinates in decimal degrees
%           i.e. decdeg =
%                   30.4867
%                   -118.9833
%
% Inverse fucntion is decdeg2degmin(decdeg)
%
% Created 7/24/2016 by S. Fregosi

decdeg=zeros(length(degmin(:,1)),1);

for f=1:length(degmin(:,1))
    dec=degmin(f,2)/60;
    deg=degmin(f,1);
    if deg>0
        decdeg(f,1)=deg+dec;
    else
        decdeg(f,1)=deg-dec;
    end
end
