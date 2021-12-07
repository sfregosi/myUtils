%Convert file names for LTSA in Triton


% path_data = 'S:\MACS_2021_DASBR\decimated\1kHz\';
% path_data = 'R:\WHICEAS_2020_DASBR\Recordings\decimated\1kHz\';
% path_data = 'Q:\HICEAS_2017_DASBR\Recordings\decimated\1kHz\';
path_data = 'Q:\MACS_2018_DASBR\Recordings\decimated\1kHz\';

folders = dir(path_data);
for g = 3:length(folders)
    
    folderName = folders(g).name;
    path_out = [path_data folderName '\'];
    % mkdir(path_out);
    
    files = dir([path_data folderName '\*_1kHz.wav']);
    for f = 1:length(files)
        % old name
        [pathname, filename, extension] = fileparts(files(f).name);
        % new name
        newName = ['1kHz_' filename(1:end-5)];
        % rename
        movefile([path_data folderName '\' filename extension], ...
            [path_out newName extension]);
    end
end
