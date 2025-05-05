function splitxwav(rfStart, rfEnd)
%SPLITXWAV	write new xwav from existing xwav containing only specified raw files
%
%   Syntax:
%       SPLITXWAV(RFSTART, RFEND)
%
%   Description:
%       Write a new xwav, based on an existing xwav, to include only the
%       raw files specified. Writes correct xwav header in new shorter
%       file. To be used when splitting an xwav that has a gap in time
%       between sequential raw files. Requires global PARAMS variable for
%       in and out path/file info, sample rate, and other necessary
%       parameters. 
%
%       Modified from a copy of decimatexwav.m within Triton
%
%   Inputs:
%       rfStart    [integer] index of first raw file to write
%       rfEnd      [integer] index of last raw file to write (will be
%                  included)
%
%   Outputs:
%       none, writes an .xwav file specified in PARAMS.outfile
%
%   Examples:
%       splitxwav(rfStart, rfEnd);
%
%   See also WRITESPLITXWAVS, WRXWAVHD_SPLIT
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   FirstVersion:   8 February 2022
%   Updated:        29 September 2023
%
%	Created with MATLAB ver.: 9.9.0.1538559 (R2020b) Update 3
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS

PARAMS.ftype = 2;   % file is xwav

% if want to check file name or give option for changing it 
% boxTitle2 = ['Save trimmed x.wav file'];
% [PARAMS.outfile,PARAMS.outpath] = uiputfile(PARAMS.outfile,boxTitle2);

% create and write trimmed header. 
new_xhd = wrxwavhd_split(rfStart, rfEnd);

% now write data
fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile),'r');
fod = fopen(fullfile(PARAMS.outpath, PARAMS.outfile),'a');   % open as append,

% how many raw files to write?
dn = rfEnd - rfStart + 1;
% dn = PARAMS.xhd.NumOfRawFiles;

tic % start stopwatch timer
        for di = 1:dn
            % original xwav - specify samples to read and where to start. 
            nsamp = PARAMS.xhd.byte_length(di)./(PARAMS.samp.byte*PARAMS.nch);            
            fseek(fid,PARAMS.xhd.byte_loc(rfStart + di - 1),'bof');
            % read the data
            data = fread(fid,[PARAMS.nch, nsamp],'int16');
            % write in new trimmed file. 
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
fprintf('done in %.2f seconds.\n', toc);

% toc
fclose(fid);
fclose(fod);

end



