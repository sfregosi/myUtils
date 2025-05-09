function writeSplitXwavs(gapSummary, path_xwavs, path_split)
%WRITESPLITXWAVS	batch process write new split xwavs for all with gaps
%
%   Syntax:
%       WRITESPLITXWAVS(GAPSUMMARY, PATH_XWAVS, PATH_SPLIT)
%
%   Description:
%       Processes a directory of duty cycled xwavs to split them by
%       identified time gaps and writes new xwavs with filenames that have
%       the timestamp of each raw file to a new folder path_split.
%
%   Inputs:
%       gapSummary     [table] summary info of which files contain gaps,
%                      number, and location of gaps
%       path_xwavs     [string] fullfile path to xwavs to be split
%       path_split     [string] fullfile path to output folder for newly
%                      split files 
%
%   Outputs:
%       none, writes xwavs
%
%   Examples:
%       writeSplitXwavs(gapSummary, path_xwavs, path_split)
%
%   See also SPLITXWAV, WRXWAVHD_SPLIT
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:        9 May 2025
%
%   Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% global PARAMS

if ~exist(path_split, 'dir')
    mkdir(path_split);
end

% loop through each original file and split
for xwf = 1:height(gapSummary)

    % read xwav header info
    PARAMS = rdxwavhd_sf(fullfile(gapSummary.folder{xwf}, ...
        gapSummary.fileName{xwf}), false); % use true to print times for testing

    % update PARAMS with the input file name and path to split output files
    PARAMS.infile = gapSummary.fileName{xwf};
    PARAMS.inpath = path_xwavs;

    % find gaps btwn raw files > 75 seconds to find breaks in raw files
    gapIdx = find(gapSummary.rawGaps{xwf} > seconds(75));
    % add length of raw files as "last gap" (typically 30)
    % have to ignore NaTs to get correct length
    gapIdx = [gapIdx; length(gapSummary.rawDates{xwf}(~isnat(gapSummary.rawDates{xwf})))];
    % there may be several gaps before the deployment because of bench
    % testing. That's ok. Still write individually
    fprintf(1, '%s: %i gaps, %i files to write...\n', gapSummary.fileName{xwf}, ...
        length(gapIdx)-1, length(gapIdx));

    for nf = 1:length(gapIdx) % loop through new files to be made
        % how many raw files for this new file
        if nf == 1 % first new file should start with raw file 1.
            numRawFiles = gapIdx(nf);
        else
            numRawFiles = gapIdx(nf) - gapIdx(nf-1);
        end

        % indicies of raw files to write
        rfEnd = gapIdx(nf);
        rfStart = rfEnd - numRawFiles + 1;

        % generate new file name based on first raw file datetime
        newFileStartTime = gapSummary.rawDates{xwf}(rfStart);
        newFileStartStr = datestr(newFileStartTime,'yymmdd_HHMMSS');
        % split up the original-to-split file name by the date
        [~, prefix_strs] = regexp(tsFileName,'\d{6}[_]\d{6}','match','split');
        %             date_strs = regexp(filenamesc,'\d{6}[-]\d{6}','match');
        newFileName =  [prefix_strs{1} newFileStartStr prefix_strs{2}];
        PARAMS.outfile = newFileName;
        PARAMS.outpath = path_split;

        % write the new file
        fprintf(1, 'writing new file: %s ...', newFileName)
        splitxwav(rfStart, rfEnd);
    end % end new files to be written


    %testing - read header of newly written file.
    %             PARAMS = rdxwavhd_so(fullfile(PARAMS.outpath, PARAMS.outfile)); % use 1 as display_times to print times.

end % xwavs to be broken up


end
