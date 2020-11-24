function [x1, y1, x2, y2]=latlon2utmConversion(lat1, lon1, lat2, lon2)
%function to compute UTM N & E (in meters) from two lat/lon coordinates
%being done for PMRF range area
%UTM Conversions using NAD83/WGS84 Datum
%Dec 27 2011 - FROM STEVE MARTIN

%NAD83/WGS84 Variables
% a = 6373137 = equatorial radius in meters
% b = 6356752.3142 = polar radius
% flat = 1/298.257223563 

%Symbols
% lat = latitude of point
% long = longitude of point
% long0 = central meridian of zone
% k0 = scale along long0 = 0.9996
% e = sqrt(1-b^2/a^2) =eccentricity of the earth's elliptical cross-section
%   e = 0.08; e1^2 = (e*a/b)^2 = e^2(1-e^2) = 0.007 
% n = (a-b)/(a+b)
% rho = a*(1-e^2)/(1-e^2*sin^2(lat))^(3/2) = radius of curvature of the earth
%   in the meridian plane.  
% nu = a/(1-e^2*sin^2(lat))^(1/2) = radius of curvature of the earth
%   perpendicular to the merdidian plane and the distance from the point in 
%   question to the polar axis, measured perpendicular to the earth's
%   surface.
% p = long - long0 in radians;
% S = merdidional arc

%TEST CASE
% lat = 22.7692;
% lon = -159.9504;
inputWE = 'W'; %W/E
inputNS = 'N'; %N/S

%Convert to radians
lat1rad = lat1*pi/180;
lon1rad = lon1*pi/180;
lat2rad = lat2*pi/180;
lon2rad = lon2*pi/180;
%Calculate CM 
% numbers are variables from UTMConversions1.xls
Wcheck = strcmp(inputWE, 'W');
Scheck = strcmp(inputNS, 'S');

Saddfactor = 0;
if Scheck >0
    lat1rad = -1*lat1rad;
    Saddfactor = 10000000;
    lat2rad = -1*lat2rad;
end

if Wcheck > 0
    lon1 = -1*lon1;
    lon2 = -1*lon2;
    cmzonevar1 = fix((180+lon1)/6)+1;
    cmzonevar2 = fix((180+lon2)/6)+1;
else
    cmzonevar1 = fix(lon1/6)+31;
    cmzonevar2 = fix(lon2/6)+31;
end
lon01 = 6*cmzonevar1-183;
lon02 = 6*cmzonevar2-183;

%Calculate the Meridional Arc
a = 6378137 ;
b = 6356752.3142 ;
n = (a-b)/(a+b);
e = sqrt(1-b^2/a^2);
e1sq = (e*a/b)^2;
nu1 = a/(1-e^2*sin(lat1rad)^2)^(1/2);
p1 = (pi/180)*(lon1 - lon01);
nu2 = a/(1-e^2*sin(lat2rad)^2)^(1/2);
p2 = (pi/180)*(lon2 - lon02);
k0 = 0.9996;

A = a*(1-n +(5/4)*(n^2-n^3) + (81/64)*(n^4-n^5));
B = (3*a*n/2)*(1-n-(7/8)*(n^2-n^3)+(55/64)*(n^4-n^5));
C = a*n^2*(15/16)*(1-n+(3/4)*(n^2-n^3));
D = (35*a*n^3/48)*(1-n+11*n^2/16);
E = (315*a*n^4/51)*(1-n);
    
S1 = A*lat1rad -B*sin(2*lat1rad) + C*sin(4*lat1rad)-D*sin(6*lat1rad) + E*sin(8*lat1);
S2 = A*lat2rad -B*sin(2*lat2rad) + C*sin(4*lat2rad)-D*sin(6*lat2rad) + E*sin(8*lat2);

K11 = S1*k0;
K12=S2*k0;
K21 = k0*nu1*sin(lat1rad)*cos(lat1rad)/2;
K22 = k0*nu2*sin(lat2rad)*cos(lat2rad)/2;

K31 = ((k0*nu1/24)*sin(lat1rad)*cos(lat1rad)^3)*(5-tan(lat1rad)^2+9*e1sq*cos(lat1rad)^2+4*e1sq^2*cos(lat1rad)^4);
K32 = ((k0*nu2/24)*sin(lat2rad)*cos(lat2rad)^3)*(5-tan(lat2rad)^2+9*e1sq*cos(lat2rad)^2+4*e1sq^2*cos(lat2rad)^4);
K41 = k0*nu1*cos(lat1rad);
K42 = k0*nu2*cos(lat2rad);
K51 = ((k0*nu1/6)*cos(lat1rad)^3)*(1-tan(lat1rad)^2+e1sq*cos(lat1rad)^2);
K52 = ((k0*nu2/6)*cos(lat2rad)^3)*(1-tan(lat2rad)^2+e1sq*cos(lat2rad)^2);
% northing
y1 = Saddfactor + K11 + K21*p1^2+ K31*p1^4;
%easting
x1 = 500000+K41*p1 + K51*p1^3;
% northing
y2 = Saddfactor + K12 + K22*p2^2+ K32*p2^4;
%easting
x2 = 500000+K42*p2 + K52*p2^3;
return










