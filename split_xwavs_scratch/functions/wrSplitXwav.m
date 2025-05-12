function wrSplitXwav(PARAMS, rfStart, rfEnd)
%SPLITXWAV	write new xwav from existing xwav containing only specified raw files
%
%   Syntax:
%       WRSPLITXWAV(RFSTART, RFEND)
%
%   Description:
%       Write a new XWAV, based on an existing XWAV, to include only the
%       raw files specified. Writes correct XWAV header in new shorter
%       file. To be used when splitting an XWAV that has a gap in time
%       between sequential raw files. Requires global PARAMS variable for
%       in and out path/file info, sample rate, and other necessary
%       parameters.
%
%       Modified from a copy of decimatexwav.m within Triton
%
%   Inputs:
%       PARAMS     [struct] various parameters needed to specify metadata
%                  about the XWAV
%       rfStart    [integer] index of first raw file to write
%       rfEnd      [integer] index of last raw file to write (will be
%                  included)
%
%   Outputs:
%       none, writes an .xwav file specified in PARAMS.outfile
%
%   Examples:
%       splitXwav(rfStart, rfEnd);
%
%   See also SPLITXWAVS, WRXWAVHD_SPLIT
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:        12 May 2025
%
%   Created with MATLAB ver.: 9.9.0.1524771 (R2020b) Update 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% global PARAMS

PARAMS.ftype = 2;   % file is xwav

% create and write split file header.
new_xhd = wrxwavhd_split(PARAMS, rfStart, rfEnd);

% now write data
fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile),'r');
fod = fopen(fullfile(PARAMS.outpath, PARAMS.outfile),'a');   % open as append,

% how many raw files to write?
dn = rfEnd - rfStart + 1;
% dn = PARAMS.xhd.NumOfRawFiles;

wrTic = tic; % start stopwatch timer
for di = 1:dn
    % original xwav - specify samples to read and where to start.
    nsamp = PARAMS.xhd.byte_length(di)./(PARAMS.samp.byte*PARAMS.nch);
    fseek(fid,PARAMS.xhd.byte_loc(rfStart + di - 1),'bof');
    % read the data
    data = fread(fid, [PARAMS.nch, nsamp], 'int16');
    % write in new split file
    if PARAMS.nch == 1
        fwrite(fod, data, 'int16');
    else
        for m = 1:PARAMS.nch
            ddata(m,:) = data(m,:);
        end
        fwrite(fod, ddata, 'int16');
    end
    %         end
end
fprintf('done in %.2f seconds.\n', toc(wrTic));

% toc
fclose(fid);
fclose(fod);

% testing - read header of newly written file
% checkPARAMS = rdxwavhd_sf(fullfile(PARAMS.outpath, PARAMS.outfile)); % use 1 as display_times to print times.

end



