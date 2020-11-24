function [status]=plotIndTkDetails(vTk,vTkICI, tvcnt, phInfo, place, plotN, ICI, ICIcor, ICItcor, spdICI)
%function to plot individual track with details of ICI and est. speed
status=1;
% if trackWhat==1; load vTkMinke ; end;  %issues passing structure to function so just directly load structure
    if (plotN+1)>1 && plotN<(tvcnt+1)
        scrsz=get(0,'ScreenSize');      %set up figure for about correct lat/lon dimension
        figure(plotN+10); H=gcf;
        %set(H,'Position',[100, scrsz(4)/10, scrsz(3)/3, scrsz(4)/2.5]);
        subplot(3, 2, [1 5]), plot(vTk(plotN).nest(1).lon, vTk(plotN).nest(1).lat,'-.k');
        if place ==1, axis([-160.25 -159.6 22 22.85 ]); end;    %PMRF
        if place ==2, axis([-119.35 -118.5 32.6 33.2 ]); end;   %SCORE
        hold on
        for nn=1:length(vTk(plotN).nest);
            hold on
            plot(vTk(plotN).nest(nn).lon, vTk(plotN).nest(nn).lat,'k.-');
            pause(0.05);    %to see time sequencing of tracked localizations
        end
        str=sprintf('Track number: %u',plotN);
        title(str);
        subplot(3,2,2),plot(ICI,'-+k');
        xlabel('localization number')
        ylabel('ICI (sec)')
        hold on
        subplot(3,2,6),plot(ICItcor(1:length(spdICI)), spdICI,'-+k');
        ylabel('speed (m/s)');
        xlabel('rel time');
        hold on
        subplot(3,2,4),plot(ICItcor, ICIcor,'-+k');
        ylabel('auto corrected ICI (sec)');
        xlabel('relative time of localization (sec)');
        hold on
    end
end
       