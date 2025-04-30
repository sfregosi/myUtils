function tm = unix2matlab(tu)
% UNIX2MATLAB	Convert from Unix time (in seconds) to MATLAB datenum
%
%   Syntax:
%       TM = UNIX2MATLAB(TU)
%
%   Description:
%       Conversion between Unix time, in seconds, to MATLAB time as a
%       datenum
%
%   Inputs:
%       tu    [double] unix time in seconds from 1/1/1970 00:00:00 
%
%	Outputs:
%       tm    [double] time as MATLAB datenum (serial days from 1/1/0000)
%
%   Examples:
%       tu = 1745971200; % 30 April 2025
%       tm = unix2matlab(tu);
%
%   See also MATLAB2UNIX
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   30 April 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tm = datenum('1970', 'yyyy') + tu/86400;

end

