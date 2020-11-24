% main .m file for kinematic tracking of passively localized things from SCORE and PMRF
% this version of code is provided for tracking minke whales only and
% sample localizations are provided to allow running the code standalone

% S. Martin original code 22 July 2014, updated 9 June 2015 by C. Martin -
% major revision Aug 2015 (code clean up using more functions, plot tracks from decimated recordings)
% note: older localizations (pre Feb 2014 baseline 1 processing) do NOT
% have the depth (z) field in the localizations text file (e.g.
% /06Feb15/TrackMinke.dat)
place=input('Tracking on PMRF(1), SCORE(2), or other(3) ?  ');
RunPath=('i:\score\2015\c3d\');
RunPath=('i:\score\2015\matlab\MartinTracking');
% RunPath=('C:/Tracker_19Aug2015/');
cd (RunPath)
phInfo=[];  %placeholder for hydrophone sensor locations (unable to provide PMRF phone locations here)
%what do you want to PAM track?
trackWhat=1;   %for sample public release code only provide minke example (trackWhat=1 is minke)
%load params for what is to be tracked, max delta time, max Lat/lon, max
%feature (DSC for minke), etc.
if trackWhat==1; load TrackParamMinke; end

%previously tracked this? If so, can just use the matlab structure from
%prior tracking run
prior=input('Use previously tracked info?  Yes(1)/No(0)  ');
if prior==1;
    if trackWhat==1, [matfilenam, matpathnam]=uigetfile('MinkeTracks.mat', 'select the minke .mat file'); end
    cd (matpathnam)
    load (matfilenam, 'vTk', 'vTkICI','Indat', 'DeltaTmax', 'InDir', 'tvcnt'); %this will load the vTk nested struct
    %TkParams
    cd (RunPath)
    %plot all of the valid tracks over time
    [vTk,startTim,endTim]=PlotAllValidTracks(place, phInfo, Indat, vTk);
else%create new (or changed track parameter values) track the localizations provided
    %read in localization data, ascii text file 
    [Indat, RunPath, InDir, filenam, pathnam]=ReadC3Dlocs(place, RunPath, trackWhat);
    if trackWhat==1, save IndatMinke Indat, end;    %save the input data to .mat file
    minNumEle=0;
    cd(RunPath); 
    %GenTracks is the function that actually creates the tracks from the
    %localizations
    [vTk, vTkICI, TrackStats, tvcnt, ICI,ICIcor, ICIt, ICItcor, spdICI]=GenTracks_original(trackWhat, InDir, DeltaTmax, DeltaLatmax, DeltaLonmax, RunPath);
    [vTk,startTim,endTim]=PlotAllValidTracks(place, phInfo, Indat, vTk);    %plot all tracks generated over time
    cd (InDir);
    %save matlab structure and data from tracking run
    if trackWhat==1
        save vTkMinke vTk vTkICI place trackWhat InDir Indat tvcnt DeltaTmax DeltaLatmax DeltaLonmax
    end
    cd (RunPath)
end
% FOR PLOTTING INDIVIDUAL TRACK DETAILS (lat/lon and subplots for call
% intervals and estimated speed based upon movement and time between calls
disp(' ');
morePlts=1;
plotIndTk=input('Do you want to plot any individual tracks?  Yes(1)/No(0)  ');
if plotIndTk==1
    cd(InDir); 
    status=0;
    if trackWhat==1;load vTkMinke; end;
    plotN=input('Enter track # for single plot and IDI plot ');
    %generate the Inter Call Intervals and estimated speeds from the track
    %structure and save in ICI structure
    while plotIndTk==1
        ICI=vTkICI(plotN).ICI;
        ICIcor=vTkICI(plotN).ICIcor;
        ICItcor=vTkICI(plotN).ICItcor;
        spdICI=vTkICI(plotN).spdICI;
        [status]=plotIndTkDetails(vTk,vTkICI,trackWhat, tvcnt, phInfo, place, plotN, ICI, ICIcor, ICItcor, spdICI);
        plotN=input('Plot more tracks details?  Enter track #/No(0)  ');
        disp(' ');
        if plotN==0, plotIndTk=0; end
        if plotN>0, plotIndTk=1; end
    end
end
cd(RunPath)