%Convert file names for LTSA in Triton


path_data = 'S:\MACS_2021_DASBR\decimated\9.6kHz\DS14_9.6kHz\';
path_out = 'S:\MACS_2021_DASBR\decimated\9.6kHz\DS14_9.6kHz\';
% mkdir(path_out);

files = dir([path_data '*.wav']);
for f = 1:length(files)
    % old name
    [pathname, filename, extension] = fileparts(files(f).name);
    % new name
    newName = ['9-6kHz_' filename(1:end-7)];
    % rename
    movefile([path_data filename extension], [path_out newName extension]);
end
