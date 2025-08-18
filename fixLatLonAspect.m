function fixLatLonAspect(axArray)
% FIXLATLONASPECT Adjust aspect ratio for lat/lon plot
%
%   Syntax:
%       FIXLATLONASPECT(axArray)
%
%   Description:
%       Set the data aspect ratio for a two-axes plot of lat/lon data
%       created with standard plotting tools (rather than the mapping
%       toolbox) so that the axes are proportional to real-world distances
%       at that latitude.
%
%       This will preserve the aspect ratio even through resizing and
%       zooming in/out on the plot.
% plot of lat/lon data created with
%       standard plotting tools (rather than the mapping toolbox) so that
%       the axes are proportional to the real-world distances at that
%       latitude.
%
%       If no input arguments are given it will try to detect the lat.lon
%       range from the plot objects or from the axes limits.
%
%   Inputs:
%       axArray   vector or cell array of axes handles (e.g., [ax1 ax2])
%
%	Outputs:
%       none, adjusts axes of current figure
%
%   Examples:
%       % two axes
%       linkaxes([ax1 ax2]);
%       fixLatLonAspect([ax1 ax2]);
%
%       % many axes
%       axArray = findall(gcf, 'Type', 'axes');
%       makeLatLonAspectZoomProofMulti(axArray);
%
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   15 August 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(axArray) || ~all(isgraphics(axArray, 'axes'))
    error('Input must be one or more valid axes handles.');
end

% Make sure it's a row vector of handles
axArray = axArray(:)';

% Apply once at start
applyAspect(axArray);

% Add listeners to automatically reapply on zoom/pan
% We just listen to the first axis in the list
addlistener(axArray(1), 'XLim', 'PostSet', @(~,~) applyAspect(axArray));
addlistener(axArray(1), 'YLim', 'PostSet', @(~,~) applyAspect(axArray));

% Nested function: apply aspect ratio correction
    function applyAspect(axArray)
        yl = ylim(axArray(1)); % latitude range from first axis
        lat0 = mean(yl) * pi/180; % mean latitude in radians
        for ax = axArray
            daspect(ax, [1 cos(lat0) 1]);
        end
    end
end