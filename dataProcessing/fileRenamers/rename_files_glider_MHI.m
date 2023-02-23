% rename files

% original files
path_in = 'D:\sg639_MHI_Apr2022\recordings\wav';
% path_in = 'T:\Glider_MHI_Spring_2022\sg680_MHI_Apr2022\recordings\wav\';
wavFiles = dir(fullfile(path_in, '*.wav') );
oldNames = {wavFiles.name};
newNames = regexprep(oldNames, '_HI', '_MHI');
newNames = regexprep(newNames, 'Apr22', 'Apr2022');

for f = 1 : length(oldNames)
    movefile(fullfile(path_in, oldNames{f}), fullfile(path_in, newNames{f}));
end