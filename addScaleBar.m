function addScaleBar(varargin)
% ADDSCALEBAR  Draw a custom scale bar on current map axes.
%
%   Syntax:
%       ADDSCALEBAR(VARAGRIN)
%
%   Description:
%       Detailed description here, please
%
%   Inputs:
%       Optional Name-Value pairs:
%         'Length'      total bar length in km (default 200)
%         'Major'       major segment size in km (default 100)
%         'Minor'       minor tick spacing in km (default [])
%         'AnchorLat'   bottom latitude of bar (default auto)
%         'AnchorLon'   left longitude of bar (default auto)
%         'HeightFrac'  bar height as fraction of map lat span (default 0.02)
%         'FontSize'    label size (default 12)
%
%   Examples:
%       addScaleBar('Length',200,'Major',100,'Minor',20)
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%       Generated with assistance from ChatGPT
%
%   Updated:   24 February 2026
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -------------------- Parse inputs --------------------
p = inputParser;
addParameter(p,'Length',200)
addParameter(p,'Major',100)
addParameter(p,'Minor',[])
addParameter(p,'AnchorLat',[])
addParameter(p,'AnchorLon',[])
addParameter(p,'HeightFrac',0.02)
addParameter(p,'FontSize',12)
parse(p,varargin{:})

L      = p.Results.Length;
Major  = p.Results.Major;
Minor  = p.Results.Minor;
lat0   = p.Results.AnchorLat;
lon0   = p.Results.AnchorLon;
hFrac  = p.Results.HeightFrac;
fs     = p.Results.FontSize;

% -------------------- Map limits --------------------
latlim = getm(gca,'MapLatLimit');
lonlim = getm(gca,'MapLonLimit');

latSpan = diff(latlim);
centerLat = mean(latlim);

% Default anchor location (bottom-left inset)
if isempty(lat0)
    lat0 = latlim(1) + 0.05*latSpan;
end
if isempty(lon0)
    lon0 = lonlim(1) + 0.05*diff(lonlim);
end

barHeight = hFrac * latSpan;

% -------------------- Convert km to degrees --------------------
km_per_deg_lon = deg2km(1) * cosd(centerLat);
deg_per_km = 1 / km_per_deg_lon;

Ldeg     = L * deg_per_km;
Majordeg = Major * deg_per_km;

hold on

% -------------------- Draw Major Segments --------------------
nMajor = L / Major;

for k = 0:nMajor-1
    lonStart = lon0 + k*Majordeg;
    lonEnd   = lonStart + Majordeg;

    if mod(k,2)==0
        faceColor = 'k';
    else
        faceColor = 'w';
    end

    patchm([lat0 lat0 lat0+barHeight lat0+barHeight], ...
           [lonStart lonEnd lonEnd lonStart], ...
           faceColor, 'EdgeColor', 'k', 'HandleVisibility', 'off');
end

% -------------------- Minor Ticks --------------------
if ~isempty(Minor)
    Minordeg = Minor * deg_per_km;
    nMinor = L / Minor;

    for k = 0:nMinor
        lonTick = lon0 + k*Minordeg;
        plotm([lat0 lat0+barHeight*0.6], ...
              [lonTick lonTick], 'k', 'LineWidth', 1, ...
              'HandleVisibility', 'off');
    end
end

% -------------------- Labels --------------------
textm(lat0 - barHeight*1.2, lon0, '0', ...
    'HorizontalAlignment','center','FontSize',fs)

textm(lat0 - barHeight*1.2, lon0 + Ldeg/2, ...
    sprintf('%d km', L/2), ...
    'HorizontalAlignment','center','FontSize',fs)

textm(lat0 - barHeight*1.2, lon0 + Ldeg, ...
    sprintf('%d km', L), ...
    'HorizontalAlignment','center','FontSize',fs)

end