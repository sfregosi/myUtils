function RGB = hillshadeMap(Z, refvec, cmap, azimuth, elevation)
% HILLSHADEMAP Creates a hillshaded RGB image from geographic raster data
%
% Inputs:
%   Z         - Raster of elevation/bathymetry (same size as lat/lon)
%   lat, lon  - Latitude and longitude grids (meshgrid format)
%   cmap      - n×3 colormap (e.g., combined ocean+land)
%   azimuth   - Illumination azimuth in degrees (0 = north, clockwise)
%   elevation - Illumination elevation angle in degrees
%
% Output:
%   RGB       - Hillshaded RGB image (nRows×nCols×3)

% Normalize Z to [0,1] for colormap indexing
zmin = min(Z(:));
zmax = max(Z(:));
Z_scaled = (Z - zmin) / (zmax - zmin);

% Map Z to RGB
[nRows, nCols] = size(Z);
RGB = ind2rgb(round(Z_scaled*(size(cmap,1)-1))+1, cmap);

% Compute geographic gradients
[FX, FY] = gradientm(Z, refvec);

% Compute slope and aspect
slope = atan(sqrt(FX.^2 + FY.^2));
aspect = atan2(FY, -FX);

% Convert angles to radians
az = deg2rad(azimuth);
el = deg2rad(elevation);

% Hillshade formula
hs = cos(el).*cos(slope) + sin(el).*sin(slope).*cos(az - aspect);
hs = max(min(hs, 1), 0);  % clamp to [0,1]

% Apply hillshade to RGB channels
for k = 1:3
    RGB(:,:,k) = RGB(:,:,k) .* hs;
end

end
