function writeSplitXwavs(gapSummary, path_xwavs, path_original)
%WRITESPLITXWAVS	batch process write new split xwavs for all with gaps
%
%   Syntax:
%       WRITESPLITXWAVS(GAPSUMMARY, PATH_XWAVS, PATH_ORIGINAL)
%
%   Description:
%       Process all xwavs from a trip/recorder combination to write new,
%       split xwavs based on all identified gaps in original xwavs and
%       listed in gapSummary variable. 
% 
% Loads and modifies a global PARAMS
%       variable for information about file paths, sample rates, and other
%       parameters. 
%
%   Inputs:
%       gapSummary     [table] summary info of which files contain gaps,
%                      number, and location of gaps
%       path_xwavs     [string] fullfile path to xwavs, inclusive of 
%                      'xwavs' folder
%       path_original  path to back up original unsplit copies of all xwavs
%                      to be split
%
%   Outputs:
%       none, writes xwavs
%
%   Examples:
%       writeSplitXwavs(gapSummary, path_xwavs, path_original)
%
%   See also SPLITXWAV, WRXWAVHD_SPLIT
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   FirstVersion:   8 February 2022
%   Updated:        29 September 2023
%
%   Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS

% if the split files need to be stored in own subfolder
% can do this and still run all in Pamguard without issue, but causes
% issues when looking for xwavs when browsing LTSA in Triton
path_split = path_xwavs;
% path_split = [path_data 'splitFiles\'];
% mkdir(path_split);

% loop through each original file and split
for wf = 1:height(gapSummary)
%     tsFileNum = gapSummary.fileNum(wf);
    tsFileName = gapSummary.fileName{wf};
    tsFilePath = gapSummary.folder{wf};
    PARAMS = rdxwavhd_so(fullfile(tsFilePath, tsFileName),[]); % use 1 as display_times to print times.
    
%     % move original file to xwavs_original folder (move in the beginning
%     % and then open from this location when writing later (to not overwrite)
%     movefile(fullfile(tsFilePath, tsFileName), ...
%         fullfile(path_original, tsFileName));
    % check that file is backed up in path_original
    ogCheck = exist(fullfile(path_original, tsFileName),'file');
    if ogCheck ~= 2
        fprintf('Confirm that original file %s is backed up! exiting writeSplitXwavs.m\n', tsFileName);
        return
    end
    
    % update file path
    tsFilePath = path_original;
    % update PARAMS with the input file name and path (to be trimmed)
    PARAMS.infile = tsFileName;
    PARAMS.inpath = tsFilePath;
    
    
    % find gaps btwn raw files > 75 seconds to find breaks in raw files
    gapIdx = find(gapSummary.rawGaps{wf} > seconds(75));
    % add length of raw files as "last gap" (typically 30)
    % have to ignore NaTs to get correct length
    gapIdx = [gapIdx; length(gapSummary.rawDates{wf}(~isnat(gapSummary.rawDates{wf})))];
    % there may be several gaps before the deployment because of bench
    % testing. That's ok. Still write individually
    fprintf(1, '%s: %i gaps, %i files to write...\n', tsFileName, ...
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
        newFileStartTime = gapSummary.rawDates{wf}(rfStart);
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
