% workflow to split duty-cycled xwavs
%

%WORKFLOW_SPLITXWAVS.M
%	Workflow to split duty-cycled XWAVs into individual files
%
%	Description:
%        Script to split XWAV data recorded with a duty cycle into
%        individual XWAVs with new filenames based on the timestamp of each
%        raw file, accounting for the duty cycle gaps between the raw
%        files. The correct start time of each raw file is stored in the
%        XWAV header, but that header is not accessible by PAMGuard or
%        other acoustic analysis programs, which rely on timestamps in the
%        filenames to correctly parse the file start time.
%
%        The script identifies gaps between the raw files, prompts the user
%        to confirm these gaps are correct, then reads in each XWAV, splits
%        it into the required number of segments, and writes each of those
%        segments to new XWAV files named with the correct start time info
%        from the XWAV header.
%
%	Notes
%        Unfortunately, this is a data-storage-heavy process; this will
%        produce a copy of the XWAV data so sufficient storage space equal
%        to the input data is required in the output directory.
%
%	See also
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:   5 May 2025
%
%	Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% (4) Clean up XWAVs
%       - to split raw files with gaps across sets or other misc gaps
%       - use findXwavGaps to auto identify number of gaps (should match
%       number identified manually
%       - separate any raw files with gaps between using writeSplitXwavs
%       - this loops through each frame deployed in a trip


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User specified inputs

% add code to path
path_code = ('C:\Users\selene.fregosi\Documents\MATLAB\myUtils');
addpath(genpath(path_code));

% set input directory
path_in = ('C:\Users\selene.fregosi\Desktop\split_xwav_test\in');

% set output directory
path_split = ('C:\Users\selene.fregosi\Desktop\split_xwav_test\split');

%%
% %% (4) Clean up XWAVs
% % Check XWAV Timing, Process Gaps, and Summarize
%
% % loop through whichever frames were set to be processed (all or single frame?)
% if strcmp(frToProcess, 'all')
% 	loopVals = 1:numFrames;
% elseif isnumeric(frToProcess)
% 	loopVals = frToProcess;
% end
%
% % check that is proper cell, and if not, fix
% if ~iscell(recNames{:})
% 	recNames{:} = {recNames{:}};
% end

%% Find all directories to process

% % find all directories/subdirectories with xwavs
% xwavDirs = find_dirs_triton(path_in, '*.x.wav');
%
% % loop through each directory to process
% for xd = 1:length(xwavDirs)
%     path_xwavs = xwavDirs(xd);
% 	fprintf(1, 'Splitting xwavs for %s\n', path_xwavs);
% end

% alternatively just prompt to select path to process
path_xwavs = uigetdir(path_in, 'Select folder containing xwavs');

% Identify gap in raw files within xwavs
gsFileName = 'fileGapsSummary.mat';
if ~isfile(fullfile(path_data, gsFileName)) % check exists to not overwrite
    gapSummary = findXwavGaps(path_xwavs);
    save(fullfile(path_out, gsFileName), 'gapSummary'); % save in out folder
else
    fprintf('gapSummary already exists. Exiting.\n')
end

fprintf(1, ['check number of gaps (n=%i) and files (n=%i) against ' ...
    'what you would expect with this duty cycle. ENTER to continue\n'], ...
    sum(gapSummary.numGaps), height(gapSummary));
pause;

% write new xwavs
% path_original = fullfile(path_xwavs(1:xwavFolderIdx-1), 'xwavs_original');
%     % make a copy/backup of original files that will be split
%     mkdir(path_original);
%     fprintf(1, 'Copying %i original files to ''xwavs_original''...\n', height(gapSummary));
    % for of = 1:height(gapSummary)
    %     copyfile(fullfile(gapSummary.folder{of}, gapSummary.fileName{of}), ...
    %         fullfile(path_original, gapSummary.fileName{of}));
    % end
    % then split the files
    writeSplitXwavs(gapSummary, path_xwavs, path_original)

% end % loop through multiple directories


