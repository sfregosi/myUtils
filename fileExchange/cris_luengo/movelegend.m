%MOVELEGEND Moves the legend to a new position.
%   MOVELEGEND(POS) places the legend in the specified
%   location:
%       0 = Automatic "best" placement (least conflict with data)
%       1 = Upper right-hand corner (default)
%       2 = Upper left-hand corner
%       3 = Lower left-hand corner
%       4 = Lower right-hand corner
%      -1 = To the right of the plot
%
%   MOVELEGEND(H,POS) moves the legend with handle H or the legend
%   in axes H to POS.
%
%   See also LEGEND

% (c) by Cris Luengo, May 2001
% 13 December 2002: New syntax added: poxition relative to axes

function movelegend(varargin)

if nargin==2
   hl = varargin{1};
   pos = varargin{2};
   err = 1;
   if length(hl)==1,
      if ishandle(hl) & strcmp(get(hl,'type'),'axes')
         if strcmp(get(hl,'tag'),'legend');
            err = 0;
         else
            hl = find_legend(hl);
            err = 0;
         end
      end
   end
   if err
      error('Invalid handle');
   end
else
   hl = legend;
   if nargin==0
      pos = 1;
   else
      pos = varargin{1};
   end
end

ud = get(hl,'userdata');
ud.legendpos = pos;
set(hl,'userdata',ud);
legend(hl);

%--------------------------------
function [hl] = find_legend(ha)
hl = findobj(allchild(get(ha,'parent')),'Tag','legend');
if ~isempty(hl)
   ud = get(hl,{'userdata'});
   for ii=1:length(ud)
      if isfield(ud{ii},'PlotHandle') & ud{ii}.PlotHandle == ha
         hl = hl(ii);
         return
      end
   end
end
hl = [];
