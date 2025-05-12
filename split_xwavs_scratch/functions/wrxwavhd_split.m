function new_xhd = wrxwavhd_split(PARAMS, rfStart, rfEnd)
% WRXWAVHD_SPLIT    Write an XWAV header
%
%   Syntax:
%       NEW_XHD = WRXWAVHD_SPLIT(PARAMS, RFSTART, RFEND)
%
%   Description:
%       Modified version of Triton's wrxwavhd (used in decimating data)
%       that writes a header just for a select number of raw files from an
%       existing XWAV header. To be used when splitting XWAVs by gaps
%       between dutycycles. 
%
%       Modifications include the inputs of which raw files to write and
%       changing PARAMS to an input and output rather than global
%
%   Inputs:
%       PARAMS     [struct] various parameters needed to specify metadata
%                  about the XWAV
%       rfStart    [integer] index of first raw file to write
%       rfEnd      [integer] index of last raw file to write (will be
%                  included)
%
%	Outputs:
%       generates the beginning of an XWAV file
%       new_xhd    [struct] PARAMS.xhd but for the new split file - various
%                  parameters needed to specify metadata about the XWAV
%
%   Examples:
%
%   See also SPLITXWAVS, WRSPLITXWAV
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   09 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% global PARAMS

num_rf = rfEnd - rfStart + 1;

new_xhd = []; % temporary varible to hold the header info
% want to keep initial PARAMS.xhd because they may be trimmed several times
% for a single initial xwav file to be trimmed. 

% start populating new_xhd
new_xhd.ByteRate = PARAMS.xhd.ByteRate;
new_xhd.byte_length = PARAMS.xhd.byte_length(rfStart:rfEnd);
new_xhd.sample_rate = PARAMS.xhd.sample_rate(rfStart:rfEnd);
new_xhd.write_length = PARAMS.xhd.write_length(rfStart:rfEnd);

header_size = (8+4) + (8+16) + 64 + (32 * num_rf) + 8;
new_xhd.nsubchunksize = sum(new_xhd.byte_length(:)) + (header_size - 8); % header - 8 bytes
new_xhd.dsubchunksize = sum(new_xhd.byte_length(:));
new_xhd.time = inf*ones(num_rf,7); % preinitialize for speed
new_xhd.time =  [PARAMS.xhd.year(rfStart:rfEnd); PARAMS.xhd.month(rfStart:rfEnd); ...
    PARAMS.xhd.day(rfStart:rfEnd); PARAMS.xhd.hour(rfStart:rfEnd); ...
    PARAMS.xhd.minute(rfStart:rfEnd); PARAMS.xhd.secs(rfStart:rfEnd); ...
    PARAMS.xhd.ticks(rfStart:rfEnd)]';
new_xhd.byte_loc(1) = header_size;% Pad for header and dir listings

if num_rf > 1
    for rf = 2:num_rf
        new_xhd.byte_loc(rf) = new_xhd.byte_loc(rf-1) + new_xhd.byte_length(rf-1);
    end
end
new_xhd.gain = PARAMS.xhd.gain(rfStart:rfEnd).*ones(1,num_rf); % they stay the same, could be wrong


% wav file header parameters
% RIFF Header stuff:
harpsize = num_rf * 32 + 64 - 8;% length of the harp chunk
% end
% Format Chunk stuff:
% fsize = PARAMS.xhd.fSubchunkSize;  % format chunk size
% fcode = PARAMS.xhd.AudioFormat;
fsize = 16;  % format chunk size
if PARAMS.nBits == 16 || PARAMS.nBits == 24
    fcode = 1;   % compression code (PCM = 1)
elseif PARAMS.nBits == 32
    fcode = 3;   % compression code (PCM = 3) for 32 bit
end
PARAMS.xhd.BlockAlign = PARAMS.nch*PARAMS.nBits/8; % byte for one sample with all channels
% open output file
fod = fopen(fullfile(PARAMS.outpath, PARAMS.outfile), 'w' );

% write xwav file header
% RIFF file header                  % length = 12 bytes
fprintf( fod, '%c' , 'R' );
fprintf( fod, '%c' , 'I' );
fprintf( fod, '%c' , 'F' );
fprintf( fod, '%c' , 'F' );                      % byte 4
fwrite( fod, new_xhd.nsubchunksize, 'uint32' );               % ChunkSize
fprintf( fod, '%c', 'W' );
fprintf( fod, '%c', 'A' );
fprintf( fod, '%c', 'V' );
fprintf( fod, '%c', 'E' );

% Format information
fprintf( fod, '%c', 'f' );
fprintf( fod, '%c', 'm' );
fprintf( fod, '%c', 't' );
fprintf( fod, '%c', ' ' );                      % byte 16
fwrite( fod, fsize, 'uint32' );
fwrite( fod, fcode, 'uint16' );
fwrite( fod, PARAMS.nch, 'uint16' );         % only one channel of data shown in window this is wrong
fwrite( fod, PARAMS.fs, 'uint32' );
fwrite( fod, PARAMS.fs*PARAMS.xhd.BlockAlign, 'uint32' );   % ByteRate
fwrite( fod, PARAMS.xhd.BlockAlign, 'uint16' );
fwrite( fod, PARAMS.nBits, 'uint16' );                  % byte 35 & 36

% "harp" chunk (64 bytes long)
fprintf( fod, '%c', 'h' );
fprintf( fod, '%c', 'a' );
fprintf( fod, '%c', 'r' );
fprintf( fod, '%c', 'p' );
fwrite( fod, harpsize, 'uint32');
fwrite( fod, PARAMS.xhd.WavVersionNumber , 'uchar' );
% check the firmware version...make sure not funky!
% find if any are non-ascii values
if any(PARAMS.xhd.FirmwareVersionNumber > 127) % something is non-ascii...deal with it.
    asciiOnly = regexprep(PARAMS.xhd.FirmwareVersionNumber, '[^0-9a-zA-Z.\s]+', '');
    PARAMS.xhd.FirmwareVersionNumber = pad(asciiOnly, 10, 'right');
elseif all(PARAMS.xhd.FirmwareVersionNumber < 128) % all are ascii values
    % all good no change.
end
fprintf( fod, '%c', PARAMS.xhd.FirmwareVersionNumber );  % 10 char
fprintf( fod, '%c', PARAMS.xhd.InstrumentID );            % 4 char
fprintf( fod, '%c', PARAMS.xhd.SiteName );                % 4 char
fprintf( fod, '%c', PARAMS.xhd.ExperimentName );          % 8 char
fwrite( fod, PARAMS.xhd.DiskSequenceNumber, 'uchar' );
fprintf( fod, '%c', PARAMS.xhd.DiskSerialNumber );        % 8 char

fwrite( fod, num_rf, 'uint16' );
fwrite( fod, PARAMS.xhd.Longitude, 'int32' );
fwrite( fod, PARAMS.xhd.Latitude, 'int32' );
fwrite( fod, PARAMS.xhd.Depth, 'int16' );
fwrite( fod, 0, 'uchar' );   % padding
fwrite( fod, 0, 'uchar' );
fwrite( fod, 0, 'uchar' );
fwrite( fod, 0, 'uchar' );
fwrite( fod, 0, 'uchar' );
fwrite( fod, 0, 'uchar' );
fwrite( fod, 0, 'uchar' );
fwrite( fod, 0, 'uchar' );                        % byte 100
for k = 1:num_rf
    fwrite( fod, new_xhd.time( k, 1 ), 'uchar' );
    fwrite( fod, new_xhd.time( k, 2 ), 'uchar' );
    fwrite( fod, new_xhd.time( k, 3 ), 'uchar' );
    fwrite( fod, new_xhd.time( k, 4 ), 'uchar' );
    fwrite( fod, new_xhd.time( k, 5 ), 'uchar' );
    fwrite( fod, new_xhd.time( k, 6 ), 'uchar' );
    fwrite( fod, new_xhd.time( k, 7 ), 'uint16' );
    fwrite( fod, new_xhd.byte_loc( k ), 'uint32' );
    fwrite( fod, new_xhd.byte_length( k ), 'uint32' );
    fwrite( fod, new_xhd.write_length( k ), 'uint32' );
    fwrite( fod, new_xhd.sample_rate( k ), 'uint32' );
    fwrite( fod, new_xhd.gain( k ), 'uint8' );
    fwrite( fod, 0, 'uchar' ); % padding
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
end

% Data area -- variable length
fprintf( fod, '%c', 'd' );
fprintf( fod, '%c', 'a' );
fprintf( fod, '%c', 't' );
fprintf( fod, '%c', 'a' );           % data subchunk
fwrite( fod, new_xhd.dsubchunksize, 'uint32' ); % Data SubChunkSize

fclose(fod);
% disp_msg( ['done writing header for ', PARAMS.outpath, PARAMS.outfile] )

end