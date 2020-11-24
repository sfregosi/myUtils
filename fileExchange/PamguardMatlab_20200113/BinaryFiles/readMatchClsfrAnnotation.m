function [data] = readMatchClsfrAnnotation(fid, anId, anLength, fileInfo, anVersion)
%READMATCHCLSFRANNOTATION Read annotaitons from the matched click
%classifier. 
%   The matched clcik classifier annotates click detections with a
%   threshold, matchciorr and rejectcorr value. The threshold value is used
%   in the binary classification process. If it exceeds a hard value the the click is classified with the set type. The matchcorr and rejectcorr values are simple the correlation values of the 
%   the match and reject templates with the click repsectively. 

%read the threshold value. This is the test for the binary classifier i.e.
%does this value exceed a certain threshold. 
threshold = fread(fid, 1, 'double');

%the maximum correlation between the match template and the click 
matchcorr = fread(fid, 1, 'double');

%the max correlation value between the reject template and the click. 
rejectcorr = fread(fid, 1, 'double');

data=[threshold, matchcorr, rejectcorr]; 

end

