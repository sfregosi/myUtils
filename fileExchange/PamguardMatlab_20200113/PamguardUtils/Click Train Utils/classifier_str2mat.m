function [classifiersinfo] = classifier_str2mat(classiferstr)
%CLASSIFIERSTR2MAT Converts a click train detector classifier string to a
%struct
%   [CLASSIFIER] = CLASSIFIER_STR2MAT(CLASSIFIERSTR) converts a
%   CLASSIFIERSTR into a struct CLASSIFIER struct.

% split the classifier
classifiersplit = split(classiferstr,'--');

% the classifier split
for i=1:length(classifiersplit)
    if (contains(classifiersplit{i}, '{'))
    classifiersinfo(i) = jsondecode(classifiersplit{i});
    end
end

end

