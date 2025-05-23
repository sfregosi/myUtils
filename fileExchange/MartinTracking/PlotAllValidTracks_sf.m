function [vTk, startTim,endTim]=PlotAllValidTracks_sf(place, phInfo, Indat, vTk);

%function to plot all tracks generated by the PAM tracking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PLOT ALL TRACKS - ONE FIG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scrsz=get(0,'ScreenSize');      %set up figure for about correct lat/lon dimensions
figure('Position',[scrsz(3)/10, scrsz(4)/10, scrsz(3)/2, scrsz(4)/1.5]);
if place ==1
    axis([-160.35 -159.5 21.9 23 ]);  %PMRF
elseif place == 2
    axis([-119.35 -118.5 32.6 33.2 ]);  %SCORE
end

% sf addition 9/1/16 - plot the phones
hold on
if ~isempty(phInfo);
scatter(phInfo(:,3),phInfo(:,2),2,'filled');
end
% *****

if place==3
    axis([-160.35 -159.5 21.9 23 ]);  %use PMRF area as test - no phone locations available
str=sprintf('Number of valid tracks: %u', length(vTk));
title (str);
end
tvcnt=length(vTk); 
% MORE BASIC JUST PLOT ALL WITH DIFFERENT SYMBOLS
for valTrk = 1:tvcnt
    scatter(vTk(valTrk).nest.lon(:),vTk(valTrk).nest.lat)

% STEVES CODE TO PLOT THROUGH TIME
startTim=Indat(1).tim;
endTim=Indat(length(Indat)).tim;
timeStep=6000;   %time step for plotting in seconds
for timer=startTim:timeStep:endTim
    st=timer;
    et=timer+timeStep; 
    for valTrk=1:tvcnt
        for nn=1:length(vTk(valTrk).nest);
            if ( ((vTk(valTrk).nest(nn).tim) >= st) && ((vTk(valTrk).nest(nn).tim) < et) )
                        if valTrk==1,linestyle_marker_color='*k';end;
                        if valTrk==2,linestyle_marker_color='+k';end;
                        if valTrk==3,linestyle_marker_color='dm';end;
                        if valTrk==4,linestyle_marker_color='*b';end;
                        if valTrk==5,linestyle_marker_color='dr';end;
                        if valTrk==6,linestyle_marker_color='>k';end;
                        if valTrk==7,linestyle_marker_color='<m';end;
                        if valTrk==8,linestyle_marker_color='ob';end;
                        if valTrk==9,linestyle_marker_color='sr';end;
                        if valTrk==10,linestyle_marker_color='>k';end;
                        if valTrk==11,linestyle_marker_color='^m';end;
                        if valTrk==12,linestyle_marker_color='vb';end;
                        if valTrk==13,linestyle_marker_color='pr';end;
                        if valTrk==14,linestyle_marker_color='hk';end;
                        if valTrk==15,linestyle_marker_color='xm';end;
                        pause(.01); %pause for stepping through plots or delaying longer per update
                        plot(vTk(valTrk).nest(nn).lon, vTk(valTrk).nest(nn).lat, linestyle_marker_color);
                        xlabel(timer);  %x axis label provides the relative time in seconds
                        ylabel(tvcnt);  %y axis label provides the number of valid tracks generated (met criteria)
            end
        end
    end
end
strs=sprintf('# valid tracks: %u',length(vTk));

end