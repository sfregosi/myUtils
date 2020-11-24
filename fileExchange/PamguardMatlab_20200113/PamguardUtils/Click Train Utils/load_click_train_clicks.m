function [clicktrains] = load_click_train_clicks(sqlLitedB, binaryFolder, varargin)
%   LOAD_CLICK_TRAIN_CLICKS load clicks from event database.
%   CLICKTRAINS = LOAD_CLICK_TRAIN_CLICKS(SQLLITEDB, BINARYFOLDER) loads all
%   clicks trains from a PAMGuard database. Only compatible with PAMGuard 2+
%   CLICKTRAINS is a structure with each element an individual click trains.
%   Each clicktrain contains a an array of click structures.
%
% CLICKTRAINS = LOAD_CLICK_TRAIN_CLICKS(SQLLITEDB, BINARYFOLDER, VARARGIN)
% adds additional arguments. These are:
%
% * 'timerange', [STARTDATE ENDDATE] is the start and end time where click
% * ITEM2
%
% trains that overalap within the time ranges are included.

modulename = 'Click_Train_Detector';
startime = -inf;
endtime = inf;

if nargin<2
% sqlLitedB='E:\Google Drive\SMRU_research\Alfa 2019\2019_Sitka_sperm_whale\Surveys_all\surveys_Alaska_all.sqlite3';
sqlLitedB='E:\Google Drive\SMRU_research\Click_Train_Detector\Harbour_Porpoise\Pamguard_examples\GillNet_ST4Chan_Example\st4c_gilllnet_Cornwall_1678032921_AK580_H3_clk_train.sqlite3';
binaryFolder = 'E:\Google Drive\SMRU_research\Click_Train_Detector\Harbour_Porpoise\annotated_data\Binary\';
end

timeRange = [-Inf +Inf];
iArg = 0;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'timerange'
            iArg = iArg + 1;
            %            timeRange = dateNumToMillis(varargin{iArg});
            timeRange = varargin{iArg};
            startime =   timeRange(1);
            endtime = timeRange(2);
    end
end

% if nargin < 3
%     startDate  = 0;
% end
%
% if nargin < 4
%     endDate = datenum('1 Jan 2099');
% end


%% first read the event table data from the database.
% conn = sqlite(sqlLite_dB,'readonly');
conn = sqlitedatabase(sqlLitedB);

setdbprefs('DataReturnFormat','cellarray') %<- does not work on 2018 above?

sqlquery=['select UTC from ' modulename '_Children'];

% sql query for the click train detector children
sqlquery = ['select Id, UTC, UTCMilliseconds, UID, parentUID, BinaryFile, LongDataName from ' modulename '_Children'];
% curs = fetch(conn, sqlquery, 'DataReturnFormat','cellarray'); % does not work on 2017 below
curs = fetch(conn, sqlquery);

%sql query for the click train detector.
sqlquery = ['select Id, UTC, UTCMilliseconds, EndTime, UID, DataCount, Chi2, median_IDI_sec, mean_IDI_sec, std_IDI_sec, '...
    'algorithm_info, avrg_spectrum_max, avrg_spectrum, classifiers, speciesFlag from ' modulename];
curparent = fetch(conn, sqlquery);

% close the database connected
close(conn)

%% extract data from click train children
fileNames=              curs(:,6);
clicktimes =            curs(:,2);
clickmillis =           cell2mat(curs(:,3));
clicksUID=              cell2mat(curs(:,4));
parentUID=              cell2mat(curs(:,5));

clksdatenum = dBdate2Datenum(clicktimes);

disp(['Found the ' num2str(length(unique(parentUID))) ' unique parent UIDs from click children']);

%% extract data from click trains
clktrainstrttimes =     curparent(:,2);
% clktrainmillis =        cell2mat(curs(:,3));
cltrainendtimes =       curparent(:,4);

%start and end time of the click trains in datenum.
clktrainstrtdatenum = dBdate2Datenum(clktrainstrttimes);
clktrainsenddatenum = dBdate2Datenum(cltrainendtimes);

%find click trains by time first so we know how to filter clicks
index = find((clktrainstrtdatenum>startime |  clktrainsenddatenum>startime) &...
    (clktrainsenddatenum<endtime |  clktrainsenddatenum<endtime));

%now filter so that we only have the click trains we want
if (isempty(index))
    disp('There were no click trains within the specified time period')
    clicktrains =[];
    return;
end

% index=1; %% temp for debugging <- DELETE

% filter out the unwanted click trains.
clktrainstrttimesd=      clktrainstrtdatenum(index);
cltrainendtimesd =       clktrainsenddatenum(index);

minclktime = min(clktrainstrttimesd);
maxlcktime = max(cltrainendtimesd);

clktrainsUID =          cell2mat(curparent(index,5));
clktrains_datacount =   cell2mat(curparent(index,6)); % the number of child detections
clktrainsUID =          cell2mat(curparent(index,5));
clktrains_datacount =   cell2mat(curparent(index,6)); % the number of child detections
clktrains_chi2 =        cell2mat(curparent(index,7)); % chi^2 value of click trains
clktrains_mean_IDI =    cell2mat(curparent(index,9)); % mean IDI value of click trains
clktrains_median_IDI =  cell2mat(curparent(index,8)); % median IDI value of click trains
clktrains_std_IDI =     cell2mat(curparent(index,10)); % std_IDI value of click trains

algorithm_info =        curparent(index,11); % string with algorithm specific info for the click train
avrg_spectrum_max =     cell2mat(curparent(index,12)); % the max value of the click train average
avrg_spectrum =         curparent(index,13); % the click train average spectrum
classifiers =           curparent(index,14); % click classifier information

speciesflag =          cell2mat(curparent(index,15)); % click classifiers.


disp(['Found click ' num2str(length(clktrainsUID)) ' trains']);

% dir sub
d = dirsub(binaryFolder, 'Click_Detector_*.pgdf');

currentfilename = '';
% search efficiently through the binary file folder, only opening the
% binary files that actually need opened.
n=1;
for i=1:length(clicksUID)
    % now search efficiently through the clicks
    if (clksdatenum(i)<minclktime || clksdatenum(i)>maxlcktime)
        continue; % the click is out of range of any click trains
        %(assuming start and end times in database are actually correct).
    end
    
    if strcmp(fileNames{i},currentfilename)
        % the clicks are already loaded...
        ind = clicksFileUIDlist == clicksUID(i);
        clicks(n) = clicksFileList(ind);
        parentUID2(n)=parentUID(i);
        n=n+1;
    else
        % find the file- should not be called that much
        % - will  need to iterate through d
        for j=1:length(d)
            [~, name, ext] =  fileparts(d(j).name);
            %             disp([ num2str(j) ' ' [name ext] ' '  fileNames{i}])
            if strcmp([name ext], strtrim(fileNames{i}))
                %load a new bianry file if needed.
                currentfilename = fileNames{i};
                disp(['i: ' num2str(i) ' Loading: ' name ext])
                clicksFileList = loadPamguardBinaryFile( d(j).name);
                break;
            end
        end
        clicksFileUIDlist=[clicksFileList.UID];
    end
end
% now put everything into a sensible structure which each element is a
% single clicks train.
for i=1:length(clktrainsUID)
    
    % Find the click trains
    disp (['Extracting clicks into click train: ' num2str(i) ' of ' num2str(length(clktrainsUID))]);
    
    clicksintrain = clicks(parentUID2 == clktrainsUID(i));
    
    clicktrains(i).date =           clktrainstrttimesd(i);
    clicktrains(i).UID =            clktrainsUID(i);
    clicktrains(i).chi2 =           clktrains_chi2(i);
    clicktrains(i).datecount =      clktrains_datacount(i);
    clicktrains(i).meanIDI =        clktrains_mean_IDI(i);
    clicktrains(i).medianIDI =      clktrains_median_IDI(i);
    clicktrains(i).stdIDI =         clktrains_std_IDI(i);
    clicktrains(i).clicks =         clicksintrain;
    clicktrains(i).medianIDI =      clktrains_median_IDI(i);
    clicktrains(i).stdIDI =         clktrains_std_IDI(i);
    clicktrains(i).clicks =         clicksintrain;
    
    % Average spectrum
    avrgspectrum = strsplit(avrg_spectrum{i}, ',');
    avrgspectrumnum = zeros(length(avrgspectrum),1);
    n=1;
    for j=1:length(avrgspectrum)
        if (~isempty(avrgspectrum{j}))
            avrgspectrumnum(n) = str2num(avrgspectrum{j});
            n=n+1;
        end
    end
    avrgspectrumnum=avrgspectrumnum(1:n-1);
    avrgspectrumnum = avrgspectrumnum*avrg_spectrum_max(i);
    
    clicktrains(i).averagespectrum = avrgspectrumnum;
    
    % Now the more complex stuff including algorithm information and
    % and classifiers.
    clicktrains(i).classifiers  =   classifier_str2mat(classifiers{i});
    clicktrains(i).algorithminfo =  algorithminfo_str2mat(algorithm_info{i});
    clicktrains(i).speciesflags =   speciesflag(i);
    
end

end

function [dates] = dBdate2Datenum(utcstrings)
%DBDATE2DATENUM converts database date strings to a MATLAB datenumber.
for jj=1:length(utcstrings)
    utcstrings{jj};
    dates(jj) = datenum(utcstrings{jj} , 'yyyy-mm-dd HH:MM:SS.FFF');
end
end