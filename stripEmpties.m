function [dirStructNew, names] = stripEmpties(dirStruct)
% STRIPEMPTIES     remove '.' and '..' files from a 'dir' output
%
%   Syntax:
%       [DIRSTRUCTNEW, NAMES] = STRIPEMPTIES(DIRSTRUCT)
% 
%   Description:
%       get the file names and a cleaned up structure object for a 
%       directory call with 'dir', removing any empty files '.' and '..'
%
%   Inputs:
%       dirStruct       structure output typically from a dir() command
% 
%   Outputs:
%       dirStructNew    dirStruct without '.' and '..' rows
%       names           names of folders/files as cell array
%
%   Examples:
%
%   See also
%       dir, stripEmptyFolders
% 
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
%
%	FirstVersion: 	unknown
%	Updated:        13 February 2023
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

names = {dirStruct.name}';
dirStructNew = dirStruct(~ismember(names, {'.','..'}));
names = names(~ismember(names, {'.','..'}));

end