% Performs pressure waveform analysis for PAMGuide.m

% This code accompanies the manuscript: 

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright © 2014 The Authors.

% Author: Nathan D. Merchant. Last modified 22 Sep 2014

function [A] = PG_Waveform(xbit,Fs,S,tstamp,calib,disppar)

tic
    if calib == 1
        x = xbit/(10^(S/20));       %apply sensitivity correction factor
                                    % EQUATION 21
    else
        x = xbit;
    end      
    clear xbit
    xl = length(x);                 %length of input
    t = 0:1/Fs:(xl-1)/Fs;           %time vector
    if ~isempty(tstamp)             %if time stamp provided
       t = tstamp + datenum(0,0,0,0,0,t); 
    end
    A = [t.',x];                    %define output array
tock = toc;
if disppar == 1,fprintf([' done in ' num2str(tock) ' s.\n']),end
