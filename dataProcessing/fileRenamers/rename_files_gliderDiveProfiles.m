%Rename Glider profile data files for submission to GRIIDC
% 2018 06 25
% for LADCGEMM project 

%% profile files
path_in = 'T:\GulfOfMexico\2017\forDataSubmission\profiles\';
cd(path_in)
fileList = dir([path_in '*.nc']);
for i = 1:length(fileList)
    orig = fileList(i).name;
    new = ['sg607_20170609T182847Z_p' fileList(i).name(5:8) '_delayed.nc'];
  if (~strcmp(orig, new)), movefile(orig, new); end
end 

%% acoustic files
% % VERY SLOW
% path_in = 'T:\GulfOfMexico\2017\forDataSubmission\acoustics_netCDF\';
% cd(path_in)
% fileList = dir([path_in '*.nc']);
% for i = 1:length(fileList)
%     orig = fileList(i).name;
%     new = [fileList(i).name(1:end-6) '.nc'];
%   if length(orig) ~= 25; movefile(orig, new); end
%   disp(i)
% end 

% faster
path_in = 'T:\GulfOfMexico\2017\forDataSubmission\acoustics_netCDF\';
orig_path = 'T:\GulfOfMexico\2017\Acoustics\WAV\';
origFileList = dir([orig_path '*.wav']);
cd(path_in)
fileList = dir([path_in '*.nc']);
for i = 1:length(fileList)
    orig = fileList(i).name;
    new = ['sg' fileList(i).name(3:19) origFileList(i).name(12:13) '_delayed.nc'];
    [Status, Msg] = FileRename(orig, new);
 if Status ~= 1; disp('error'); end
end 

