function [vTk, vTkICI, TrackStats, tvcnt, ICI,ICIcor, ICIt, ICItcor, spdICI] = ...
    GenTracks_SF_BpL(BpL, DeltaTmax, DeltaLatmax, DeltaLonmax, minNumPh, maxLS, minNumEle)
% function to track localizations using BpL
% Input
%       location data as BpL variable; preload the file outside of this function
%       deltaTmax
%       deltaLatmax
%       deltaLonmax
%       minNumPh, maxLS, minNumEle - SF added to input in function not
%       manually while coe is running. 
% Output

% for testing
% path_in = 'D:\score\2015\finTracks\';
% fname = 'BpLocs_TrackFinSei_all.mat';
% load([path_in fname]);
% DeltaLatmax = 0.003; % ~150 m
% DeltaLonmax = 0.003;
% DeltaTmax = 240; % seconds
%*****END TESTING****


cnt=0;  %initialize variables
trkcntr=0;
loops=height(BpL); % loop through EVERY location
tnum=zeros(loops,81);   % make tnum array track # (max length(Indat)by 79 (max num phones +2
tnum(:,1) = [1:loops]; %first element of each row is the track number
BpL.trkd = zeros(loops,1);

% deltaTMax input is in seconds so needs to be changed to datenum
DeltaTmax = DeltaTmax/86400;

%prompt to enter the minimum number of hydrophones used in each
%localization and the maximum Least square for valid localizaitons (often
%limited by the automatic detection process in previous processing
%steps)
% minNumPh=input('enter min num of hydrophones in each localization (>4)   = ');
% maxLS=input('enter the max LS for a loc to be valid, e.g. 0.1 s    =  ');
%this looping creates tracks which employ ALL localizations (e.g. single
%element tracks possible here)

for m=1:loops % loop through every location
    % check that location hasn't been tracked yet and that it meets the min
    % phone and max lse criteria
    if (BpL.trkd(m)==0) && (BpL.numPh(m)>=minNumPh) && BpL.lse(m)<=maxLS
        % sf modified for SCORE - 9/1/2016 - check that it is within the
        % range region
        if (ge(BpL.lat(m),32.6)) && (le(BpL.lat(m),33.2)) && ...
                (ge(BpL.lon(m),-119.35)) && (le(BpL.lon(m),-118.5))   
            % for each location, loop through each possible already
            % occuring track and see if that location fits a track
            for tnL=1:9999   %magic number MAX number of tracks 999 includes single element tracks!!
                % if this loc hasn't been tracked and the current track
                % number already has at least one element already
                if BpL.trkd(m)==0 && tnum(tnL,2)>0   %this element NOT tracked yet but the track has elements
                    % extract out elements that are already in that track
                    mm=tnum(tnL,3:2+tnum(tnL,2));   % keeping record of what loc #'s are in a track
                    
                    if BpL.timeDN(m)-Tk(tnL).nest.timeDN(length(mm)) <= DeltaTmax && ...
                            abs(BpL.lat(m)-Tk(tnL).nest.lat(length(mm))) < DeltaLatmax && ...
                            abs(BpL.lon(m)-Tk(tnL).nest.lon(length(mm))) < DeltaLonmax
                        BpL.trkd(m)=1;
                        tnum(tnL,2)=length(mm);   %how many track elements in this track
                        tnum(tnL,2)=tnum(tnL,2)+1; % bump up the loc counter
                        tnum(tnL,length(mm)+3)=m; % fill in this loc index at the end of the row
                        mm=tnum(tnL,3:2+tnum(tnL,2)); % pull new location indices
                        ntc=tnum(tnL,1); % number of this track
                        Tk(tnum(ntc,1)).trnum = ntc;
                        Tk(tnum(ntc,1)).nest = BpL(mm,:);
                        break % loc tracked, added to previous track
                    end
                else % if this track (tnum row) has no elements yet
                    if BpL.trkd(m)==0 && tnum(tnL,2)==0  %this element not already tracked
                        BpL.trkd(m)=1;  % set this loc as TRACKED trkd = 1
                        tnum(tnL,2)=1;  % mark loc counter to 1 for this track row
                        tnum(tnL,3)=m;  % ID the first element of this track by its location index
                        mm=tnum(tnL,3:2+tnum(tnL,2)); % pull location indices for each element in this track
                        ntc=tnum(tnL,1); % pull the number of this track
                        % and add this location's info to the nest for that
                        % track number
                        Tk(tnum(ntc,1)).trnum = ntc;
                        Tk(tnum(ntc,1)).nest = BpL(mm,:);
                        break % loc tracked, new track
                    end
                end
            end % magic number
        end % if is within reasonable range
    end % if hasn't been tracked and meets criteria
end % m - all locations


%FILTER tracks on the minimum number of elements to be a valid track
cnt=0;
tvcnt=0;
% minNumEle=input('enter min num of elements for valid track  = ');
%this loop checks the total num tracks and filters to those with a min num
%of element - results termed valid tracks (vTk structure of structures)
for kk=1:length(Tk)
    if size(Tk(kk).nest,1)< minNumEle
        cnt=cnt+1;
    else
        tvcnt=tvcnt+1;
        vTk(tvcnt)=Tk(kk);
        vTk(tvcnt).trnum=tvcnt;
    end
end
valTkCnt=tvcnt;
% cd(RunPath);
clear tnum;
TrackStats.numValidTks=tvcnt;
TrackStats.numLocs=loops;
TrackStats.numTotTks=length(Tk);

% calculate Inter-Call-Intervals and distance between valid posits & est.
% speed for valid tracks (vTk)
for ntrk=1:tvcnt
    clear ICI ICIt ICIcor ICItcor spdICI latc lonc;
    icnt=0;
    cumDist=0;
    for jk=1:height(vTk(ntrk).nest)-1
        ICI(jk)=vTk(ntrk).nest.tim(jk+1)-vTk(ntrk).nest.tim(jk);    %intervals between calls
        ICIt(jk)=vTk(ntrk).nest.tim(jk+1)-vTk(ntrk).nest.tim(1);    %times of calls relative to track start
        if ICI(jk) >6  %&& jk>1 %this does away with possible multipath localizations with a delta T of < 6 sec
            icnt=icnt+1;
            ICIcor(icnt)=ICI(jk);
            ICItcor(icnt)=ICIt(jk);
            latc(icnt)=vTk(ntrk).nest.lat(jk);
            lonc(icnt)=vTk(ntrk).nest.lon(jk);
        end
    end
    for jj=1:icnt-1;
        lat1=latc(jj);    %vTk(ntrk).nest(jk).lat;
        lon1=lonc(jj);    %vTk(ntrk).nest(jk).lon;
        lat2=latc(jj+1);  %vTk(ntrk).nest(jk+1).lat;
        lon2=lonc(jj+1);  %vTk(ntrk).nest(jk+1).lon;
        %this function converts lat,lon to x, y
        [x1, y1, x2, y2]=latlon2utmConversion(lat1, lon1, lat2, lon2);
        spdICI(jj)=((x2-x1)^2+(y2-y1)^2)^0.5/(ICIcor(jj)); %speed in m/sec, need to check 4 quadrants
        cumDist=cumDist+((x2-x1)^2+(y2-y1)^2)^0.5;
    end
    %create vTkICI structre with derived information
    vTkICI(ntrk).ICI=ICI;
    vTkICI(ntrk).ICIt=ICIt;
    vTkICI(ntrk).ICIcor=ICIcor;
    vTkICI(ntrk).ICItcor=ICItcor;
    vTkICI(ntrk).spdICI=spdICI;
    vTkICI(ntrk).latc=latc;
    vTkICI(ntrk).lonc=lonc;
    vTk(ntrk).minNumEle=minNumEle;
    vTk(ntrk).minNumPh=minNumPh;
    vTk(ntrk).minLS= maxLS;
    vTk(ntrk).ICIcorMean=mean(ICIcor); vTk(ntrk).ICIcorSD=std(ICIcor);
    vTk(ntrk).ICIcorMax=max(ICIcor); vTk(ntrk).ICIcorMin=min(ICIcor);
    vTk(ntrk).cumDist=cumDist;
    vTk(ntrk).spdMean=mean(spdICI); vTk(ntrk).spdSD=std(spdICI);
    vTk(ntrk).spdMax=max(spdICI); vTk(ntrk).spdMin=min(spdICI);
%     vTk(ntrk).filename=fname;
end
% cd(RunPath);

end
