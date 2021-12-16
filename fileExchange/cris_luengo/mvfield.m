function t = mvfield(s,oldfield,newfield)
%MVFIELD Rename structure field.
%   S = MVFIELD(S,'oldfield','newfield') renames the specified field
%   in the structure array S.
%
%   S = MVFIELD(S,OLDFIELDS,NEWFIELDS) renames more than one field
%   at a time when OLDFIELDS and NEWFIELDS are character arrays or cell
%   arrays of strings. The changed structure is returned.
%
%   See also RMFIELD, SETFIELD, GETFIELD, FIELDNAMES, STRVCAT.

%   (c) by Cris Luengo, September 2000
%   Adapted from RMFIELD, which is Copyright (c) 1984-98 by The MathWorks, Inc.

if ~isa(s,'struct'), error('S must be a structure array.'); end
if isstr(oldfield),
  oldfield = cellstr(oldfield);
elseif ~iscellstr(oldfield),
  error('OLDFIELD must be a cell array of strings.');
end
if isstr(newfield),
  newfield = cellstr(newfield);
elseif ~iscellstr(newfield),
  error('NEWFIELD must be a cell array of strings.');
end
if prod(size(oldfield)) ~= prod(size(newfield))
  error('OLDFIELD and NEWFIELD must have the same number of strings  .');
end
of = fieldnames(s);

% Create a list with new field names.
nf = of;
for i=1:prod(size(oldfield))
  j = strmatch(oldfield{i},of,'exact');
  if isempty(j),
    error(sprintf('A field named ''%s'' doesn''t exist.',field{i}));
  end
  nf{j} = newfield{i};
end

% Now change the fieldnames by copying them all.
t = [];
for i=prod(size(s)):-1:1
  for j=1:length(nf)
    t = setfield(t,{i},nf{j},getfield(s,{i},of{j}));
  end
end
if ~isempty(t)
  t = reshape(t,size(s));
end
