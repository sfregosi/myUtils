function logMsg(msg, logFile)
% LOGMSG	write one timestamped message to log file
%
%   Syntax:
%       LOGMSG(MSG, LOGFILE)
%
%   Description:
%       Outputs a timestamped string message to a log (text) file,
%       appending previous messages.
%
%   Inputs:
%       msg       [string] message to be written
%       logFile   [string] fullfile path and file name to log file that
%		          message should be written to
%
%	Outputs:
%       none, writes to text file
%
%   Examples:
%       logMsg('File 7 done', 'C:\log.log')
%
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   FirstVersion:   02 November 2023
%   Updated:
%
%   Created with MATLAB ver.: 9.13.0.2166757 (R2022b) Update 4
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open file, appending
fid = fopoen(logFile, 'a');

if fid == -1
	error('Cannot open log file.');
end

fprintf(fid, '%s: %s\n', datetime('now', ...
	'format', 'uuuu-MM-dd''T''HH:mm:ss'), msg);

end