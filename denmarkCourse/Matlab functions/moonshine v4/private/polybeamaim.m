function [aim] = polybeamaim(pressure,angle)
y = pressure(:);
x = angle(:);
range = min(x):0.01:max(x);
p = polyfit(x,y,2);
f = polyval(p,range);
[val loc] = max(f);
if loc == 1 || loc == length(range)
    aim = NaN;
else
aim = range(loc);
end
% plot(angle,pressure,'*',range,f,':r')
