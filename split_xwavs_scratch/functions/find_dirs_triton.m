function dirs = find_dirs_triton(d, ftype)
% originally found in Triton code. Extracted and added to myUtils 
% S. Fregosi 2021 08 11

cd(d);
dirs = {};

% find each of the subdirectories
files = dir;
inds = find(vertcat(files.isdir));
subdirs = {};
subdirs_xwav = {};
for k = 1:length(inds)
    ind = inds(k);
    if ~strcmp(files(ind).name, '.') && ~strcmp(files(ind).name, '..')
        subdirs{end+1} = fullfile(d, files(ind).name);
    end
end

% for each subdirectory, check for xwavs and append to list of indirs
for k = 1:size(subdirs, 2)
    subdirs_xwav = find_dirs_triton(subdirs{k}, ftype);
    dirs = cat_cell(dirs, subdirs_xwav);
end
cd(d);
if ~isempty(dir(ftype))
    dirs{end+1} = d;
end

end
