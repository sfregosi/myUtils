function [latout,lonout,deltadist] = interpm2(lat,lon,maxdiff,method,units,tolerance)
% INTERPM2 employs the interpm function to densifiy lat/lon sampling in
% lines or polygons, but extends the available input units to include
% 'meters' or 'kilometers'. However, note that if units of meters or kilometers 
% are specified, the resultant spacing will be only an approximation, due
% to an underlying approximation of the Earth's shape as a sphere of mean
% radius 6371 km.  Requires Mapping Toolbox. 
% 
% 
% Syntax
% [latout,lonout] = interpm(lat,lon,maxdiff)
% [latout,lonout] = interpm(lat,lon,maxdiff,method)
% [latout,lonout] = interpm(lat,lon,maxdiff,method,units)
% [latout,lonout] = interpm(lat,lon,maxdiff,method,units,tolerance)
% [latout,lonout,deltadist] = interpm(...)
% 
% 
% Description 
% [latout,lonout] = interpm(lat,lon,maxdiff) fills in any gaps in latitude (lat) or 
% longitude (lon) data vectors that are greater than a defined tolerance maxdiff apart 
% in either dimension. The angle units of the three inputs need not be specified, but 
% they must be identical. latout and lonout are the new latitude and longitude data 
% vectors, in which any gaps larger than maxdiff in the original vectors have been 
% filled with additional points. The default method of interpolation used by interpm 
% is linear.
% 
% [latout,lonout] = interpm(lat,lon,maxdiff,method) interpolates between vector data 
% coordinate points using a specified interpolation method. Valid interpolation method 
% strings are 'gc' for great circle, 'rh' for rhumb line, and 'lin' for linear 
% interpolation.
% 
% [latout,lonout] = interpm(lat,lon,maxdiff,method,units) specifies the units used, 
% where units can be 'degrees', 'radians', 'meters', or 'kilometers'. The default is 
% 'degrees'. If units are meters or kilometers, the calculation will assume the  
% Earth is a sphere of radius 6371 km. 
% 
% [latout,lonout] = interpm(lat,lon,maxdiff,method,units,tolerance) specifies  
% an amount of acceptable deviation between maxdiff and the average distance between 
% output points. Due to an approximation of the Earth as a sphere, the
% first solution this function calculates may not yield points exactly
% maxdiff apart. If, however, you specify maxdiff = 15 meters and tolerance
% = 0.010, the function will keep trying until it finds a solution in which the 
% average distance between points is 15+/-0.010 meters. If no tolerance is declared 
% a value corresponding to 0.1% of maxdiff will be assumed.  
%
% [latout,lonout,deltadist] = interpm(...) returns the mean distance between 
% output points given by latout and lonout. Units of deltadist are in meters 
% unless input units are kilometers, in which case deltadist units are in 
% kilometers. 
% 
% Example 1: 
% Draw a great circle route from Denver to Lisbon at 25 km spacing; compare to linear 
% and rhumb line paths: 
% 
% denver = [39.739167, -104.984722]; % city coordinates in the form [lat lon]
% lisbon = [38.713811, -9.139386]; 
% 
% [lat25km,lon25km] = interpm2([denver(1) lisbon(1)],[denver(2) lisbon(2)],25,'gc','km'); 
% 
% figure
% worldmap('world')
% land = shaperead('landareas', 'UseGeoCoords', true);
% geoshow(land, 'FaceColor', [0.5 0.7 0.5])
% plotm(lat25km,lon25km,'b','linewidth',2)
% 
% % Now compare great circle path to linear and rhumb lines: 
% [lat25rh,lon25rh] = interpm2([denver(1) lisbon(1)],[denver(2) lisbon(2)],25,'rh','km'); 
% [lat25lin,lon25lin] = interpm2([denver(1) lisbon(1)],[denver(2) lisbon(2)],25,'lin','km'); 
% 
% plotm(lat25rh,lon25rh,'r','linewidth',2)
% plotm(lat25lin,lon25lin,'m','linewidth',2)
% 
%     
% Example 2:
% Densify the path given by [lat,lon] to 15-meter spacing along a great circle route: 
% 
% lat = [39.61 39.31 39.01 38.71 38.40 38.10 37.80 37.49 37.19 36.89 36.58];  
% lon = [16.72 16.53 16.34 16.15 15.97 15.80 15.62 15.46 15.29 15.13 14.97];
% 
% [lat15m,lon15m] = interpm2(lat,lon,15,'gc','meters'); 
% 
% figure
% worldmap([min(lat) max(lat)],[min(lon) max(lon)])
% plotm(lat,lon,'bp') % original data
% plotm(lat15m,lon15m,'k.') % data densified to ~15 m spacing 
% 
% % Check actual distance between densified points: 
% distance(lat15m(1),lon15m(1),lat15m(2),lon15m(2),referenceEllipsoid('wgs 84'))
% 
% 
% Author Info
% This script was created by Chad A. Greene of the Institute for Geophysics
% at the University of Texas at Austin on June 11, 2014. 
% 
% This is version 2, June 16 2014. 
% 
% See also interpm, intrplat, and intrplon. 

assert(nargin>=3,'Interpm2 must have at least three inputs.')
usekm = false;
usem = false; 
percentError = 100; 
usermaxdiff = maxdiff; 

if exist('units','var')
    switch lower(units)
        case {'deg','degree','degrees'}
            units = 'degrees'; 

        case {'radian','radians','rad'} 
            units = 'radians'

        case {'km','kilometer','kilometers'} 
            maxdiff = km2deg(maxdiff); 
            usekm = true; 
            units = 'degrees'; 

        case {'m','meter','meters'} 
            maxdiff = km2deg(maxdiff/1000); 
            units = 'degrees'; 
            usem = true; 

        otherwise
            warning('Units not recognized.')
            return    
    end
else
    units = 'degrees';
end

if exist('method','var') 
    switch lower(method)
        case {'gc','great circle','mechanical bird path'}
            method = 'gc'; 

        case {'rh','rhumb','rhumb line'}
            method = 'rh'; 
            
        case {'lin','linear'}
            method = 'lin'; 
            
        otherwise
            warning('Interpolation method not recognized. Choose linear, great circle, or rhumb line')
            return
    end
else
    method = 'lin'; 
end

if exist('tolerance','var')
    assert(isscalar(tolerance),'Tolerance value must be a scalar.')
    percentAcceptableError = 100*tolerance/usermaxdiff; 
end
if ~exist('tolerance','var')
    percentAcceptableError = .1; 
end


% Solve iteratively up to 30 times: 
for n = 1:31
    if abs(percentError)>abs(percentAcceptableError)
        if n==31
            warning('Cannot find a valid solution.')
            return
        end
        [latout,lonout] = interpm(lat,lon,maxdiff,method,units);

        % Calculate average distance between points:
        deltadist = mean(distance(latout(1:end-1),lonout(1:end-1),latout(2:end),lonout(2:end),referenceEllipsoid('wgs 84'))); 

        if usekm 
            deltadist = deltadist/1000; 
        end

        if usem || usekm
            percentError = 100*(deltadist-usermaxdiff)/usermaxdiff; 
        end
        
        if ~usem && ~usekm
            percentError = 0; 
        end

        maxdiff = maxdiff*(100-percentError)/100; 
    end
end
   

end