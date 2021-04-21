function [Y,FS,NBITS,encoding_info,tag_info] = flacread(FILE,varargin)
%FLACREAD Read FLAC (".flac") sound file.
%    Y = OGGREAD(FILE) reads a OGG file specified by the string FILE,
%    returning the sampled data in Y. Amplitude values are in the range [-1,+1].
%
%    [Y,FS,NBITS,encoding_info,tag_info] = OGGREAD(FILE) returns the sample rate (FS) in Hertz
%    and the number of bits per sample (NBITS) used to encode the
%    data in the file.
%
%    'encoding_info' is a string containing information about the mp3
%    encoding used
%
%    'tag_info' is a string containing the tag information of the file
%
%
%    Supports two channel or mono encoded data.
%
%    See also OGGWRITE, WAVWRITE, AUREAD, AUWRITE.

persistent cachetest

a = length(FILE);
if a >= 4
    exten = FILE(a-3:a);
    if strcmp(exten,'.flac')==1
        FILE = strcat(FILE,'.flac');
    end
end
if a <= 3
    FILE = strcat(FILE,'.flac');
end
if exist(FILE,'file') ~= 2
    error(['File not Found: ' FILE])
end

%%%%%% Location of the ".exe" Files
s = which('flacread.m');
ww = findstr('flacread.m',s);
location = s(1:ww-2);

%%%%Temporary file%%%%%%
tmpdir='';
tmpdir=tempdir;
[pa,na,ex]=fileparts(FILE);
tmpfile = fullfile(tmpdir,[na ex '.wav']);
cachefile = fullfile(tmpdir,[na ex '.tmp.wav']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Info extraction using "ogginfo.exe"%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stat_1=0;

% [stat_1,raw_info] = dos(['"',location,'\ogginfo.exe"',' ', '"',FILE,'"']);
% raw_info_channels_beg = findstr(raw_info,'Channels: ');
% raw_info_channels_end = findstr(raw_info,'Rate: ')-2;
% info_channels = raw_info(raw_info_channels_beg:raw_info_channels_end);
% raw_info_rate_beg = findstr(raw_info,'Rate: ');
% raw_info_rate_end = findstr(raw_info,'Nominal bitrate: ')-1;
% info_rate = strcat(raw_info(raw_info_rate_beg:raw_info_rate_end),' Hz');
% raw_info_bit_rate = findstr(raw_info,'Nominal bitrate: ');
% raw_info_bit_rate_end = findstr(raw_info,'kb/s');
% info_bit_rate = raw_info(raw_info_bit_rate+17:raw_info_bit_rate_end-1);
% info_bit_rate = ['Bit Rate: ',num2str(floor(str2num(info_bit_rate))),' Kb/s'];
% encoding_info = {info_channels info_rate info_bit_rate};
% %%%%% TAG INFO %%%%%
% if isempty(findstr(raw_info,'User comments section follows...')) ~= 1
%     tag_info_beg = findstr(raw_info,'User comments section follows...')+32;
%     tag_info_end = findstr(raw_info,'Vorbis stream 1:')-1;
%     tag_info = raw_info(tag_info_beg:tag_info_end);
% else
%     tag_info = 'No Tag Info';
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% File Decoding using "oggdec.exe" %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Y=[];FS=NaN;NBITS=NaN;

if nargin>1
    if isequal(varargin{end},'cache')
        %disp(['start "flaccache" /B /min ' location '\flaccache.cmd "' FILE '" "' cachefile '" "' tmpfile '"']);
        dos(['start "flaccache" /B /min ' location '\flaccache.cmd "' FILE '" "' cachefile '" "' tmpfile '"']);
        cachetest=FILE;
        return
    end
end

i=0;
while isequal(cachetest,FILE) && ~exist(tmpfile,'file')
    i=i+1;
    pause(0.1)
    if i==10
        disp(['waiting for cache: ' FILE])
    end
    if i==600
        warning(['ignoring cache for:' FILE])
        break
    end
end

if ~exist(tmpfile,'file')
    cachetest=[];
    [stat_2,raw_info] = dos(['"' location,'\flac.exe"', ' -d -o "', tmpfile, '" ', '"',FILE,'"']);
    if stat_1 || stat_2
        warning(['Problems in flac.exe while decoding file ' FILE])
    end
end

if exist(tmpfile,'file')
    cachetest=[];
    try
        [Y,FS,NBITS] = wavread(tmpfile);    % Load the data and delete temporary file
    catch
        try delete(tmpfile); catch warning(['cannot delete ' tmpfile ]); end
        error(['Error while reading converted file ' tmpfile ])
    end
    try delete(tmpfile); catch warning(['cannot delete ' tmpfile ]); end
else
    error(['Error flac.exe could not convert ' FILE ' to .wav'])
end
