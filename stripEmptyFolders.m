function [folderStruct, folderNames] = stripEmptyFolders(dirStruct)
% STRIPEMPTYFOLDERS     remove '.' and '..' folders from a 'dir' output
%
%   Syntax:
%       [FOLDERSTRUCT, FOLDERNAMES] = STRIPEMPTYFOLDERS(DIRSTRUCT)
% 
%   Description:
%       get the folder names and a cleaned up folder structure object for a 
%       directory call with 'dir', removing the empty holders '.' and '..'
%
%   Inputs:
%       dirStruct       structure output typically from a dir() command
% 
%   Outputs:
%       dirStructNew    dirStruct without '.' and '..' rows
%       folderNames     names of folders as cell array
%
%   Examples:
%
%   See also
%       dir, stripEmpties
% 
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
%
%	FirstVersion: 	unknown
%	Updated:        17 October 2022
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

folderStruct = dirStruct([dirStruct.isdir],:);
folderStruct = folderStruct(~ismember({folderStruct.name}, {'.','..'}));
folderNames = {folderStruct(:).name}';

end