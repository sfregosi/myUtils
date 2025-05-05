function gapSummary = findXwavGaps(path_xwavs)

% FIND GAPS IN XWAV FILES
%
%
%   INPUTS:     path_xwavs  path to xwavs, should include "xwavs" folder
%
%   OUTPUTS:    gapSummary  table with summary info on which files containt
%                           gaps and how many
%


% extract sound files
wavFiles = dir(fullfile(path_xwavs, '**\*.x.wav'));
% wavFiles = dir([path_xwavs '**\*.x.wav']); % this will look in subdirs also.
wavFileNames = {wavFiles.name}'; % just to make it a little easier to view/access

% read headers to get an idea of what needs to be done
toSplit = [];
numGaps = [];
rawGapList = [];
rawDates = [];
fileStartDT = [];
for wf = 1:length(wavFileNames)
    xwav = fullfile(wavFiles(wf).folder, wavFileNames{wf});
    PARAMS = rdxwavhd_so(xwav, false); % use true as display_times to print times.
    
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
    % there may be several gaps before the deployment because of bench
    % testing. That's ok. Still write individually
    
    % list which files need to be broken up.
    if ~isempty(gapIdx)
        fprintf(1, 'File: %i, %i gaps\n', wf, length(gapIdx));
        toSplit = [toSplit; wf];
        numGaps = [numGaps; length(gapIdx)];
        rawGapList = [rawGapList; {rawGaps}];
        rawDates = [rawDates; {rawDateList}];
        fileStartDT = [fileStartDT; rawDateList(1)];
    end
end % loop through all xwavfiles

% summarize split file info
gapSummary = table;
gapSummary.fileNum = toSplit;
gapSummary.fileName = wavFileNames(toSplit);
gapSummary.folder = {wavFiles(toSplit).folder}';
gapSummary.fileStartDT = fileStartDT;
gapSummary.fileStartDT_HST = fileStartDT - hours(10);
gapSummary.numGaps = numGaps;
gapSummary.rawGaps = rawGapList;
gapSummary.rawDates = rawDates;

% sort by date
gapSummary = sortrows(gapSummary,'fileStartDT');

end