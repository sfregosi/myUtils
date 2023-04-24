function [degmin] = decdeg2degmin(decdeg)
% DECDEG2DEGMIN	Convert decimal degrees to degree decimal minutes
%
%	Syntax:
%		DEGMIN = DECDEG2DEGMIN(DECDEG)
%
%	Description:
%		Detailed description here, please
%	Inputs:
%		decdeg  N-by-1 vector of coordinates in decimal degrees 
%       e.g., decdeg = [30.4867; -118.9833]
%
%	Outputs:
%		degmin  N-by-2 matrix of coordinates in degrees decimal minutes
%		with degrees in the first column and decimal minutes in the second
%		column
%
%	Examples:
%       decdeg = [30.4867; -118.9833];
%       degmin =
%               30.0000   29.2020
%               -118.0000   58.9980
%	See also
%       degmin2decdeg(degmin)
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
%
%	FirstVersion: 	24 July 2016
%	Updated:        23 April 2023
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

degmin = zeros(length(decdeg), 1);

for f = 1:length(decdeg)
    deg = fix(decdeg(f));
    dec = abs(rem(decdeg(f), 1));
    min = dec*60;
    degmin(f,1:2) = [deg min];
end


