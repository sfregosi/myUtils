function decimateDir(fsNew, folder)
% DECIMATEDIR	downsample directory of wav files using DECIMATE
%
%	Syntax:
%		DECIMATEDIR(FSNEW, FOLDER)
%
%	Description:
%		Decimate a directory of wav files to a defined new sampling rate,
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
%       folder 	path to wav files to be decimated. Can contain subfolders
%
%	Outputs:
%		creates a folder where newly written WAVs are stored
%
%	Examples:
%       decimate([10 9600], 'G:/glider/wav');
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
%
%	FirstVersion: 	17 October 2022
%	Updated:        01 August 2024
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
	folder = uigetdir('C:\', 'Select folder containing wav files');
end

if nargin < 1
	fsNew = input('Specify new sample rate:');
end


% fileList = dir(folder);
% % skip any subfolders or ., ..
% dirFlags = [fileList.isdir];
% fileList = fileList(~dirFlags,:);

% do the decimation!
fprintf(1, 'Starting %s\n', folder);

wavFiles = dir(fullfile(folder, '*.wav'));

% check for wav files
if isempty(wavFiles)
	fprintf(1, '%s: no wav files. Exiting...\n', folder);
	return

	% if files present...
elseif ~isempty(wavFiles)
	% set up decimation factors/output folder structure
	info = audioinfo(fullfile(folder, wavFiles(1,1).name));
	fprintf(1, 'sample rate: %0.f Hz\n', info.SampleRate)
	df = zeros(length(fsNew), 1); % decimation factor(s)
	path_out = cell(length(fsNew), 1);
	fsNewStr = cell(length(fsNew), 1);
	for f = 1:length(fsNew)
		fsN = fsNew(f);
		% calc decimation factor and check that its an integer
		dfN = info.SampleRate/fsN;
		if rem(dfN,1) == 0
			fprintf(1,'decimation factor (%0.f) is good\n', dfN);
			df(f) = dfN;
			fsNewStr{f} = [num2str(fsN/1000) 'kHz']; % new sample rate in string as kHz (for file names)
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
	for wf = 1:length(wavFiles)
		try
			[~, wfName, ext] = fileparts(fullfile(wavFiles(wf).folder, ...
				wavFiles(wf).name));
			[data, fs] = audioread(fullfile(wavFiles(wf).folder, ...
				wavFiles(wf).name));

			for g = 1:length(df)
				dataNew = decimate(data, df(g));
				audiowrite(fullfile(path_out{g}, [wfName '_' fsNewStr{g} ext]), ...
					dataNew, fsNew(g));
			end
			clear data dataNew
		catch
			fprintf(1, 'ATTENTION: %s - file #%i: %s corrupt\n', ...
				datetime('now'), f, wavFiles(f,1).name);
		end

	end %loop through wavFiles
end % wavFile check
fprintf(1, '%s DONE\n', folder)

end
