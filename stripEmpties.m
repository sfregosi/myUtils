function [dirStructNew, names] = stripEmpties(dirStruct)

% get the folder/file names for a directory with '.' and '..' removed
%
%
% INPUT:    dirStruct       structure output typically from a dir() command
% 
% OUTPUT:   dirStructNew    dirStruct without '.' and '..' rows
%           names           names of folders/files as cell array

names = {dirStruct.name}';
dirStructNew = dirStruct(~ismember(names, {'.','..'}));
names = names(~ismember(names, {'.','..'}));

end