function newFun(fxnName, inputs, outputs)
%NEWFUN creates a function m-file with proper help info from template
%
%   Syntax:
%       newFun(fxnName)
%       newFun(fxnName, inputs, outputs)
%
%   Description:
%       newFun(fxnName) creates a function file according to the template
%       and opens it in the Editor. The new m-file is saved in the Current
%       Folder 
%
%       newFun(fxnName, inputs, outputs) creates a function file with the
%       specified inputs and outputs pre-populated
% 
%   Inputs:
%       fxnName name of new function, as char string
%       inputs  optional argument, input variable names either as char 
%               string for single input, or cell array for multiple inputs
%               e.g., {'in1', 'in2'} or 'in'
%       outputs optional argument, output variable names either as char 
%               string for single output, or cell array for multiple outputs
%               e.g., {'out1', 'out2'} or 'out'
%
%   Outputs:
%       None. The function creates a new m-file and opens it in the editor.
%       The m-file is saved in the Current Folder
%
%   Examples:
%       newFun myfun
%       newFun myfun 'input1, input2' 'output1, output2'
%
%   See also
%
%   Authors:
%       S. Fregosi  <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   First version:   18 July 2022
%   Updated:         19 July 2022
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%
% CHECKS
% %%%%%%%%%%%%%%%%
narginchk(1, 3);

if nargin < 2
    inputs = 'input';
end
if nargin < 3
    outputs = 'output';
end

% check inputs/outputs valid formats
inSz = checkArgs(inputs);
outSz = checkArgs(outputs);

% check whether function already exists - only if given as input
if ~isempty(fxnName)
    fxnCheck = which(fxnName);
    if ~isempty(fxnCheck)
        error('%s already exists: %s Choose a different function name', ...
            fxnName, fxnCheck)
    end
end

% %%%%%%%%%%%%%%%%
% PREP INFO
% %%%%%%%%%%%%%%%%
% create the properly formatted call
call =              formatCall(fxnName, inputs, outputs);
oneLinePrompt =     'One-line description here, please';
descriptionPrompt = 'Detailed description here, please';
username =          'S. Fregosi';
userEmail =         'selene.fregosi@gmail.com';
userGitHub =        'https://github.com/sfregosi';

% %%%%%%%%%%%%%%%%
% WRITE FUNCTION
% %%%%%%%%%%%%%%%%
% create the filename based on the function name
[path, name, extension] = fileparts(fxnName);
if isempty(extension)
    fileName = fullfile(path, [name '.m']);
else
    fileName = fxnName;
end

% beginning of file-printing stage
fid = fopen(fileName,'wt');

fprintf(fid, 'function %s\n', call);
fprintf(fid, '%% %s\t%s\n', upper(fxnName), oneLinePrompt);
fprintf(fid, '%%\n');
fprintf(fid, '%%\tSyntax:\n');
fprintf(fid, '%%\t\t%s\n', upper(call));
fprintf(fid, '%%\n');
fprintf(fid, '%%\tDescription:\n');
fprintf(fid, '%%\t\t%s\n',  descriptionPrompt);
fprintf(fid, '%%\tInputs:\n');
if inSz > 1
    for f = 1:length(inputs)
        fprintf(fid, '%%\t\t%s \t%s\n', inputs{f}, 'describe, please');
    end
elseif inSz == 1
    fprintf(fid, '%%\t\t%s \t%s\n', inputs, 'describe, please');
end
fprintf(fid,'%%\n');
fprintf(fid, '%%\tOutputs:\n');
if outSz > 1
    for f = 1:length(inputs)
        fprintf(fid, '%%\t\t%s \t%s\n', outputs{f}, 'describe, please');
    end
elseif outSz == 1
    fprintf(fid, '%%\t\t%s \t%s\n', outputs, 'describe, please');
end
fprintf(fid, '%%\n');
fprintf(fid, '%%\tExamples:\n');
fprintf(fid, '%%\n');
fprintf(fid, '%%\tSee also\n');
fprintf(fid, '%%\n');
fprintf(fid, '%%\n');
fprintf(fid, '%%\tAuthors:\n');
fprintf(fid, '%%\t\t%s <%s> <%s>\n', username, userEmail, userGitHub);
% fprintf(fid, '%% Created with MATLAB ver.: %s on %s\n', version, osConfig);
fprintf(fid, '%%\tCreated with MATLAB ver.: %s\n', version);
fprintf(fid, '%%\n');
fprintf(fid, '%%\tFirstVersion: \t%s\n', datestr(now,'dd mmmm yyyy'));
fprintf(fid, '%%\tUpdated:\n');
fprintf(fid, '%% %s\n',repmat('%',1,72));
fclose(fid);
% end of file-printing stage

edit(fileName);

end

% %%%%%%%%%%%%%%%%
% NESTED FUNCTIONS
% %%%%%%%%%%%%%%%%
% user configuration info
function val = ownConfig(opt)
keyvals = {
    'user_name'   'S. Fregosi'
    'user_email'  'selene.fregosi@gmail.com'
    'github_url'  'https://github.com/sfregosi'
    };
val = keyvals{strcmp(opt, keyvals(:,1)), 2};
end

% operating system configuration
function os = osConfig
% getenv('OS') does not work on Mac. Query the OS like ver.m
% find platform OS
if ispc
    platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
elseif ismac
    [fail, input] = unix('sw_vers');
    if ~fail
        platform = strrep(input, 'ProductName:', '');
        platform = strrep(platform, sprintf('\t'), '');
        platform = strrep(platform, sprintf('\n'), ' ');
        platform = strrep(platform, 'ProductVersion:', ' Version: ');
        platform = strrep(platform, 'BuildVersion:', 'Build: ');
    else
        platform = system_dependent('getos');
    end
else
    platform = system_dependent('getos');
end
os = platform;
end

% check inputs/outputs format and size
function sz = checkArgs(arguments)
if iscell(arguments)
    sz = length(arguments);
elseif ischar(arguments) && size(arguments, 1) == 1
    sz = 1;
else
    fprintf(1, 'incorrect input/output format\n')
    return
end
end

% clean up arguments
function pretty_arguments = formatArguments(arguments)
sz = checkArgs(arguments);
if sz > 1
    strArgs = string(arguments);
    fmt = ['%s' repmat(', %s', 1, sz-1)];
    pretty_arguments = sprintf(fmt, strArgs);
elseif ischar(arguments) && size(arguments, 1) == 1
    pretty_arguments = arguments;
end
end

function pretty_call = formatCall(name, inputs, outputs)
pretty_inputs = formatArguments(inputs);
pretty_outputs = formatArguments(outputs);
if isempty(pretty_outputs)
    pretty_call = [name '(' pretty_inputs ')'];
elseif ismember(',', pretty_outputs)
    pretty_call = [ '[' pretty_outputs '] = ' name '(' pretty_inputs ')'];
else
    pretty_call = [ pretty_outputs ' = ' name '(' pretty_inputs ')'];
end
end