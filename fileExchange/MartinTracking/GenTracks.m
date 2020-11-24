function [vTk, vTkICI, TrackStats, tvcnt, ICI,ICIcor, ICIt, ICItcor, spdICI]=GenTracks(InDir, DeltaTmax, DeltaLatmax, DeltaLonmax, RunPath, filenam);
% function to track localizations using Indat
cd (InDir)
% if trackWhat==1; % for tracking minke load the input data
load(['Indat_' filenam(1:end-4)]); %IndatMinke;
fn=pwd; %info to know what data this track is for
% end
cnt=0;  %initialize variables
trkcntr=0;
loops=length(Indat);
tnum=zeros(loops,64);   %make tnum array track # (max length(Indat)by 64 (max num phones +2
for p=1:loops;
    tnum(p,1)=p;    %first element of each row is the track number
end
%prompt to enter the minimum number of hydrophones used in each
%localization and the maximum Least square for valid localizaitons (often
%limited by the automatic detection process in previous processing
%steps)
minNumPh=input('enter min num of hydrophones in each localization (>4)   = ');
minLS=input('enter the min LS for a loc to be valid, e.g. 0.1 s    =  ');
%this looping creates tracks which employ ALL localizations (e.g. single
%element tracks possible here)
for m=1:loops
    if (Indat(m).trkd==0) && (Indat(m).numPh>=minNumPh) && Indat(m).lse<=minLS
        % below line is for PMRF
        %         if (ge(Indat(m).lat,22.208)) && (le(Indat(m).lat,22.843)) && (ge(Indat(m).lon,-160.221)) && (le(Indat(m).lon,-159.69))  %C.Martin added 19 Aug 2015 sort out locs outside of coord boundry
        % sf modified for SCORE - 9/1/2016
        if (ge(Indat(m).lat,32.6)) && (le(Indat(m).lat,33.2)) && (ge(Indat(m).lon,-119.35)) && (le(Indat(m).lon,-118.5))  
            
            %test for first non zero track
            for tnL=1:999   %magic number MAX number of tracks 999 includes single element tracks!!
                if Indat(m).trkd==0 && tnum(tnL,2)>0;   %this element NOT tracked yet but the track has elements
                    mm=tnum(tnL,3:2+tnum(tnL,2));   % keeping record of what loc #'s are in a track
                    if ((Indat(m).tim-Tk(tnL).nest(length(mm)).tim) <= DeltaTmax && abs(Indat(m).lat-Tk(tnL).nest(length(mm)).lat)< DeltaLatmax && abs(Indat(m).lon-Tk(tnL).nest(length(mm)).lon)<DeltaLonmax )
                        Indat(m).trkd=1;
                        tnum(tnL,2)=length(mm);   %how many track elements in this track
                        tnum(tnL,2)=tnum(tnL,2)+1;
                        tnum(tnL,length(mm)+3)=m;
                        mm=tnum(tnL,3:2+tnum(tnL,2));
                        ntc=tnum(tnL,1);
                        Tk(tnum(ntc,1))=struct('trnum', ntc,'nest', struct(Indat(mm)));  %was tnum(1,1) changed to ntc
                        break
                    end
                else
                    if Indat(m).trkd==0 && tnum(tnL,2)==0;  %this element not already tracked
                        Indat(m).trkd=1;    %set m trkd =1
                        tnum(tnL,2)=1;      %ser trkd element cntr=1
                        tnum(tnL,3)=m;      %set m of first element in trk=m
                        mm=tnum(tnL,3:2+tnum(tnL,2));
                        ntc=tnum(tnL,1);
                        Tk(tnum(ntc,1))=struct('trnum', ntc,'nest', struct(Indat(mm))); %was tnum(1,1) changed to ntc
                        break
                    end
                end
            end
        end
    end
end
%FILTER tracks on the minimum number of elements to be a valid track
cnt=0;
tvcnt=0;
minNumEle=input('enter min num of elements for valid track  = ');
%this loop checks the total num tracks and filters to those with a min num
%of element - results termed valid tracks (vTk structure of structures)
for kk=1:length(Tk)
    if size(Tk(kk).nest,2)< minNumEle
        cnt=cnt+1;
    else
        tvcnt=tvcnt+1;
        vTk(tvcnt)=Tk(kk);
        vTk(tvcnt).trnum=tvcnt;
    end
end
valTkCnt=tvcnt;
cd(RunPath);
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
    for jk=1:length(vTk(ntrk).nest)-1
        ICI(jk)=vTk(ntrk).nest(jk+1).tim-vTk(ntrk).nest(jk).tim;    %intervals between calls
        ICIt(jk)=vTk(ntrk).nest(jk+1).tim-vTk(ntrk).nest(1).tim;    %times of calls relative to track start
        if ICI(jk) >6  %&& jk>1 %this does away with possible multipath localizations with a delta T of < 6 sec
            icnt=icnt+1;
            ICIcor(icnt)=ICI(jk);
            ICItcor(icnt)=ICIt(jk);
            latc(icnt)=vTk(ntrk).nest(jk).lat;
            lonc(icnt)=vTk(ntrk).nest(jk).lon;
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
    vTk(ntrk).minLS= minLS;
    vTk(ntrk).ICIcorMean=mean(ICIcor); vTk(ntrk).ICIcorSD=std(ICIcor);
    vTk(ntrk).ICIcorMax=max(ICIcor); vTk(ntrk).ICIcorMin=min(ICIcor);
    vTk(ntrk).cumDist=cumDist;
    vTk(ntrk).spdMean=mean(spdICI); vTk(ntrk).spdSD=std(spdICI);
    vTk(ntrk).spdMax=max(spdICI); vTk(ntrk).spdMin=min(spdICI);
    vTk(ntrk).filename=fn;
end
cd(RunPath);

end
