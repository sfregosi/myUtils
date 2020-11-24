function bingo_gen(numCards,cardsPerPage)

% generates an excel workbook of bingo cards with the specified .dat
% file. Each element in the .dat file should be on a new line with no comma
% delimiter. The excel workbook will have each bingo card on a seperate
% sheet. Maximum cards per page is 2 (default is one per page).
%
% To modify all sheets in excel right click the first sheet and click
% "Select All Sheets". Any modifications made to the first sheet should be
% carried out to the remaining ones. When ready to print, be sure to select
% "Entire Workbook" under the "Print what" section

warning off MATLAB:xlswrite:AddSheet

if nargin==1
    cardsPerPage = 1;
else nargin==2
    cardsPerPage = min(2,cardsPerPage);
end
    

outputFileName = ['bingo_card' datestr(now, '_yyyy-mm-dd_HH_MM_SS') '.xls'];
centerBoxText = 'FREE SPACE';
fid = fopen('bingo_boxes.dat');
list = {};
cont = 1;
while cont
    tline = fgetl(fid);
    if tline ~= -1        
        list{end+1} = tline;
    else
        cont = 0;
    end        
end

numSpots = length(list);
if numSpots>=25
    idxMx = zeros(numSpots,numCards);
    for k = 1:numCards
        idxMx(:,k) = randperm(numSpots);
    end

    idxMx = reshape(idxMx(1:25,:),5,5,numCards);
    emptyCell = cell(5,5);
    for k = 1:cardsPerPage:numCards
        card1 = list(idxMx(:,:,k));
        card1{3,3} = centerBoxText;
        if cardsPerPage~=1
            if k==numCards
                card2 = emptyCell;
            else
                card2 = list(idxMx(:,:,k+1));
                card2{3,3} = centerBoxText;
            end
            xlswrite(outputFileName,[cell(1,5); card1; cell(1,5); card2],(k-1)/2+1);
        else
            xlswrite(outputFileName,[cell(1,5); card1],k);
        end    
    end
else
    disp('Need at least 25 elements to generate bingo card!')
end
