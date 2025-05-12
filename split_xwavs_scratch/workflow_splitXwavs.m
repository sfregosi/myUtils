% workflow to split duty-cycled xwavs

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
%        To run:
%           - Update the path to the split-xwavs code folder on line 42
%           - Set the input xwav path on line 47 or comment that line out
%           to be prompted to select a folder
%           - Set the output folder on line 59 (it will be created if it
%           doesn't already exist)
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
%	Updated:   9 May 2025
%
%	Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User specified inputs

% add code to path
% path_code = ('C:\Users\selene.fregosi\Documents\MATLAB\split-xwavs');
path_code = 'C:\Users\selene.fregosi\Documents\MATLAB\myUtils\split_xwavs_scratch';
addpath(genpath(path_code));

% set input directory
path_xwavs = 'C:\Users\selene.fregosi\Desktop\split_xwav_test\in\Wake_S_04';
% path_xwavs = 'C:\Users\selene.fregosi\Desktop\split_xwav_test\in\Wake_S_10';
% alternatively just prompt to select path to process
if ~exist('path_xwavs', 'var')
    path_xwavs = uigetdir(path_in, 'Select folder containing xwavs');
    fprintf(1, 'Selected xwav directory: %s\n', path_xwavs);
end

% set output directory
% will be created in writesplitXwavs if it doesn't exist
path_split = ('C:\Users\selene.fregosi\Desktop\split_xwav_test\split');
if ~exist(path_split, 'dir'); mkdir(path_split); end

fprintf(1, 'Splitting xwavs in %s\n', path_xwavs);
fprintf(1, 'Start time %s\n', datetime('now'));
sTic = tic;

%% Find the gaps

% Identify gaps in raw files within xwavs
gapSummary = findXwavGaps(path_xwavs);
save(fullfile(path_split, 'fileGapsSummary.mat'), 'gapSummary'); % save in output folder

% check step
% for a 5 min every 30 min duty cycle, expect 7 gaps per xwav
% may have additional gaps in first file because of deck test files
fprintf(1, ['check number of gaps (n=%i) and files (n=%i) against ' ...
    'what you would expect with this duty cycle.\nPress ENTER to continue.\n'], ...
    sum(gapSummary.numGaps), height(gapSummary));
pause;

%% Split the files
% actually write new files
% this calls rdxwavhd_sf, wrxwavhd_split, wrSplitXwavs
splitXwavs(gapSummary, path_xwavs, path_split)

fprintf(1, 'End time %s. Process took %i seconds.\n', datetime('now'), ...
    round(toc(sTic)));
