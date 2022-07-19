% rename files

% original files
path_in = 'D:\sg680_MHI_Apr22\wav';
wavFiles = dir(fullfile(path_in, '*.wav') );
oldNames = {wavFiles.name};
newNames = regexprep(oldNames, '_HI', '_MHI');

for f = 1 : length(oldNames)
    movefile(fullfile(path_in, oldNames{f}), fullfile(path_in, newNames{f}));
end