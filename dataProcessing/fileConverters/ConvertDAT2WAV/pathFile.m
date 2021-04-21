function f = pathFile(p)
% filename = pathFile(pathname)
% Given a pathname, strip off the leading directory names.
%
% See also pathRoot, pathExt, pathDir, pathFileDisk, filesep, fileparts.

w = [0 find(p == '/' | p == '\')];
f = p(w(end)+1 : end);
