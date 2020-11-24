function [ travelTime ] = calcTravelTime( pos1, pos2, speedOfSound );
%CALCTRAVELTIME calculates the time in seconds for a sound to travel between two
%positions. pos1 and pos2. pos1 and pos2 are cartesian co-ordinates [x,y,z]
%in meters. speedOfSound in ms^-1; 
%   
travelTime=pdist([pos1; pos2],'euclidean')/speedOfSound;

end

