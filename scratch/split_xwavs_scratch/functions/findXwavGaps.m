function gapSummary = findXwavGaps(path_xwavs)
% FINDXWAVGAPS	Identify time gaps between raw files in xwavs
%
%   Syntax:
%       GAPSUMMARY = FINDXWAVGAPS(PATH_XWAVS)
%
%   Description:
%       Reads through a directory of xwavs and identify gaps in time
%       between consecutive raw files and saves the timing and gap info to
%       an output table called 'gapSummary' for review.
%
%       Extracts the start time of each raw file from the xwav header and
%       identifies gaps between consecutive raw file start times that are
%       greater than a certain threshold (currently 75 sec for a 'typical'
%       HARP; could be modified) to indicate a break in continuous
%       recording
%
%       This is done before splitting raw files into individual xwavs
%       without gaps
%
%   Inputs:
%       path_xwavs   [string] fullfile path to xwavs to be split
%
%	Outputs:
%       gapSummary   [table] summary info of which files contain gaps,
%                    number, and location of gaps. Columns:
%                    filenum - the number of the file processed
%                    filename - the xwav file name
%                    folder - the path to the file
%                    fileStartDT - the start time of the file as MATLAB
%                           datetime
%                    numGaps - the number of gaps between raw files above
%                           the 75 sec threshold
%                    rawGaps - cell of durations of all raw file gaps
%                           (typically 1:15 aka 75 sec)
%                    rawDates - cell of datetimes with startime of each raw
%                           file
%
%   Examples:
%       gapSummary = findXwavGaps(path_xwavs);
%
%   See also READXWAVHD_SF
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   09 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% extract sound files
xwavFiles = dir(fullfile(path_xwavs, '*.x.wav'));
xwavFileNames = {xwavFiles.name}'; % make it easier to view/access

% set up outputs
toSplit     = NaN(length(xwavFiles), 1);
numGaps     = NaN(length(xwavFiles), 1);
rawGapList  = cell(length(xwavFiles), 1);
rawDates    = cell(length(xwavFiles), 1);
fileStartDT = NaT(length(xwavFiles), 1);
tsCount = 0;

% read headers to see what files need splitting
for xwf = 1:length(xwavFileNames)
    xwav = fullfile(xwavFiles(xwf).folder, xwavFileNames{xwf});
    PARAMS = rdxwavhd_sf(xwav, false); % use true to print times for testing

    % export the raw file times as datetiemes
    rawDateList = NaT(30,1);
    for rf = 1:length(PARAMS.xhd.year)
        xdatevec = [PARAMS.xhd.year(rf)+2000 PARAMS.xhd.month(rf) ...
            PARAMS.xhd.day(rf) PARAMS.xhd.hour(rf) PARAMS.xhd.minute(rf)...
            PARAMS.xhd.secs(rf)+PARAMS.xhd.ticks(rf)/1000 ];
        %         disp(datestr(xdatevec));
        rawDateList(rf,1) = datetime(xdatevec);
    end

    % find gaps btwn raw files > 75 seconds to find breaks in raw files
    rawGaps = diff(rawDateList);
    gapIdx = find(rawGaps > seconds(75));
    % these should occur according to the duty cycle but also may have a
    % few at the start of a deployment because of bench testing

    % list which files need to be broken up.
    if ~isempty(gapIdx)
        fprintf(1, 'File: %i, %i gaps\n', ...
            xwf, length(gapIdx));
        tsCount = tsCount + 1;
        toSplit(tsCount) = xwf;
        numGaps(tsCount) = length(gapIdx);
        rawGapList(tsCount) = {rawGaps};
        rawDates(tsCount) = {rawDateList};
        fileStartDT(tsCount) = rawDateList(1);
    end
end % loop through all xwavfiles

% clean up outputs (left over preallocation bc of files that didn't have gaps)
toSplit     = toSplit(1:tsCount);
numGaps     = numGaps(1:tsCount);
rawGapList  = rawGapList(1:tsCount);
rawDates    = rawDates(1:tsCount);
fileStartDT = fileStartDT(1:tsCount);

% summarize split file info
gapSummary = table;
gapSummary.fileNum = toSplit;
gapSummary.fileName = xwavFileNames(toSplit);
gapSummary.folder = {xwavFiles(toSplit).folder}';
gapSummary.fileStartDT = fileStartDT;
% gapSummary.fileStartDT_HST = fileStartDT - hours(10);
gapSummary.numGaps = numGaps;
gapSummary.rawGaps = rawGapList;
gapSummary.rawDates = rawDates;

% sort by date
gapSummary = sortrows(gapSummary, 'fileStartDT');

end