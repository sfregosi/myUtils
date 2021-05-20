% downsample WHICEAS 2020 DASBR data for baleen whale analysis

% **use DECIMATE instead of RESAMPLE (decimate function is what triton's
% decimate feature uses)


clear all
% clc
warning('off')

drive = 'R:\';
cruise = 'WHICEAS_2020';

% % single dasbr
% dasbrNum = 'DS2';
% stNum = 'ST-2';
% serial = '1208766495'; %inner folder name and prefix of all wave filenames

% loop through all dasbrs
dasbrList = dir([drive cruise '_DASBR\Recordings\DS*']);

for d = 7:length(dasbrList)
    dasbrNum = dasbrList(d).name;
    fprintf(1, 'Starting %s\n', dasbrNum)
    stFolder = dir([drive cruise '_DASBR\Recordings\' dasbrNum '\ST*']);
    stNum = stFolder.name;
    srFolder = dir([drive cruise '_DASBR\Recordings\' dasbrNum '\' stFolder.name]);
    srFolder(~[srFolder.isdir])= []; %Remove all non directories.
    serial = setdiff({srFolder.name},{'.','..'});
    serial =  serial{:};  %inner folder name and prefix of all wave filenames
    % double check serial is a long number
    if ~isnumeric(str2double( serial))
        pause;
    elseif isnumeric(str2double(serial))
        fprintf(1, 'Serial is good...');
    end
    
    
    path_raw = [drive cruise '_DASBR\Recordings\' dasbrNum '\' stNum '\' ...
        serial '\'];
    % cd(path_raw);
    wavFiles = dir([path_raw '*.wav']);
    
    % check that og sample rate is 288 kHz
    info = audioinfo([path_raw wavFiles(1,1).name]);
    if info.SampleRate ~= 288000
        fprintf(1, '%s %s (d = %i) sample rate is %.0f Hz ...skipping\n', ...
            dasbrNum, stNum, d, info.SampleRate)
        continue
    elseif info.SampleRate == 288000
        fprintf(1,'sample rate is good\n');
    end
    
    
    % define new sample rates. **Make sure a evenly divide into full SR**
    fs0 = info.SampleRate;
    fs1 = fs0/288; % 1 kHz
    %     fs2 = fs0/60; % 4.8 kHz
    fs3 = fs0/30; % 9.6 kHz
    
    path_out1 = [drive cruise '_DASBR\Recordings\decimated\1kHz\' dasbrNum '_1kHz\'];
    mkdir(path_out1);
    %     path_out2 = [drive cruise '_DASBR\Recordings\decimated\4.8kHz\' dasbrNum '_4.8kHz\'];
    %     mkdir(path_out2);
    path_out3 = [drive cruise '_DASBR\Recordings\decimated\9.6kHz\' dasbrNum '_9.6kHz\'];
    mkdir(path_out3);
    
    for f = 1:length(wavFiles)
        try
            [data, fs] = audioread([path_raw wavFiles(f,1).name]);
            
            % data1 = resample(data, fs1, fs);
            data1 = decimate(data,fs0/fs1);
            % data2 = resample(data, fs2, fs);
            % data2 = decimate(data,fs0/fs2);
            % data3 = resample(data, fs2, fs);
            data3 = decimate(data,fs0/fs3);
            
            audiowrite([path_out1 wavFiles(f,1).name(1:end-4) '_1kHz.wav'], data1, fs1);
            % audiowrite([path_out2 wavFiles(f,1).name(1:end-4) '_4.8kHz.wav'], data2, fs2);
            audiowrite([path_out3 wavFiles(f,1).name(1:end-4) '_9.6kHz.wav'], data3, fs3);
            
            %             fprintf(1, '%s - file #%i: %s processed\n', datestr(now), f, wavFiles(f,1).name);
            
        catch
            fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), f, wavFiles(f,1).name);
        end
    end % wavFiles
    fprintf(1, '%s DONE\n', dasbrNum)
    
end % end dasbrs
