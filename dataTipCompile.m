function [output]=dataTipCompile(cursordata)
% function [output]=dataTipCompile(cursordata)
%
% function takes multiple datatips that were exported (by right clicking,
% "export cursor data to workspace") into a single variable (rather than a
% structure) with columns for x/y position
% it does them in reverse order of marking, but sorts to descending order
% of column 1


output=[];
for f=1:length(cursordata);
    output(f,:)=cursordata(f).Position;
end

output=sortrows(output,1);
