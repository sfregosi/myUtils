function polar_plot(angle,magnitude,dB_range,span,orientation,varargin)
%Creates a polar plot that plots negative values
%angle = angle measurements
%magnitude = relative amplitude measurements 
%dB_range = magnitude range eg. 30 creates a plot spanning 0 to -30 dB.
%span = angular span of plot in degrees eg. [-90 90] creates standard 180 degree upwards plot
%orientation = angular rotation of the plot in degreesmagnitude = magnitude(:);
angle = angle(:);
magnitude = magnitude(:);

if nargin < 3 || isempty(dB_range)
    dB_range = 30;
end
if nargin < 4 || isempty(span)
    span = [-90 90];
end
if nargin < 5 || isempty(orientation)
    orientation = 0;
end

angle(find(magnitude < -dB_range)) = [];
magnitude(find(magnitude < -dB_range)) = [];


Angle_range = (span(1):15:span(2))+orientation;

[y_data,x_data] = pol2cart(Angle_range*pi/180,dB_range + 3);

alpha = -dB_range:6:0;
theta = Angle_range(1)+180:0.1:Angle_range(end)+180;
for m = 1:length(alpha)
    [opp(:,m),adj(:,m)] = pol2cart(theta*pi/180,alpha(m));
end
% figure;
for n = 1:length(adj(1,:))
    plot(adj(:,n),opp(:,n),'color','k')
    hold on
end
for n = 1:length(x_data)
    plot([0 x_data(n)],[0 y_data(n)],'color','k')
end

plot([0 x_data(1)],[0 y_data(1)],'k')
plot([0 x_data(end)],[0 y_data(end)],'k')

[y_points,x_points] = pol2cart((angle+orientation)*pi/180,magnitude+dB_range);

try
    plot(x_points,y_points,varargin{:})
catch
    warning('polar_plot:plotOptions',...
              'Something went wrong when plotting')
    plot(x_points,y_points,'*')
end










