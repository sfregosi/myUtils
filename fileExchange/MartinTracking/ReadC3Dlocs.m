function [Indat, RunPath, InDir, filenam, pathnam]=ReadC3Dlocs(place, RunPath, trackWhat)
% function to read individual model based localizations text files
% \t delimiter is tab
% EOL is the end of line character sequence
% read characters that match chr btwen brackets %[.....]
%older C3D versions (pre Feb 2014) do NOT have the depth (z) field

% sf additions 9/1/2016
% so I don't have to do the trackWhat part
if nargin<3
    trackWhat = 1;
end

    
%open localization file
[filenam, pathnam]=uigetfile('*.dat', 'Pick the localization file to process ');
InDir=pathnam;
% if trackWhat==1; load TrackParamMinke; end
cd (InDir);

fid=fopen(filenam,'rt');
numLines=0;                 %determine number of lines in the selected Track .dat file
maxLen=3;
while 1                     %go through file first time to get sizes
    tline=fgetl(fid);
    tlinen=strrep(tline, '(',' ');
    tlinen=strrep(tlinen, ')', ' ');
    if tline==-1, break, end
    x=str2num(tlinen);
    len=length(x);
        if len>=maxLen;
            maxLen=len;
        end
    numLines=numLines+1;
end
fseek(fid,0,-1);                %rewind file pointer
x=zeros(numLines,maxLen);       %create array to fit all data 
for k=1:numLines;               %go through file second time to get values and numFields each line
    tline = fgetl(fid);
    tlinen=strrep(tline, '(',' ');
    tlinen=strrep(tlinen, ')', ' ');
    x1=str2num(tlinen);
    numFields(k)=length(x1);
    x(k, 1:length(x1))=x1;
end
fseek(fid, 0, -1);
fclose(fid);

% xS=sortrows(x,1);               %ensure the data is time sorted low to high  
                                    % selene removed to deal with multiyear survey period. 
                                    
    % but still need to get rid of zero rows
    BaseChk = 2;
    xS = x;
    xS(all(x==0,2),:)=[];

% %C.Martin 11Aug15 - ML2014 fgetl adds 0 line after each line, sort puts 0 lines first
% BaseChk=2;  %baseline automated DCL processing version 2 fixed for sample public release
% if xS(1,1)==0       %Check if time for first loc is 0, ML2007 will ignore all this    
     numLines=numLines/2;
%     xRS=xS((numLines+1:numLines*2),1:maxLen);     %Put 2nd half of data in new array
%     clear('xS');
%     xS=xRS;  %xS now size of corresponding TrackFile rather than double amount of rows     
% end

if BaseChk==2
    for k=1:numLines           %now create Indat structure use numFields(k)
        fldCnt=0;
        Indat(k).tim=xS(k,1);
        Indat(k).lat=xS(k,2);
        Indat(k).lon=xS(k,3);
        Indat(k).z=xS(k,4);
        Indat(k).numPh=xS(k,5);
        Indat(k).lse=xS(k,6);
        fldCnt=6+2*xS(k,5);
        for kk=1:Indat(k).numPh
            Indat(k).p(kk)=xS(k, fldCnt-1-2*(Indat(k).numPh-kk));
            Indat(k).pt(kk)=xS(k, fldCnt+-2*(Indat(k).numPh-kk));
        end
        Indat(k).trkd=0;
    end
end

end

