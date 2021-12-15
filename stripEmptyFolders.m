function [dirStructNew, folderNames] = stripEmptyFolders(dirStruct)

% get the folder names for a directory with '.' and '..' removed
%
%
% INPUT:    dirStruct       structure output typically from a dir() command
% 
% OUTPUT:   dirStructNew    dirStruct without '.' and '..' rows
%           folderNames     names of folders as cell array

folderNames = {dirStruct([dirStruct.isdir]).name}';
dirStructNew = dirStruct(~ismember(folderNames, {'.','..'}));
folderNames = folderNames(~ismember(folderNames, {'.','..'}));

end