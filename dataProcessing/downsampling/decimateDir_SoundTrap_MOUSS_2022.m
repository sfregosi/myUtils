% downsample MOUSS 2022 SoundTrap data for fish and camera sound analysis

% **use DECIMATE instead of RESAMPLE (decimate function is what triton's
% decimate feature uses)


clear all
% clc
warning('off')

drive = 'S:\';
cruise = 'MOUSS_2022';

% define new sample rates in Hz. **Make sure can evenly divide into full SR**
% decimation factor calculated below
% fs0 = info.SampleRate;
fsNew = [1000 9600]; % in Hz, can have multiple values e.g., [1000 5000]

% loop through all deployments
deplList = dir(fullfile(drive, cruise, '5413*'));

for d = 1:length(deplList)
    deplNum = deplList(d).name;
    fprintf(1, 'Starting %s\n', deplNum)
    
    path_raw = fullfile(drive, cruise, deplNum);
    % cd(path_raw);
    wavFiles = dir(fullfile(path_raw, '*.wav'));
    
    if isempty(wavFiles)% check that there are actually wav files
        fprintf(1, '%s: no wav files\n', deplNum);
        continue
    elseif ~isempty(wavFiles)
        % set up decimation factors and output folder structure
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
                path_outN = fullfile(drive, cruise, 'decimated', fsNewStr{f}, ...
                    [deplNum '_' fsNewStr{f}]);
                mkdir(path_outN);
                path_out{f} = path_outN;
            else
                fprintf(1, 'invalid decimation factor: %s %s (d = %i) fs = %.0f Hz ...skipping\n', ...
                    deplNum, stNum, d, info.SampleRate)
                continue
            end
        end % fsNew
        
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
    fprintf(1, '%s DONE\n', deplNum)
end % end dasbrs
