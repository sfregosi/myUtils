% workflow processing longline acoustic monitoring trip

% (4) Clean up XWAVs
%       - to split raw files with gaps across sets or other misc gaps
%       - use findXwavGaps to auto identify number of gaps (should match
%       number identified manually
%       - separate any raw files with gaps between using writeSplitXwavs
%       - this loops through each frame deployed in a trip


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% (4) Clean up XWAVs
% Check XWAV Timing, Process Gaps, and Summarize

% loop through whichever frames were set to be processed (all or single frame?)
if strcmp(frToProcess, 'all')
	loopVals = 1:numFrames;
elseif isnumeric(frToProcess)
	loopVals = frToProcess;
end

% check that is proper cell, and if not, fix
if ~iscell(recNames{:})
	recNames{:} = {recNames{:}};
end

% loop through all frames
for fr = loopVals % 1 %:numFrames
	frStr = recNames{:}{fr}(1:4);
	fprintf(1, 'Splitting xwavs for %s %s\n', trip, frStr);

	if tripNum >= 60 % these file folders should be
		fprintf(1, 'STANDARDIZED FOLDER PATHS...no need to select folder\n')
		path_xwavs = fullfile(path_data, recNames{:}{fr}, 'xwavs');
		if exist(path_xwavs, 'dir') ~= 7
			% if it doesn't work, manually select
			fprintf(1, 'Expected folder does not exist. Manually select...\n');
			pause
			path_xwavs = uigetdir(path_data, ...
				sprintf('Select folder containing xwavs for frame %s', frStr));
		end
	else
		% there CAN BE MULTIPLE FOLDERS of data for a single frame...how do
		% I deal with that??
		% manually select folder.
		path_xwavs = uigetdir(path_data, ...
			sprintf('Select folder containing xwavs for frame %s', frStr));
	end

	%     load(fullfile(path_analysis, 'deploymentSummaries\', [trip '_summary.mat']));
	%     load([path_analysis 'deploymentSummaries\' trip '_summary.mat']);

	% Identify gap in raw files within xwavs
	if numFrames > 1
		gapSummFileName = ['fileGapsSummary_' frStr '.mat'];
	elseif numFrames == 1
		gapSummFileName = 'fileGapsSummary.mat';
	end
	if ~isfile(fullfile(path_data, gapSummFileName)) % check exists to not overwrite
		gapSummary = findXwavGaps(path_xwavs);
		save(fullfile(path_data, gapSummFileName), 'gapSummary'); % save in data folder
	else
		load(fullfile(path_data, gapSummFileName));
	end

	fprintf(1, ['check number of gaps (n=%i) and files (n=%i) against ' ...
		'recorder times summary table. ENTER to continue\n'], ...
		sum(gapSummary.numGaps), height(gapSummary));
	pause;

	% write new xwavs (if not already done!)
	xwavFolderIdx = regexp(path_xwavs, 'xwavs', 'IgnoreCase');
	path_original = fullfile(path_xwavs(1:xwavFolderIdx-1), 'xwavs_original');
	if ~isfolder(path_original)
		% make a copy/backup of original files that will be split
		mkdir(path_original);
		fprintf(1, 'Copying %i original files to ''xwavs_original''...\n', height(gapSummary));
		for of = 1:height(gapSummary)
			copyfile(fullfile(gapSummary.folder{of}, gapSummary.fileName{of}), ...
				fullfile(path_original, gapSummary.fileName{of}));
		end
		% then split the files
		writeSplitXwavs(gapSummary, path_xwavs, path_original)
	else
		fprintf('%s already split.\n', trip);
	end

end % loop through all frames

% ***MOVE deck test files NOW...if they exist***

