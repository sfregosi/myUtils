function e = pathExt(p)
% ext = pathExt(pathname)
% Given a pathname, return the extension (without its initial '.').
% If there is no '.' in the filename, return ''.
%
% See also pathDir, pathRoot, pathFile, filesep.

extchar = '.';			% character that starts an extension

e = '';				% default result
p = pathFile(p);		% get rid of directory part of path
w = find(p == extchar);
if (length(w))
  e = p(w(length(w))+1:length(p));
end
