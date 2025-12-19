function cmap = makeTopoColormap(Z)
% MAKETOPOCOLORMAP	Make combined and scaled bathymetry/land colormap
%
%   Syntax:
%       CMAP = MAKETOPOCOLORMAP(Z)
%
%   Description:
%       Detailed description here, please
%
%   Inputs:
%       input   describe, please
%
%	Outputs:
%       output  describe, please
%
%   Examples:
%
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   05 November 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get mins and max of depth/elevation data
zMin = min(Z(:));
zMax = max(Z(:));

% get fraction of total colormap that's positive (land) or negative (ocean)
nColors = 256;
fracOcean = abs(zMin) / (abs(zMin) + zMax);
nOcean = max(1, round(nColors * fracOcean));
nLand  = max(1, nColors - nOcean);

% pull ocean colors from cmocean's 'ice' (mid colors)
cmapOceanFull = cmocean('ice', 256);
cmapOceanMid = cmapOceanFull(70:230, :); % darker colors
cmapOcean = interp1(1:size(cmapOceanMid, 1), cmapOceanMid, ...
    linspace(1, size(cmapOceanMid, 1), nOcean));
% --- Land colors (use only top half of topo, i.e., green→brown→white)
cmapTopoFull = cmocean('topo', 256);
cmapLandHalf = cmapTopoFull(129:end, :);  % upper half = land
cmapLand = interp1(1:size(cmapLandHalf,1), cmapLandHalf, ...
                   linspace(1, size(cmapLandHalf,1), nLand));
cmap = [cmapOcean; cmapLand];

% for testing
% colormap(cmap);
end
