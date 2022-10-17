function decimateDir(folder, fsNew)
% DECIMATEDIR	downsample directory of wav files using DECIMATE
%
%	Syntax:
%		DECIMATEDIR(FOLDER, FSNEW)
%
%	Description:
%		Decimate a directory of wav files to a defined new sampling rate,
%		fsNew, or multiple new sample rates, and write new files in nested
%		subdirectory
%
%       This was originally a script that was modified for each deployment,
%       but this function aims to simplify that script. See
%       myUtils/dataProcessing/downsampling for example scripts to deal
%       with more complicated folder strutures.
%       Requires myUtils/stripEmptyFolders.m
%
%	Inputs:
%		folder 	path to wav files to be decimated. Can contain subfolders
%       fsNew   new sample rate or vector of multiple new sample rates
%       (e.g., [1000 9600]) in Hz. Original sample rate must be divisible
%       by new sample rates by an integer.
%
%	Outputs:
%		creates a folder where newly written .wavs are stored
%
%	Examples:
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
%
%	FirstVersion: 	17 October 2022
%	Updated:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    fsNew = input('Specify new sample rate:');
end

if nargin < 1
    folder = uigetdir('C:\', 'Select folder containing subfolders of wav files');
end

fileList = dir(folder);
dirFlags = [fileList.isdir];
[fldrList, fldrNames] = stripEmptyFolders(fldrList);

% check for an existing 'decimated' folder and ignore it
if any(strcmp(fldrNames, 'decimated'))
    decIdx = find(strcmp(fldrNames, 'decimated'));
    fldrNames(decIdx) = [];
    fldrList(decIdx) = [];
end
    
% loop through all folders to do decimation work
for d = 1:length(fldrNames)
    fprintf(1, 'Starting %s\n', fldrNames{d});
    
    path_raw = fullfile(fldrList(d).folder, fldrNames{d});
    wavFiles = dir(fullfile(path_raw, '*.wav'));
    
    % check for wav files
    if isempty(wavFiles) 
        fprintf(1, '%s: no wav files\n', fldrNames{d});
        continue
        
        % if file present...
    elseif ~isempty(wavFiles)
        % set up decimation factors/output folder structure
        info = audioinfo(fullfile(path_raw, wavFiles(1,1).name));
        fprintf(1, 'sample rate: %0.f Hz\n', info.SampleRate)
        df = zeros(length(fsNew),1); % decimation factor(s)
        path_out = cell(length(fsNew),1);
        fsNewStr = cell(length(fsNew),1);
        for f = 1:length(fsNew)
            fsN = fsNew(f);
            % calc decimation factor and check that its an integer
            dfN = info.SampleRate/fsN;
            if rem(dfN,1) == 0
                fprintf(1,'decimation factor (%0.f) is good\n', dfN);
                df(f) = dfN;
                fsNewStr{f} = [num2str(fsN/1000) 'kHz'];% new sample rate in string as kHz (for file names)
                path_outN = fullfile(folder, 'decimated', fsNewStr{f}, ...
                    [fldrNames{d} '_' fsNewStr{f}]);
                mkdir(path_outN);
                path_out{f} = path_outN;
            else
                fprintf(1, 'invalid decimation factor: %s (d = %i) fs = %.0f Hz ...skipping\n', ...
                    fldrNames{f}, d, info.SampleRate)
                continue
            end
        end % fsNew

        % decimate and write new files
        for wf = 1:length(wavFiles)
            try
                [~, wfName, ext] = fileparts(fullfile(path_raw, wavFiles(wf,1).name));
                [data, fs] = audioread(fullfile(path_raw, wavFiles(wf,1).name));
                
                for g = 1:length(df)
                    dataNew = decimate(data, df(g));
                    audiowrite(fullfile(path_out{g}, [wfName '_' fsNewStr{g} ext]), ...
                        dataNew, fsNew(g));
                end
            clear data dataNew    
            catch
                fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), f, wavFiles(f,1).name);
            end
            
        end %loop through wavFiles
    end % wavFile check
    fprintf(1, '%s DONE\n', fldrNames{d})
end % loop through fldr list

end
