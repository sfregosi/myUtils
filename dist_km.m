function d_km = dist_km(pt1, pt2)

% points should be in format [lat lon];

d_km = mean(deg2km(distance(pt1,pt2)));
