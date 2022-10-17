function d_km = dist_km(pt1, pt2)
% DIST_KM	calculates approximate distance (in km) between two lat/lon points
%
%	Syntax:
%		D_KM = DIST_KM(PT1, PT2)
%
%	Description:
%		Calculates the great circle distance, in km, between two 
%       latitude/longitude points on a sphere with the mean radius of 
%       6371 km, the mean radius of Earth. Uses the MATLAB Mapping Toolbox
%       functions 'distance' and 'deg2km'
%	Inputs:
%		pt1 	first point, in latitude and longitude, in the format 
%               [lat lon]
%		pt2 	second point, in latitude and longitude, in the format 
%               [lat lon]
%	Outputs:
%		d_km 	distance, in km
%
%	Examples:
%       d_km = dist_km([32 -122], [33 -122])
%       d_km =
%          111.194926644559
%	See also
%       distance.m deg2km
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
%
%	FirstVersion: 	unknown
%	Updated:        17 October 2022
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d_km = deg2km(distance(pt1,pt2));
