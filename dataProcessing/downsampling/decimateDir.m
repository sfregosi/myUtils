function decimateDir(fsNew, ext, folder)
% DECIMATEDIR	downsample directory of audio files using DECIMATE
%
%	Syntax:
%		DECIMATEDIR(FSNEW, EXT, FOLDER)
%
%	Description:
%		Decimate a directory of audio files to a defined new sampling rate,
%		fsNew, or multiple new sample rates, and write new files in new
%		subdirectory.
%
%       This was designed to work on a folder of subfolders of instruments,
%       e.g., DASBRs following the folder structure on the PIFSC server.
%       This has an outer folder within which there is a subfolder for each
%       recorder/deployment
%
%       Because of variability in folder structures, this really only works
%       with a basic folder/subfolder arrangement where there is a folder
%       such as 'recordings' that contains a subfolder for 'wav' and then
%       the decimated recordings will be saved in a newly created
%       'decimated' subfolder with each new sample rate in the name
%
%       This was originally a script that was modified for each deployment,
%       but this function aims to simplify that script. However, this
%       function can only run on a single folder of sound files. See
%       myUtils/dataProcessing/downsampling for example scripts to deal
%       with more complicated folder strutures and to loop through multiple
%       directories of sound files in one script
%
%	Inputs:
%       fsNew   [double] or [vector] new sample rate or vector of multiple
%               new sample rates (e.g., [1000 9600]) in Hz. Original sample
%               rate must be divisible by new sample rates by an integer
%       ext     [string] input file extension, either '.wav', or '.flac'
%       folder 	path to audio files to be decimated
%
%	Outputs:
%		creates a folder where newly written audio files are stored
%
%	Examples:
%       decimate([10 9600], '.wav', 'G:/glider/wav');
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:        31 March 2025
%
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    folder = uigetdir('C:\', 'Select folder containing audio files');
end

if nargin < 2
    ext = input('Specify file extension [''.wav'' or ''.flac'']');
end

if nargin < 1
    fsNew = input('Specify new sample rate:');
end


% fileList = dir(folder);
% % skip any subfolders or ., ..
% dirFlags = [fileList.isdir];
% fileList = fileList(~dirFlags,:);

% do the decimation!
fprintf(1, 'Decimating %s\n', folder);
fprintf(1, '   Start time: %s\n',datetime('now'));


audioFiles = dir(fullfile(folder, ['*', ext]));

% check for wav files
if isempty(audioFiles)
    fprintf(1, '%s: no audio files. Exiting...\n', folder);
    return

    % if files present...
elseif ~isempty(audioFiles)
    % set up decimation factors/output folder structure
    info = audioinfo(fullfile(folder, audioFiles(1,1).name));
    fprintf(1, 'Original sample rate: %0.f Hz\n', info.SampleRate)
    df = zeros(length(fsNew), 1); % decimation factor(s)
    path_out = cell(length(fsNew), 1);
    fsNewStr = cell(length(fsNew), 1);
    for f = 1:length(fsNew)
        fsN = fsNew(f);
        % calc decimation factor and check that its an integer
        dfN = info.SampleRate/fsN;
        if rem(dfN,1) == 0
            fprintf(1,'  decimation factor (%0.f) to %i Hz is good\n', dfN, fsN);
            df(f) = dfN;
            % make string for new file names - as Hz or kHz
            if fsN/1000 < 1
                fsNewStr{f} = [num2str(fsN) 'Hz']; % as Hz
            else
                fsNewStr{f} = [num2str(fsN/1000) 'kHz'];
            end

            pathParts = regexp(folder, filesep, 'split');
            path_outN = fullfile(pathParts{1:end-1}, ...
                [pathParts{end} '_decimated_' fsNewStr{f}]);
            mkdir(path_outN);
            path_out{f} = path_outN;
        else
            fprintf(1, ['invalid decimation factor: \n', ...
                '%s\n fs = %.0f Hz but fsNew = %.0f Hz ...skipping\n'], ...
                folder, info.SampleRate, fsN)
            continue
        end
    end % fsNew

    % decimate and write new files
    for wf = 1:length(audioFiles)
        try
            [~, wfName, ext] = fileparts(fullfile(audioFiles(wf).folder, ...
                audioFiles(wf).name));
            [data, fs] = audioread(fullfile(audioFiles(wf).folder, ...
                audioFiles(wf).name), 'native');

            for g = 1:length(df)
                dataNew = decimate(double(data), df(g));
                % write data type based on output bits
                if info.BitsPerSample == 16
                    audiowrite(fullfile(path_out{g}, [wfName '_' fsNewStr{g} ext]), ...
                        int16(dataNew), fsNew(g), 'BitsPerSample', info.BitsPerSample);
                elseif info.BitsPerSample == 24 || info.BitsPerSample == 32
                    audiowrite(fullfile(path_out{g}, [wfName '_' fsNewStr{g} ext]), ...
                        int32(dataNew), fsNew(g), 'BitsPerSample', info.BitsPerSample);
                else
                    fprintf(1, 'Error: bit size %i not supported.', info.BitsPerSample)
                    return
                end

                % old audiowrite - have to be careful with how data are
                % read in ('native') and saved (double vs int16/int32)
                % audiowrite(fullfile(path_out{g}, [wfName '_' fsNewStr{g} ext]), ...
                %     dataNew, fsNew(g), 'BitsPerSample', info.BitsPerSample);
            end
            clear data dataNew
        catch
            fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', ...
                datetime('now'), f, audioFiles(f,1).name);
        end

    end %loop through audioFiles
end % audioFile check
fprintf(1, '%s DONE. End time: %s\n', folder, datetime('now'))

end
