function decdeg = ddmm2decdeg(ddmm)
% DDMM2DECDEG	Convert DDMM (no space) to decimal degrees
%
%   Syntax:
%       DECDEG = DDMM2DECDEG(DDMM)
%
%   Description:
%       Utility to convert coordinates from decimal minutes (with no space
%       between, e.g., -15112.5482) to decimal degrees
%
%   Inputs:
%       ddmm    N-by-1 vector of coordinates in format DDMM.MMMM
%
%	Outputs:
%       decdeg  N-by-1 vector of coordinates in decimal degrees
%
%   Examples:
%       ddmm = [-15802.7258; -15802.7318]
%       decdeg = ddmm2decdeg(ddmm)
%       decdeg =
%                 -158.04543
%                 -158.04553      
%
%   See also DEGMIN2DECDEG, DECDEG2DEGMIN, DECDEG2DEGMINSEC,
%   DEGMINSEC2DECDEG
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   2026 March 13
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sgn = sign(ddmm);
ddmm = abs(ddmm);

deg = floor(ddmm/100);
min = ddmm - deg*100;

decdeg = sgn.*(deg + min/60);

end