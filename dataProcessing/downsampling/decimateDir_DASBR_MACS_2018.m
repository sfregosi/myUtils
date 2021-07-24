% downsample MACS 2018 DASBR data for baleen whale analysis

% **use DECIMATE instead of RESAMPLE (decimate function is what triton's
% decimate feature uses)


clear all
% clc
warning('off')

drive = 'Q:\';
cruise = 'MACS_2018';

% define new sample rates in Hz. **Make sure can evenly divide into full SR**
% decimation factor calculated below
% fs0 = info.SampleRate;
fsNew = [1000 9600]; % in Hz, can have multiple values e.g., [1000 5000]

% % single dasbr
% dasbrNum = 'DS2';
% stNum = 'ST-2';
% serial = '1208766495'; %inner folder name and prefix of all wave filenames

% loop through all dasbrs
dasbrList = dir([drive cruise '_DASBR\Recordings\DS*']);

for d = 1:length(dasbrList)
    dasbrNum = dasbrList(d).name;
    fprintf(1, 'Starting %s\n', dasbrNum)
    stFolder = dir([drive cruise '_DASBR\Recordings\' dasbrNum '\ST*']);
    stNum = stFolder.name;
    srFolder = dir([drive cruise '_DASBR\Recordings\' dasbrNum '\' stFolder.name]);
    srFolder(~[srFolder.isdir])= []; %Remove all non directories.
    serial = setdiff({srFolder.name},{'.','..'});
    serial =  serial{:};  %inner folder name and prefix of all wave filenames
    % double check serial folder is a long number
    if ~isnumeric(str2double( serial))
        pause;
    elseif isnumeric(str2double(serial))
        fprintf(1, 'Serial is good...');
    end
    
    path_raw = [drive cruise '_DASBR\Recordings\' dasbrNum '\' stNum '\' ...
        serial '\'];
    % cd(path_raw);
    wavFiles = dir([path_raw '*.wav']);
    
    if isempty(wavFiles)% check that there are actually wav files
        fprintf(1, '%s: no wav files\n', dasbrNum);
        continue
    elseif ~isempty(wavFiles)
        info = audioinfo([path_raw wavFiles(1,1).name]);
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
                path_outN = [drive cruise '_DASBR\Recordings\decimated\' ...
                    fsNewStr{f} '\' dasbrNum '_' fsNewStr{f} '\'];
                mkdir(path_outN);
                path_out{f} = path_outN;
            else
                fprintf(1, 'invalid decimation factor: %s %s (d = %i) fs = %.0f Hz ...skipping\n', ...
                    dasbrNum, stNum, d, info.SampleRate)
                continue
            end
        end % fsNew
        
        for wf = 1:length(wavFiles)
            try
                [data, fs] = audioread([path_raw wavFiles(wf,1).name]);
                
                for g = 1:length(df)
                    dataNew = decimate(data, df(g));
                    %                     dataNew = resample(data, fsNew(g), fs);
                    audiowrite([path_out{g} wavFiles(wf,1).name(1:end-4) ...
                        '_' fsNewStr{g} '.wav'], dataNew, fsNew(g));
                end
                %             fprintf(1, '%s - file #%i: %s processed\n', datestr(now), f, wavFiles(f,1).name);
                
            catch
                fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), f, wavFiles(f,1).name);
            end
        end %loop through wavFiles
    end % wavFileq check
    fprintf(1, '%s DONE\n', dasbrNum)
end % end dasbrs
