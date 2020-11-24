function [algorithmInfo] = algorithminfo_str2mat(algorithmstr)
%ALGORITHMINFOSTR2MAT Converts a click train detector algorihm string to a
%struct
%   [ALGORITHMINFO] = ALGORITHMINFO_STR2MAT(ALGORITHMSTR) converts a
%   ALGORITHMSTR into a struct ALGORITHMINFO struct.

% split the classifier
algorithminfosplit = split(algorithmstr,'--');

% the classifier split
for i=1:length(algorithminfosplit)
    if (contains(algorithminfosplit{i}, '{'))
        algorithmInfo(i) = jsondecode(algorithminfosplit{i});
    end
end

end

