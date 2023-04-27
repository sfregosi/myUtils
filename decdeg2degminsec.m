function [degminsec] = decdeg2degminsec(decdeg)
% DECDEG2DEGMINSEC	Convert decimal degrees to degrees minutes seconds
%
%	Syntax:
%		DEGMINSEC = DECDEG2DEGMINSEC(DECDEG)
%
%	Description:
%		Convert decimal degrees to degrees minutes seconds
%
%	Inputs:
%		decdeg      N-by-1 vector of coordinates in decimal degrees 
%                   e.g., decdeg = [30.4867; -118.9833]
%       
%	Outputs:
%		degminsec   N-by-3 matrix of coordinates in degrees minutes seconds
%		            with degrees in the first column and minutes in the 
%                   second column, and seconds in the third column
%
%	Examples:
%       decdeg = [30.4867; -118.9833];
%       degminsec =
%                   30      29      12.1199999999965
%                   -118    58      59.8799999999994
%	See also
%       degminsec2decdeg(degminsec)
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
%
%	FirstVersion: 	25 April 2023
%	Updated:        
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

degminsec = zeros(length(decdeg), 3);

for f = 1:length(decdeg)
    deg = fix(decdeg(f));
    dec = abs(rem(decdeg(f), 1));
    decmin = dec*60;
    min = fix(decmin);
    dec = abs(rem(decmin, 1));
    sec = dec*60;

    degminsec(f,1:3) = [deg min sec];
end

end

