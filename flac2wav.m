function flac2wav(path_flac, inDir, outDir, varargin)
% FLAC2WAV	Wrapper to convert FLAC to WAV via command line/flac.exe
%
%   Syntax:
%       FLAC2WAV(PATH_FLAC, INDIR, OUTDIR, VARARGIN)
%
%   Description:
%       Wrapper function to convert a single directory or subdirectories of
%       FLAC files to WAV format using the command line to call flac.exe.
%       The input folder structure will be maintained in the output
%       directory. 
%       flac.exe can be downloaded from https://xiph.org/flac/download.html
%
%   Inputs:
%       path_flac   [string] fullfile path to flac.exe but should not
%                   include the '.exe.', e.g.,
%                   'C:\flac-1.5.0-win\Win64\flac'
%       inDir       [string] path to folder containing FLAC files to be
%                   converted
%       outDir      [string] path to output folder to store newly created
%                   WAV files. *THIS PATH MUST ENDED IN A FINAL SLASH!!* A
%                   check will ensure that it does.
%       OPTIONAL varargins are specified using name-value pairs
%                 e.g., 'verbose', true
%       dryrun        [true or false] log/display what would be done
%                     without modifying any actual files. Default is false
%       overwrite     [true or false] overwrite existing .wav files.
%                     Default is false
%       recursive     [true or false] operate recursively through
%                     subdirectories. Default is false
%       verbose       [true or false] display progress for all files in
%                     Command Window. Default is true
%       logfile       [string] fullfile path to an output text log file. If
%                     just a filename is specified it will be saved in the
%                     current MATLAB working directory. E.g., 'C:/txt.log'
%
%	Outputs:
%       None. Creates files in outDir
%
%   Examples:
%       % no input arguments will prompt user to select paths
%       flac2wav;
%       % use input arguments to skip GUI prompting
%       flac2wav('C:\user.name\programs\flac-1.5.0-win\Win64\flac', ...
%                'F:\flacFiles', 'F:\wavFiles\');
%       % prompt for in/out dirs, overwrite existing, write to a log file
%       flac2wav('C:\user.name\programs\flac-1.5.0-win\Win64\flac', ...
%                 '', '', 'overwrite', true, 'logfile', 'log.txt')
%
%   See also WAV2FLAC
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   2025 December 19
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% argument checks
% set default empty required inputs
if nargin < 1 || isempty(path_flac)
    path_flac = '';
end

if nargin < 2 || isempty(inDir)
    inDir = '';
end

if nargin < 3 || isempty(outDir)
    outDir = '';
end

% path to flac.exe (without the .exe)
% e.g., path_flac = 'C:\Users\selene.fregosi\programs\flac-1.5.0-win\Win64\flac';
if isempty(path_flac) || ~exist([path_flac, '.exe'], 'file')
    [file, location] = uigetfile('*.exe', 'Select flac.exe', path_flac);
    if ~strcmp(file, 'flac.exe')
        error('flac.exe not properly selected. Exiting.')
    end
    path_flac = fullfile(location, 'flac');
end

% check input directory
% e.g., inDir = 'F:\CalCurCEAS2024_glider_data\flac';
if isempty(inDir) || ~isfolder(inDir)
    inDir = uigetdir('C:\', 'Select folder containing FLAC files');
end

% check output directory
% VERY IMPORTANT TO HAVE FINAL SLASH \
% outDir = 'F:\CalCurCEAS2024_glider_data\wav\';
if isempty(outDir) || ~isfolder(outDir)
    outDir = uigetdir(inDir, 'Select folder to write WAV files to');
end
% make sure it has an ending slash
if ~endsWith(outDir, filesep)
    outDir = [outDir, filesep];
end

% parse optional flags
opts.dryRun    = false;
opts.overwrite = false;
opts.recursive = false;
opts.verbose   = true;
opts.logFile   = ''; % default no log

if ~isempty(varargin)
    if mod(numel(varargin), 2) ~= 0
        error('Optional arguments must be name–value pairs')
    end
    for k = 1:2:numel(varargin)
        name  = lower(varargin{k});
        value = varargin{k+1};
        switch name
            case 'dryrun'
                opts.dryRun = logical(value);
            case 'overwrite'
                opts.overwrite = logical(value);
            case 'recursive'
                opts.recursive = logical(value);
            case 'verbose'
                opts.verbose = logical(value);
            case 'logfile'
                opts.logFile = char(value);
            otherwise
                error('Incorrect argument "%s". Check inputs.', varargin{k})
        end
    end
end

if ~islogical(opts.dryRun)
    error('dryRun must be true or false')
end
if ~islogical(opts.overwrite)
    error('overwrite must be true or false')
end
if ~islogical(opts.recursive)
    error('recursive must be true or false')
end
if ~islogical(opts.verbose)
    error('verbose must be true or false')
end
if ~isempty(opts.logFile) && ~ischar(opts.logFile)
    error('logFile must be a character vector')
end

% prep log file if specified
logFID = [];

if ~isempty(opts.logFile)
    logFID = fopen(opts.logFile, 'a');
    if logFID == -1
        error('Could not open log file: %s', opts.logFile)
    end
end

% print progress bits if verbose/log
logmsg = @(varargin) ...
    (opts.verbose && fprintf(varargin{:})) || true;
logwrite = @(fmt, varargin) ...
    (~isempty(logFID) && fprintf(logFID, fmt, varargin{:})) || true;

if opts.verbose
    hWait = waitbar(0, 'Converting FLAC files...', ...
        'Name', 'flac2wav');
else
    hWait = [];
end

% process the files
tic

% display paths
fprintf('inDir: %s\n', inDir);
fprintf('outDir: %s\n', outDir);
logwrite('Starting flac2wav conversion...\n');
logwrite('   inDir: %s\n', inDir);
logwrite('   outDir: %s\n', outDir);

% warn about dry run or overwrite
if opts.dryRun
    fprintf('*** DRY RUN: no files will be created ***\n');
    logwrite(' *** DRY RUN: no files will be created ***\n');
end
if opts.overwrite
    fprintf('*** OVERWRITE ENABLED: existing WAV files will be replaced ***\n');
    logwrite(' *** OVERWRITE ENABLED: existing WAV files will be replaced ***\n');
end

% build out command line string
if opts.overwrite
    decodeStr = '%s --decode --force --keep-foreign-metadata-if-present --output-prefix=%s %s';
else
    decodeStr = '%s --decode --keep-foreign-metadata-if-present --output-prefix=%s %s';
end
logwrite('   Command used: %s\n\n', decodeStr);

% loop through all files and convert
if opts.recursive
    fileList = dir(fullfile(inDir, '**', '*.flac'));
else
    fileList = dir(fullfile(inDir, '*.flac'));
end
if isempty(fileList)
    error('No FLAC files found in %s', inDir);
end

% cd(inDir)
nFiles = length(fileList);
for iFile = 1:nFiles
    % get and check files/paths
    inFile = fullfile(fileList(iFile).folder, fileList(iFile).name);
    relPath = erase(fileList(iFile).folder, inDir);
    relPath = strip(relPath, filesep);
    outSubDir = fullfile(outDir, relPath);
    if ~isfolder(outSubDir)
        mkdir(outSubDir);
    end

    % overwrite check
    outWav = fullfile(outSubDir, ...
        replace(fileList(iFile).name, ".flac", ".wav"));
    if exist(outWav, 'file') && ~opts.overwrite
        logmsg('Skipping existing file: %s\n', outWav)
        logwrite('SKIP: %s\n', outWav);
        continue
    end

    % do the conversion
    myCMD = sprintf(decodeStr, path_flac, outSubDir, inFile);
    if opts.dryRun
        logmsg('[DRY RUN] %s\n', myCMD);
        logwrite('[DRY RUN] %s\n', myCMD);
    else
        [status, cmdout] = system(char(myCMD));
        logwrite('CMD: %s\nSTATUS: %d\n', myCMD, status);
    end
    % [status, cmdout] = system(char(myCMD));
    logmsg('Done with file %d of %d - %s\n', ...
        iFile, nFiles, inFile);
    if ~isempty(hWait) && ishandle(hWait)
        % update progress bar every 10 files (or adjust as needed)
        if mod(iFile, 10) == 0 || iFile == nFiles
            waitbar(iFile / nFiles, hWait, ...
                sprintf('Processing %d of %d files', iFile, nFiles));
        end
    end
end

fprintf(' Done processing %s\n Elapsed time %.0f seconds\n', inDir, toc);
logwrite(' Done processing %s\n Elapsed time %.0f seconds\n', inDir, toc);

if ~isempty(hWait) && ishandle(hWait)
    close(hWait);
end

% close log
if ~isempty(logFID)
    fclose(logFID);
end

end