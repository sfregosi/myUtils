function writeXwavsNewTime(path_xwavs, path_new, timeOffset)
%WRITEXWAVSNEWTIME	Rewrite xwavs with corrected time in header and name
%
%   Syntax:
%       WRITEXWAVSNEWTIME(path_xwavs, path_new, timeOffset)
%
%   Description:
%       function to read in existing xwav and header, adjust header by hour
%		specified in 'timeOffset' and re-write in a new folder
% 
%   Inputs:
%       path_xwavs   path to original xwavs to be read and rewritten
%       path_new     path to location to save new xwavs
%       timeOffset   offset necessary to rewrite xwavs to UTC time, in hours
%
%   Outputs:
%       none. writes xwavs
%
%   Examples:
%
%   See also WRITESPLITXWAVS
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   FirstVersion:   10 May 2023
%   Updated:        11 May 2023
%
%   Created with MATLAB ver.: 9.14.0.2239454 (R2023a) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS

% get list of all files
xwavList = dir([path_xwavs '\*.x.wav']);
xwavNames = {xwavList(:).name}';

for wf = 1:length(xwavNames)
    %     tsFileNum = gapSummary.fileNum(wf);
    tfn = fullfile(xwavList(wf).folder, xwavList(wf).name);
    PARAMS = rdxwavhd_so(tfn,[]); % use 1 as display_times to print times.

    % make copy of PARAMS before overwriting anything - for testing
    % PARAMS_og = PARAMS;

    % update PARAMS with the input file name and path (to be trimmed)
    PARAMS.infile = xwavList(wf).name;
    PARAMS.inpath = xwavList(wf).folder;

    % update PARAMS with fixed times
    PARAMS.xhd.hour = PARAMS.xhd.hour + timeOffset;
    PARAMS.raw.dnumStart = PARAMS.raw.dnumStart + datenum(0,0,0,timeOffset,0,0);
    PARAMS.raw.dvecStart(:,4) = PARAMS.raw.dvecStart(:,4) + timeOffset;
    PARAMS.raw.dnumEnd = PARAMS.raw.dnumEnd + datenum(0,0,0,timeOffset,0,0);
    PARAMS.raw.dvecEnd(:,4) = PARAMS.raw.dvecEnd(:,4) + timeOffset;
    PARAMS.start.dnum = PARAMS.start.dnum + datenum(0,0,0,timeOffset,0,0);
    PARAMS.start.dvec(4) = PARAMS.start.dvec(4) + timeOffset;
    PARAMS.end.dnum = PARAMS.start.dnum + datenum(0,0,0,timeOffset,0,0);


    % generate new file name based on offset
    dvec_start = PARAMS.start.dvec;
    dvec_start(1) = dvec_start(1) + 2000; % fix year
    newFileStartTime = datetime(dvec_start);
    newFileStartStr = datestr(newFileStartTime,'yymmdd_HHMMSS');
    % split up the original-to-split file name by the date
    [~, prefix_strs] = regexp(xwavList(wf).name,'\d{6}[_]\d{6}','match','split');
    newFileName =  [prefix_strs{1} newFileStartStr prefix_strs{2}];
    PARAMS.outfile = newFileName;
    PARAMS.outpath = path_new;

    % write the new file
    % use the splitting functions but just do for all raw files
    rfStart = 1;
    rfEnd = length(PARAMS.raw.dnumStart);

    fprintf(1, 'writing new file: %s ...', newFileName)
    splitxwav(rfStart, rfEnd);

end % end xwavs to be re-written


%testing - read header of newly written file.
%             PARAMS = rdxwavhd_so(fullfile(PARAMS.outpath, PARAMS.outfile),1); % use 1 as display_times to print times.



end
