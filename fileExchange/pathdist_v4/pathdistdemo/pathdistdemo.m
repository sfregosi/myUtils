%% pathdist 
% The |pathdist| function uses the |distance| function to calculate cumulative distance
% traveled along a path given by the arrays lat and lon.  (Requires Mapping
% Toolbox). Always assumes WGS84 ellipsoid. 
% 
%% Syntax
% 
%  pathDistance = pathdist(lat,lon)
%  pathDistance = pathdist(...,LengthUnit)
%  pathDistance = pathdist(...,track)
%  pathDistance = pathdist(...,'refpoint',[reflat reflon])
% 
%% Description
% 
% |pathDistance = pathdist(lat,lon)| returns the cumulative distance
% traveled along the path given by (|lat|,|lon|). Distance is in meters
% by default, referenced to the WGS84 ellipsoid. The |pathDistance| array
% will be the same size as |lat| and |lon|. 
%
% |pathDistance = pathdist(...,LengthUnit)| specifies any valid length unit. 
% The following are a few |LengthUnit| options. See documentation for 
% |validateLengthUnit| for a complete list of options.
% 
% * meter	       |'m', 'meter(s)', 'metre(s)'| (default)
% * kilometer     |'km', 'kilometer(s)', 'kilometre(s)'|
% * nautical mile	|'nm', 'naut mi', 'nautical mile(s)'|
% * foot          |'ft', 'international ft','foot', 'international foot', 'feet', 'international feet'|
% * inch          |'in', 'inch', 'inches'|
% * yard          |'yd', 'yds', 'yard(s)'|
% * mile          |'mi', 'mile(s)','international mile(s)'|
%
% |pathDistance = pathdist(...,track)| uses the input string track to specify 
% either a great circle/geodesic or a rhumb line arc. If track equals |'gc'| (the default 
% value), then great circle distances are computed on a sphere and geodesic distances are 
% computed on the WGS84 ellipsoid. If track equals |'rh'|, then rhumb line distances are 
% computed on the WGS84 ellipsoid.
%
% |pathDistance = pathdist(...,'refpoint',[reflat reflon])| references the
% path distance to the point along the path nearest to |[reflat reflon]|.
% For this calculation, |pathdist| finds the point in |lat| and |lon|
% which is nearest to |[reflat reflon]| and assumes this point along
% |lat|,|lon| is the zero point. This is only an approximation, and may
% give erroneous results in cases of very sharply-curving, crossing, or 
% otherwise spaghetti-like paths; where |[reflat reflon]| lies far from any
% point along the path, or where points along the path are spaced far
% apart. 
% 
%% Example 1: Find distance traveled along a route marked by GPS measurements
% This example uses the built-in |sample_route.gpx| route. 

route = gpxread('sample_route.gpx'); % some sample data 
lat = route.Latitude; 
lon = route.Longitude; 
time = 0:255; % assume GPS measurements logged every minute

% Create a map of the route: 
figure('position',[100 50 560 800]) 
subplot(3,1,1) 
usamap([min(lat)-.05 max(lat)+.05],[min(lon)-.08 max(lon)+.08])
plotm(lat,lon,'ko-')
textm(lat(1),lon(1),'start','color',[.01 .7 .1]) 
textm(lat(end),lon(end),'end','color','r')


% Plot distance traveled:
metersTraveled = pathdist(lat,lon);

subplot(3,1,2) 
plot(time,metersTraveled)
box off; axis tight; 
xlabel('time (minutes)')
ylabel('meters traveled') 

% Plot speed: 
speed = diff(metersTraveled/1000)./diff(time/60); 

subplot(3,1,3) 
plot(time(2:end)-.5,speed)
box off; axis tight 
xlabel('time (minutes)') 
ylabel('speed (km/hr)')

%% Example 2: Calculate path length in miles referenced to a point
% Adding to the plot above, we will define a reference point at (42.354 N,
% 71.2 W). Then we will look at travel time as a function of distance from
% the reference point.  

reflat = 42.354; 
reflon = -71.2; 

subplot(3,1,1) 
plotm(reflat,reflon,'bp')
textm(reflat,reflon,'reference point','color','b') 

miFromRefPt = pathdist(lat,lon,'refpoint',[reflat reflon],'miles'); 

subplot(3,1,2) 
plot(miFromRefPt,time)
ylabel('travel time (min)') 
xlabel('distance from reference point (miles)') 
axis tight; box off; 

%% Author Info: 
% This function was written by <http://www.chadagreene.com Chad A. Greene> of the Institute for
% Geophysics at the University of Texas at Austin. June 23, 2014. Updated
% January 2015 to include more |LengthUnit| options. 


