function newScript(scriptName)
%NEWSCRIPT create a script file using a template for documentation
%
%  Syntax:
%       NEWSCRIPT(SCRIPT)
%
%  Description:
%       NEWSCRIPT(SCRIPT) creates a script file from the template and opens
%       it in the editor. The new m-file is saved in the Current Folder
%
%   Inputs:
%       scriptName  name of new function, as char string
%
%   Outputs:
%       None. The function creates a new m-file and opens it in the editor.
%       The m-file is saved in the Current Folder
%
%  Examples:
%       newScript('myscript.m')
%
%  See also:
%       newFun
%
%  Authors:
%       S. Fregosi  <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   2024 December 10
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%
% CHECKS
% %%%%%%%%%%%%%%%%
error(nargchk(1, 1, nargin, 'struct'));

% check for an extension, and if there isn't one, add it.
[path, name, extension] = fileparts(scriptName);
if strcmp(extension, '.m')
    fullName = scriptName;
else
    fullName = fullfile(path, [name '.m']);
end

% %%%%%%%%%%%%%%%%
% PREP INFO
% %%%%%%%%%%%%%%%%
oneLinePrompt =     'One-line description here, please';
descriptionPrompt = 'Detailed description here, please';
username =          'S. Fregosi';
userEmail =         'selene.fregosi@gmail.com';
userGitHub =        'https://github.com/sfregosi';

% %%%%%%%%%%%%%%%%
% WRITE SCRIPT
% %%%%%%%%%%%%%%%%
% beginning of file-printing stage
fid = fopen(fullName,'wt');

fprintf(fid, '%% %s\n', upper(scriptName));
fprintf(fid, '%%\t%s\n', oneLinePrompt);
fprintf(fid, '%%\n');
fprintf(fid, '%%\tDescription:\n');
fprintf(fid, '%%\t\t%s\n',  descriptionPrompt);
fprintf(fid, '%%\n');
fprintf(fid, '%%\tNotes\n');
fprintf(fid, '%%\n');
fprintf(fid, '%%\tSee also\n');
fprintf(fid, '%%\n');
fprintf(fid, '%%\n');
fprintf(fid, '%%\tAuthors:\n');
fprintf(fid, '%%\t\t%s <%s> <%s>\n', username, userEmail, userGitHub);
% fprintf(fid, '%% Created with MATLAB ver.: %s on %s\n', version, osConfig);
fprintf(fid, '%%\n');
fprintf(fid, '%%\tUpdated:   %s\n', datestr(now,'yyyy mmmm dd'));
fprintf(fid, '%%\n');
fprintf(fid, '%%\tCreated with MATLAB ver.: %s\n', version);
fprintf(fid, '%% %s\n',repmat('%',1,72));
fclose(fid);
% end of file-printing stage

edit(fullName);

end


% % %%%%%%%%%%%%%%%%
% % NESTED FUNCTIONS
% % %%%%%%%%%%%%%%%%
% % user configuration info
% function val = ownConfig(opt)
% keyvals = {
%     'employer_name' 'ICTS SOCIB - Servei d''observacio i prediccio costaner de les Illes Balears.'
%     'employer_url'  'http://www.socib.es'
%     };
% val = keyvals{strcmp(opt, keyvals(:,1)), 2};
% end
% 
% function val = gitConfig(opt)
% [fail, val] = system(['git config ' opt]);
% val = strtrim(val);
% end
