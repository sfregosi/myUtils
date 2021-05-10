% downsample HICEAS 2017 DASBR data for baleen whale analysis
% original sample rate


clear all
% clc
warning('off')

drive = 'Q:\';
cruise = 'HICEAS_2017';
% start with single DASBR at a time...could likely loop through all
% eventually
dasbrList = dir([drive cruise '_DASBR\Recordings\*ST*']);

for d = 8:10 %length(dasbrList)
    dasbrNum = dasbrList(d).name;
    fprintf(1, 'Starting %s\n', dasbrNum)
    sFolder = dir([drive cruise '_DASBR\Recordings\' dasbrNum '\1*']);
    serial =  sFolder.name;  %inner folder name and prefix of all wave filenames
    % double check serial is a long number
    if ~isnumeric(str2double(serial)) 
        pause; 
    elseif isnumeric(str2double(serial))
        fprintf(1, 'Serial is good...'); 
    end
        
    path_raw = [drive cruise '_DASBR\Recordings\' dasbrNum '\' serial '\'];
    % cd(path_raw);    
    wavFiles = dir([path_raw '*.wav']);
    
    % check that og sample rate is 288 kHz
    info = audioinfo([path_raw wavFiles(1,1).name]);
    if info.SampleRate ~= 288000
        pause;
    elseif info.SampleRate == 288000
        fprintf(1,'sample rate is good\n');
    end
    
    % define new sample rates. **Make sure a evenly divide into full SR**
    fs0 = info.SampleRate;
    fs1 = fs0/60; % 4.8 kHz
    fs2 = fs0/288; % 1 kHz
    
    path_out1 = [drive cruise '_DASBR\Recordings\decimated\' dasbrNum '_4.8kHz\'];
    mkdir(path_out1);
    path_out2 = [drive cruise '_DASBR\Recordings\decimated\' dasbrNum '_1kHz\'];
    mkdir(path_out2);
    
    for f = 1:length(wavFiles)
        try
            [data, fs] = audioread([path_raw wavFiles(f,1).name]);
            
            data1 = resample(data, fs1, fs);
            data2 = resample(data, fs2, fs);
            
            audiowrite([path_out1 wavFiles(f,1).name(1:end-4) '_4.8kHz.wav'], data1, fs1);
            audiowrite([path_out2 wavFiles(f,1).name(1:end-4) '_1kHz.wav'], data2, fs2);
            
            %         fprintf(1, '%s - file #%i: %s processed\n', datestr(now), f, wavFiles(f,1).name);
            
        catch
            fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', datestr(now), f, wavFiles(f,1).name);
        end
    end
    fprintf(1, '%s DONE\n', dasbrNum)
    
end
