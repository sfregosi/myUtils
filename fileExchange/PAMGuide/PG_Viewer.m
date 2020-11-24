% Plots data analysed in PAMGuide.m

% This code accompanies the manuscript: 

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright © 2014 The Authors.

% Note: requires MATLAB Signal Processing and Statistics Toolboxes by
% default. Links to open-source alternatives are provided where possible.

% Author: Nathan D. Merchant. Last modified 22 Sep 2014

function [] = PG_Viewer(A,plottype,ifile,linlog)

aid = A(1,1);
straid = num2str(aid);
tstampid = str2double(straid(1));
enviid = str2double(straid(2));
calibid = str2double(straid(3));
atypeid = str2double(straid(4));
switch tstampid,case 1,tstamp = 1;case 2,tstamp = [];end
switch enviid,case 1,pref = 20;case 2,pref = 1;end
switch calibid,case 1,calib = 1;case 2,calib = 0;end
switch atypeid
    case 1,atype = 'PSD';
    case 2,atype = 'PowerSpec';
    case 3,atype = 'TOLf';
    case 4,atype = 'Broadband';
    case 5,atype = 'Waveform';
    case 6,atype = 'TOL';
end

[ra,ca] = size(A);
if ~strcmp(atype,'Broadband') && ~strcmp(atype,'Waveform')
    t = A(2:ra,1);
    f = A(1,2:ca);
    fint = f(3) - f(2);
    A = A(2:ra,2:ca);
else
    t = A(2:ra,1);
    A = A(2:ra,2);    
end


%% Time-domain plot

if strcmp(plottype,'Time') || strcmp(plottype,'Both') %if time plot selected
fprintf('Plotting...')
tic

% Initialize figure window
figure(111); clf; set(figure(111),'color','w'); hold off;

% Plot data
switch atype
    case {'PSD','PowerSpec'}
        surf(t,[f-fint/2 max(f)+fint/2],[A.';A(:,ca-1).'],'EdgeColor','none');
        if linlog == 0,set(gca,'YScale','log');elseif linlog == 1,set(gca,'YScale','lin');end
        set(gca,'tickdir','out','layer','top','fontname',...
            'arial','fontsize',14);
        ylim([min(f)-fint/2 max(f)+fint/2]);    xlim([min(t) max(t)]);
        if isempty(tstamp),xlabel('Time [ s ]');else xlabel('Time');end
        ylabel('Frequency [ Hz ]')
            switch atype
                case 'PSD'
                    if calib == 1
        ylabel(colorbar,['PSD [ dB re ' num2str(pref) ' \muP'...
            'a^2 Hz^-^1 ]'],'fontname','arial','fontsize',14)
                    else
        ylabel(colorbar,'Relative PSD [ dB ]','fontname','arial','fontsize',14)
                    end
                case 'PowerSpec'
                    if calib == 1
                            ylabel(colorbar,['Power Spectrum [ dB re ' num2str(pref) ' \muP'...
            'a ]'],'fontname','arial','fontsize',14)
                    else
        ylabel(colorbar,'Relative power spectrum [ dB ]','fontname','arial','fontsize',14)
                    end
            end
        title(['Spectrogram of ' ifile],'interpreter','none')
        view(0,90)
        levvec = sort(reshape(A,(ra-1)*(ca-1),1));
        caxis([levvec(round(length(levvec)/100)) max(levvec(levvec<Inf))])
        if ~isempty(tstamp),datetick('x','keeplimits');end
    case 'Broadband'
        plot(t,A);
        set(gca,'tickdir','out','layer','top','fontname','arial',...
            'fontsize',14);
        xlim([min(t) max(t)]);
        if isempty(tstamp),xlabel('Time [ s ]');else xlabel('Time');end
        if calib == 1
            ylabel(['SPL [ dB re ' num2str(pref) ' \muPa ]'])
        else
            ylabel('Relative SPL [ dB ]')
        end
        title(['Broadband SPL of ' ifile],'interpreter','none')
        if ~isempty(tstamp),datetick('x','keeplimits');end
    case {'TOLf';'TOL'}
        surf(t,[f*10^-0.05 max(f)*10^0.5],[A.';A(:,ca-1).'],'EdgeColor','none');
        set(gca,'YScale','log','tickdir','out','layer','top','fontname',...
            'arial','fontsize',14);
        grid off; box on;
        ylim([min(f)*10^-0.05 max(f)*10^0.05]);    xlim([min(t) max(t)]);    
        if isempty(tstamp),xlabel('Time [ s ]');else xlabel('Time');end
        ylabel('Frequency [ Hz ]')
        if calib == 1
        ylabel(colorbar,['1/3-octave SPL [ dB re ' num2str(pref) ...
            ' \muPa ]'],'fontname','arial','fontsize',14)
        else
        ylabel(colorbar,'Relative 1/3-octave SPL [ dB ]','fontname','arial','fontsize',14)
        end
        title(['1/3 Octave Analysis of ' ifile],'interpreter','none')
        view(0,90);
        levvec = sort(reshape(A,(ra-1)*(ca-1),1));
        caxis([levvec(round(length(levvec)/100)) max(levvec(levvec<Inf))])
        if ~isempty(tstamp),datetick('x','keeplimits');end
    case 'Waveform'
        plot(t,A);                      %plot waveform
        set(gca,'tickdir','out','layer','top','fontname','arial','fontsize',14)
                                        %format axes
        if isempty(tstamp),xlabel('Time [ s ]');else xlabel('Time');end
                                        %label x-axis
        if calib == 1
            ylabel('Pressure [ \muPa ]')    %label x-axis
        else
            ylabel('Relative pressure')
        end
        title(['Pressure waveform of ' ifile],'Interpreter','none')
                                        %add title
        xlim([min(t) max(t)])           %set x-axis limits
        ylim([-max(abs(ylim))*1.1 max(abs(ylim))*1.1])
        if ~isempty(tstamp),datetick('x','keeplimits');end
end
grid off,box on
tock = toc;
fprintf([' done in ' num2str(tock) ' s.\n'])
end

%% Statistics plot

if strcmp(plottype,'Stats') || strcmp(plottype,'Both') && ~strcmp(atype,'Waveform')
tic
fprintf('Computing noise level statistics...')

M = ra-1;

%% Compute stats

%EQUATION 18
RMSlevel = 10*log10(mean(10.^(A/10))); %calculate RMS Level

p = prctile(A,1:99).';                %prctile is in the MATLAB Statistics Toolbox. For those without this toolbox, an alternative (to be placed in same folder as PAMGuide.m) can be downloaded here: http://users.powernet.co.uk/kienzle/octave/matcompat/scripts/statistics/prctile.m  


mindB = floor(min(min(A(A>-Inf)))/10)*10;
                        %minimum dB level rounded down to nearest 10
maxdB = ceil(max(max(A(A<Inf)))/10)*10;
                        %maximum dB level rounded up to nearest 10

% Compute SPD if more than 1000 data points in time domain

if ~strcmp(atype,'Broadband') && M>1000

hind = 0.1;             %histogram bin width for probability densities (PD)
dbvec = mindB:hind:maxdB;
                        %dB values at which to calculate empirical PD




%EQUATION 19

d = hist(A,dbvec)/(hind*(M));         %SPD array

d(d == 0) = NaN;                        %suppress plotting of empty hist bins
nf = length(f);
d = [d d(:,nf)];                        %add dummy column for highest frequency

switch atype
    case {'PSD';'PowerSpec'}           %axis array for SPD pcolor plot
        [X,Y] = meshgrid([f,f(nf)]-fint/2,dbvec);
    case {'TOL';'TOLf'} 
        [X,Y] = meshgrid([f,f(nf)*10^0.05]*10^-0.05,dbvec);
end
end

tock = toc;

fprintf([' done in ' num2str(tock) ' s.\n'])

if strcmp(atype,'Broadband')
    RMSlev = 10*log10(mean(10.^(A./10)));
    medlev = 10*log10(median(10.^(A./10)));
    modelev = mode(round(10*A)./10);
    if calib == 1
        fprintf(['\nRMS level (mean SPL) = ' sprintf('%.1f',RMSlev) ' dB re ' num2str(pref) ' uPa \n'])
        fprintf(['Median SPL = ' sprintf('%.1f',medlev) ' dB re ' num2str(pref) ' uPa \n'])
        fprintf(['Mode SPL = ' sprintf('%.1f',modelev) ' dB re ' num2str(pref) ' uPa \n'])
    else
        fprintf(['\nRelative normalised RMS SPL (mean SPL) = ' sprintf('%.1f',RMSlev) ' dB\n'])
        fprintf(['Relative normalised median SPL = ' sprintf('%.1f',medlev) ' dB\n'])
        fprintf(['Relative normalised mode SPL = ' sprintf('%.1f',modelev) ' dB\n'])
    end
   
    tind = t(3)-t(2);
    SEL = 10*log10(tind*sum(10.^(A./10)));
    if calib == 1
        fprintf(['SEL = ' sprintf('%.1f',SEL) ' dB re ' num2str(pref) ' uPa^2 s. Note: for SEL measurements, set window length to 1 s and window overlap to 0 percent.\n\n'])
    else
        fprintf(['Relative normalised SEL = ' sprintf('%.1f',SEL) ' dB. Note: for SEL measurements, set window length to 1 s and window overlap to 0 percent.\n\n'])
    end
end


%% Plot

fprintf('Plotting...')

tic

figure(112),clf                             %initialise figure
set(figure(112),'color','w')
hold off

if ~strcmp(atype,'Broadband')
if linlog == 0
    if M>1000
            set(gca,'XScale','log')
g = pcolor(X,Y,d);                      %SPD
set(g,'LineStyle','none')
colorbar
hold on
    end 
semilogx(f,p(:,99),'k','linewidth',2)   %percentiles
hold on
semilogx(f,p(:,95),'color',[0.1 0.1 0.1],'linewidth',2)
semilogx(f,p(:,50),'color',[0.2 0.2 0.2],'linewidth',2)
semilogx(f,p(:,5),'color',[0.3 0.3 0.3],'linewidth',2)
semilogx(f,p(:,1),'color',[0.4 0.4 0.4],'linewidth',2)

semilogx(f,RMSlevel,'m','linewidth',2)   %RMS Level
set(gca,'XScale','log','TickDir','out','layer','top','fontsize',14,'fontname','Arial')
elseif linlog == 1
    if M>1000
            set(gca,'XScale','lin')
g = pcolor(X,Y,d);                      %SPD
set(g,'LineStyle','none')
colorbar
hold on
    end 
plot(f,p(:,99),'k','linewidth',2)   %percentiles
hold on
plot(f,p(:,95),'color',[0.1 0.1 0.1],'linewidth',2)
plot(f,p(:,50),'color',[0.2 0.2 0.2],'linewidth',2)
plot(f,p(:,5),'color',[0.3 0.3 0.3],'linewidth',2)
plot(f,p(:,1),'color',[0.4 0.4 0.4],'linewidth',2)

plot(f,RMSlevel,'m','linewidth',2)   %RMS level
set(gca,'TickDir','out','layer','top','fontsize',14,'fontname','Arial')
end

title(['Noise level statistics of ' ifile],'interpreter','none')
xlabel('Frequency [ Hz ]')
switch atype
    case 'PSD'
        if calib == 1
            ylabel(['PSD [ dB re ' num2str(pref) ' \muPa^2 Hz^-^1 ]'])
        else
            ylabel('Relative PSD [ dB ]')
        end
    case 'PowerSpec'
        if calib == 1
            ylabel(['Power spectrum [ dB re ' num2str(pref) ' \muPa ]'])
        else
            ylabel('Relative power spectrum [ dB ]')
        end
    case {'TOL';'TOLf'}
        if calib == 1
            ylabel(['1/3-octave SPL [ dB re ' num2str(pref) ' \muPa ]'])
        else
            ylabel('Relative 1/3-octave SPL [ dB ]')            
        end
end



if ~strcmp(atype,'Broadband') && M>1000
caxis([0 0.05])
ylabel(colorbar,'Empirical Probability Density','fontsize',14,'fontname','Arial')
legend('SPD','99%','95%','50%','5%','1%','RMS Level','location','southwest')
else
    legend('99%','95%','50%','5%','1%','RMS Level','location','southwest')
end

ylim([mindB maxdB])
xlim([min(f) max(f)])
else
   plot(prctile(A,0:100).',[0:100]./100,'k')
    hold on
   plot([RMSlev RMSlev],[0 1],'m')
   plot([medlev medlev],[0 1],'g')
   plot([modelev modelev],[0 1],'b')
   
   ylabel('Cumulative Distribution Function')
   if calib == 1
        xlabel(['Broadband SPL [ dB re ' num2str(pref) '\muPa ]'])
   else
        xlabel('Relative SPL [ dB ]')
   end
   set(gca,'fontsize',14,'fontname','Arial','TickDir','out','layer','top')
   title(['CDF of broadband SPL for ' ifile],'interpreter','none')
   legend('CDF','RMS level','Median','Mode','location','southeast')
end

tock = toc;

    fprintf([' done in ' num2str(tock) ' s.\n'])
if ~strcmp(atype,'Broadband') && M<1000
    disp(['Too few time segments (M = ' num2str(M) ', i.e. <1000) for S'...
    'PD analysis: for SPD, use a longer file or shorter time segment le'...
    'ngth (N).'])
end


end