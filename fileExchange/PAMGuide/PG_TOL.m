% Performs 1/3-octave analysis for PAMGuide.m using the standard filter
% bank method.

% This code accompanies the manuscript: 

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright © 2014 The Authors.

% Authors: Mark P. Johnson and Nathan D. Merchant. The function oct3dsgn by
% Christophe Couvreur is included in this function.

% Last modified 22 Sep 2014

function    [A,fc,CI] = PG_TOL(xbit,S,Fs,N,pref,ifile,lcut,hcut,plottype,tstamp,calib,disppar)

%     [A,fc,CI] = PG_TOL(xbit,S,Fs,N,pref,ifile,lcut,RMS)
%     Compute third octave levels (TOLs) of signal x sampled at fs Hz
%     using multi-rate processing.
%     The third octaves to compute are chosen automatically based on the
%     sampling rate and the key frequency (1kHz by default).
%
%     Return:
%     A is the TOLs in dB re pref for each T second averaging interval.
%        The first row of S is the TOLs for the first averaging interval etc.
%     fc is the center frequency of each third octave in Hz.
%     CI is the lower and upper confidence intervals in dB for each third
%        octave assuming a Gaussian input. The confidence limit is 90%.
%
%     Scaling:
%     The TOLs are scaled so that, if all the signal energy in x is within
%     the frequency range analysed, then sum(10.^(S/10)) == mean(x.^2), assuming a
%     single averaging block. There will be small differences due to the
%     startup condition of the filter but the results should be close.
%
%     Example:
%        x=randn(10000,1);                   % white noise
%        [S,fc,CI] = thirdoctlevs(x,96e3);   % TOL analysis on x
%        % the TOLs should increase by 3dB per octave.
%
%        x=sin(2*pi*1000/96e3*(1:10000)');   % a 1kHz sinewave
%        [S,fc,CI] = thirdoctlevs(x,96e3);   % TOL analysis on x
%        [mean(x.^2) sum(10.^(S/10))]        % compare powers - should both be 0.5
%        
%     markjohnson@st-andrews.ac.uk
%     Based on the octave toolbox by Christophe Couvreur
%     The function oct3dsgn by Christophe Couvreur is included in this
%     function.
%     Last modified: 3 May 2014

if N<Fs
    N = Fs;                 %set N >= 1 s for TOL analysis
end

T = N/Fs;                   %convert N in samples into T in seconds

if lcut < 25,lcut = 25;end  %limit low cut-off frequency to 25 Hz

xold = []; naveold = [];

fkey = 1000 ;                             % ANSI standard key frequency
ord = 3 ;                                 % third octave filter order
ndec = 24 ;                               % length of decimating FIR filter
za = 1.6 ;                                % multiplier on sigma for a 90% confidence interval
nta = floor(log(Fs/3/fkey)/log(2)*3)+1 ;    % number of third octaves above key frequency
ntb = floor(-log(lcut/fkey)/log(2)*3)+1 ; % number of third octaves below key frequency
fc = fkey*10.^((nta:-1:-ntb)'/10);         % center frequencies of the third octaves to analyse, high to low



% design a filter for the top three third octaves
B = zeros(3,2*ord+1) ;
A = zeros(3,2*ord+1) ;

nave = round(T*Fs) ;                      % number of samples to average in the top octave
a = zeros(floor(length(xbit)/nave),length(fc)) ;   % make space for the results
CI = zeros(length(fc),1) ;

for k=1:length(fc),                         % loop for each third octave
   ton = rem(k-1,3)+1 ;                     % find out which filter to use
   [B(ton,:),A(ton,:)] = oct3dsgn(fc(k),Fs,ord);    %make filter
   y = filter(B(ton,:),A(ton,:),xbit) ;      % apply the filter
   [Y,~] = buffer(y,nave,0,'nodelay') ;   % break up the filter output in T-length blocks
   [~,Ycols] = size(Y);             
   if k == 1
        Ycols1 = Ycols;
   elseif Ycols ~= Ycols1       % if decimated x yields different number of T-length blocks
        [B(ton,:),A(ton,:)] = oct3dsgn(fc(k),Fs*2,ord); %keep previous fs
        y = filter(B(ton,:),A(ton,:),xold) ;      % apply the filter
        [Y,~] = buffer(y,naveold,0,'nodelay') ;   % break up the filter output in T-length blocks
   end
   a(:,k) = 10*log10(mean(Y.^2)./(pref^2))-S;        % record the power in each block in dB
   CI(k) = 0.5/sqrt(0.23*fc(k)*nave/Fs) ; % 1/(2sqrt(B*T)), B = (2^(1/6)-2^(-1/6))fc = 0.23fc
   if ton==3 && Ycols == Ycols1,          % after each third TOL, decimate by 2 for the next octave
       xold = xbit;                          % store previous x iteration
       naveold = nave;                    % store previous nave iteration
      if length(xbit)<4*ndec, break, end     % first check that there are enough samples
      xbit = decimate(xbit,2,ndec,'FIR') ;      % do the decimation
      Fs = Fs/2 ;                         % update the sampling rate and number of samples to average
      nave = round(Fs*T) ;
   end

end

a = fliplr(a(:,1:k)) ;        % reorder the results from low to high
fc = flipud(fc(1:k)) ;        % and eliminate any unanalysed third octaves.
CI = flipud(20*log10([max(1-za*CI(1:k),0) 1+za*CI(1:k)])) ;

% Scale relative analyses to 0 dB
if calib == 0
    a = a - max(max(a));
end  

%% Plot data


ttot = length(a(:,1))*T-T;          %total time in seconds
t = 0:T:ttot;                       %time vector in seconds
if ~isempty(tstamp)             %if time stamp provided
    t = tstamp + datenum(0,0,0,0,0,t);
end

if strcmp(plottype,'Time') || strcmp(plottype,'Both')
        %Initialize figure window
        figure(113); set(figure(113),'color','w'); cla; hold off
        surf(t,[fc*10^-0.05;max(fc)*10^0.05],[a a(:,length(a(1,:)))].','edgecolor','none');
        set(gca,'YScale','log','tickdir','out','layer','top','fontname','arial','fontsize',14);
        box on; grid off
        ylim([min(fc)*10^(-1/20) max(fc)*10^(1/20)]);    xlim([min(t) max(t)]);    
        if isempty(tstamp),xlabel('Time [ s ]');else xlabel('Time');end
        ylabel('Frequency [ Hz ]')
        if calib == 1
        ylabel(colorbar,['1/3-octave SPL [ dB re ' num2str(pref) ...
            ' \muPa ]'],'fontname','arial','fontsize',14)
        else
        ylabel(colorbar,'Relative 1/3-octave SPL [ dB ]','fontname','arial','fontsize',14)
        end
        title(['1/3 Octave Analysis of ' ifile '. Window length = ' num2str(T) ' s = ' num2str(N) ' samples.'])
        view(0,90);
        anum = length(a(1,:))*length(a(:,1));
        if ~isempty(tstamp),datetick('x','keeplimits');end
        levvec = sort(reshape(a,anum,1));
        caxis([levvec(round(anum/100)) max(levvec)])
end

%% Construct output array

ra = length(t)+1;   %number of rows in output vector
ca = length(fc)+1;   %number of columns in output vector
A = zeros(ra,ca);
A(2:ra,2:ca) = a;
A(1,2:ca) = fc; A(2:ra,1) = t;

return


function [B,A] = oct3dsgn(Fc,Fs,N); 
% OCT3DSGN  Design of a one-third-octave filter.
%    [B,A] = OCT3DSGN(Fc,Fs,N) designs a digital 1/3-octave filter with 
%    center frequency Fc for sampling frequency Fs. 
%    The filter is designed according to the Order-N specification 
%    of the ANSI S1.1-1986 standard. Default value for N is 3. 
%    Warning: for meaningful design results, center frequency used
%    should preferably be in range Fs/200 < Fc < Fs/5.
%    Usage of the filter: Y = FILTER(B,A,X). 
%
% Abbreviated from the octave toolbox by:
% Author: Christophe Couvreur, Faculte Polytechnique de Mons (Belgium)
%         couvreur@thor.fpms.ac.be
% Last modification: Aug. 25, 1997, 2:00pm.

% References: 
%    [1] ANSI S1.1-1986 (ASA 65-1986): Specifications for
%        Octave-Band and Fractional-Octave-Band Analog and
%        Digital Filters, 1993.

% Design Butterworth 2Nth-order one-third-octave filter 
% Note: BUTTER is based on a bilinear transformation, as suggested in [1]. 
pi = 3.14159265358979;
f1 = Fc/(10^(1/20)); 
f2 = Fc*(10^(1/20)); 
Qr = Fc/(f2-f1); 
Qd = (pi/2/N)/(sin(pi/2/N))*Qr;
alpha = (1 + sqrt(1+4*Qd^2))/2/Qd; 
W1 = Fc/(Fs/2)/alpha; 
W2 = Fc/(Fs/2)*alpha;
[B,A] = butter(N,[W1,W2]);
% oct3dsgn reproduced with permission from Christophe Couvreur. Copyright
% statement for oct3dsgn:

% Copyright (c) 1997, Christophe COUVREUR
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.