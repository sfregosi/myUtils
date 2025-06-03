function [] = xwavAmplitudeCheck(origFile, splitFiles)
%XWAVAMPLITUDECHECK	compare original and split xwav amplitudes
%
%	Syntax:
%		OUTPUT = XWAVAMPLITUDECHECK(INPUT)
%
%	Description:
%		Function to plot a split and non-split xwav to compare amplitudes
%		post-processing and make sure all looks as expected
%	Inputs:
%		origFile 	filename and path of original file (before split)
%       splitFiles  cell array containing filenames (with paths) of split 
%                   files that were made from the original file
%
%	Outputs:
%		figure is created
%
%	Examples:
%       origFile = 'N:\LLHARP\LL039\xwavs_original\LL039_SA_FR04_170317_054747.x.wav';
%       splitFiles = {'N:\LLHARP\LL039\xwavs\LL039_SA_FR04_170317_054747.x.wav'; ...
%                   'N:\LLHARP\LL039\XWAVs\LL039_SA_FR04_170318_073825.x.wav'};
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.9.0.1538559 (R2020b) Update 3
%
%	FirstVersion: 	22 November 2022
%	Updated:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ogSig, ~] = audioread(origFile);
newSig = [];
for f = 1:size(splitFiles,1)
    [sig, ~] = audioread(splitFiles{f});
    newSig = [newSig; sig];
end
clear sig
    
figure;
subplot(211);
plot(ogSig);
title('Original xwav');
clear ogSig;

subplot(212);
plot(newSig);
title('Split xwavs');
clear newSig;

linkaxes;

end