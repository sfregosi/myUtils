% BOXPLOT   Makes a box plot of grouped data
%    BOXPLOT(Y), with Y a numeric array, plots a box for each of the columns
%    in Y. Each box will be placed on integer positions along the x-axis,
%    corresponding to the column number. The box indicates the 25th and 75th
%    percentiles, a bar indicates the 50th percentile, and whiskers indicate
%    the max and min datum.
%
%    H = BOXPLOT(Y) returns one handle per box.
%
%    BOXPLOT(C), with C a cell array, plots a box for each element of C.
%
%    BOXPLOT(Y,'outlier') changes the plot such that the whiskers indicate
%    the max and min datum still within 1.5 IQR (the height of the box). Data
%    outside the whiskers are shown as dots.
%    H = BOXPLOT(Y,'outlier') returns two handles per box (one for the box,
%    one for the dots representing the outliers). The outlier handle can be 0
%    if there were no outliers to plot.
%
%    BOXPLOT(...,'boxwidth',W,'barlength',S) additionally sets the width of
%    the box as a fraction of the distance between boxes, and the total length
%    of the bar that represents the median. It is recommended that S>=W. By
%    default, W=0.4 and S=0.5.
%
%    Note that this function was not designed to be a drop-in replacemenet for
%    the function with the same name in the statistics toolbox. It has a
%    different syntax and different options.

% (c) Cris Luengo, 11 July 2012, Uppsala, Sweden.
% 31 July 2012:     By default the whiskers now give max and min.
%                   Added 'outlier' syntax for previous behaviour.
% 12 December 2013: Added 'boxwidth' and 'barlength' options.
%                   Correctly computing median and percentiles using averages
%                   in case of even number of input values.
% 15 January 2017:  Added syntax with cell array input.

function h_out = boxplot(data,varargin)
outlier = 0;
w = 0.4;   % box width
s = 0.5;   % length of median bar
ii = 1;
while ii<nargin
   if ~ischar(varargin{ii})
      error('Expected paramter string');
   end
   switch varargin{ii}
   case 'outlier'
      outlier = 1;
   case 'boxwidth'
      ii = ii+1;
      w = varargin{ii};
   case 'barlength'
      ii = ii+1;
      s = varargin{ii};
   otherwise
      error('Unknown paramter string');
   end
   ii = ii+1;
end

axh = newplot;
ish = ishold(axh);
hold(axh,'on');
if isnumeric(data)
   n = size(data,2);
   if outlier
      h = zeros(2,n);
   else
      h = zeros(1,n);
   end
   for ii=1:n
      h(:,ii) = plotonebox(axh,data(:,ii),ii,outlier,w,s);
   end
elseif iscell(data)
   n = numel(data);
   if outlier
      h = zeros(2,n);
   else
      h = zeros(1,n);
   end
   for ii=1:n
      h(:,ii) = plotonebox(axh,data{ii}(:),ii,outlier,w,s);
   end
else
   error('Input array must be numeric or a cell array');
end
if ~ish
   hold(axh,'off');
end
set(axh,'xtick',1:n,'xlim',[0,n]+0.5);
if nargout>0
   h_out = h;
end

function h = plotonebox(axh,y,x,outlier,w,s);
n = length(y);
if n==1
   q1 = y;
   q2 = y;
   q3 = y;
else
   y = sort(y);
   t = 0.25*(n+1);
   t0 = floor(t);
   t1 = ceil(t);
   t = t-t0;
   q1 = y(t0)*t + y(t1)*(1-t);
   t = 0.50*(n+1);
   t0 = floor(t);
   t1 = ceil(t);
   t = t-t0;
   q2 = y(t0)*t + y(t1)*(1-t);
   t = 0.75*(n+1);
   t0 = floor(t);
   t1 = ceil(t);
   t = t-t0;
   q3 = y(t0)*t + y(t1)*(1-t);
end
if outlier
   iqr = q3-q1;
   I1 = y < q1-1.5*iqr;
   I2 = y > q3+1.5*iqr;
   outliers = y(I1|I2);
   y(I1|I2) = [];
   h = [0;0];
else
   outliers = [];
   h = 0;
end
q0 = y(1);
q4 = y(end);
w = w/2;
s = (s/2)-w;
l = x-w;
r = x+w;
px = [ l,  r,  r,  l,  l,  NaN, l-s, r+s, NaN, x,  x,  NaN, x,  x  ];
py = [ q1, q1, q3, q3, q1, NaN, q2,  q2,  NaN, q0, q1, NaN, q3, q4 ];
h(1) = line(px,py,'parent',axh,'color','black','linestyle','-','linewidth',1,...
            'marker','none');
if ~isempty(outliers)
   h(2) = line(repmat(x,size(outliers)),outliers,'parent',axh,'linestyle','none',...
          'linewidth',1,'marker','.','markeredgecolor','black');
end
