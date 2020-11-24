function clicksTable= PGEvents2Convert(filename,varargin)
%function takes in an Excel file that contains 2 worksheets, "Events" and
%"Clicks" taken from the Pamguard database and based on the user input,
%only selects clicks pertaining to user input. This function is only
%filtering based on eventType.

%Inputs
%filename= the pathname and filename where the Excel document is. Excel
%document is of the OfflineClicks and OfflineEvents tables extracted from 
%SQLite Studio and the tabs have been labeled 'Clicks' and 'Events'
%(respectively)(Make sure you have formatted the time columns!)

%varargin means that the user can choose how many eventTypes to filter for.
%If no filters are applied (no varargin argument), this function just spits
%back the same table (not an optimal use of time)

%If you have one or more filters to apply to the click table, type them
%into the function surrounded by '' and separated by commas. Function will
%take a maximum of 4 filter arguments.

%Annamaria Izzi
%12/15/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%read in the clicks and events from PG
clicks= readtable(filename,'Sheet','Clicks');
rawEvents= readtable(filename,'Sheet','Events');

nEvents= height(rawEvents);
ID= [];
%depending on the number of filters the user puts in, filter the Event data
%such that only the eventTypes the user requests are saved

switch nargin
    case 1
        %extract everything
        ID= rawEvents.Id(:);
    case 2
        %extract only one event type, ie: BEAK
        for x= 1:nEvents
            %if the table matches the user input
            if strcmp(rawEvents.eventType{x},varargin{1})
                %save the ID number
                ID= [ID,rawEvents.Id(x)];
            end
        end
    case 3
        %extract two event types, ie: BEAK, PRBK
        for x= 1:nEvents
            %if the table matches the user input
            if strcmp(rawEvents.eventType{x},varargin{1}) ||...
                    strcmp(rawEvents.eventType{x},varargin{2})
                %save the ID number
                ID= [ID,rawEvents.Id(x)];
            end
        end
    case 4
        %extract three event types, ie: BEAK, PRBK, POBK
        for x= 1:nEvents
            %if the table matches the user input
            if strcmp(rawEvents.eventType{x},varargin{1}) ||...
                    strcmp(rawEvents.eventType{x},varargin{2}) ||...
                    strcmp(rawEvents.eventType{x},varargin{3})
                %save the ID number
                ID= [ID,rawEvents.Id(x)];
            end
        end
    case 5
        %extract four event types, ie: BEAK, PRBK, POBK, QUES
        for x= 1:nEvents
            %if the table matches the user input
            if strcmp(rawEvents.eventType{x},varargin{1}) ||...
                    strcmp(rawEvents.eventType{x},varargin{2}) ||...
                    strcmp(rawEvents.eventType{x},varargin{3})||...
                    strcmp(rawEvents.eventType{x},varargin{4})
                %save the ID number
                ID= [ID,rawEvents.Id(x)];
            end
        end
    otherwise
        %error, user should have just extracted everything by this point
        error('Too many inputs, just stick with the function default')
end
        
%now that we know which events the user wants to export, need to find them
%in the click table and push them out of the function as a table
clicksTable= clicks;
clicksTable(:,:)= [];
for i= 1:length(ID)
   indx= find(clicks.EventId==ID(i)); 
   clicksTable= vertcat(clicksTable,clicks(indx,:));
end

%should also include the eventType & Species
eventType= cell(height(clicksTable),1);
species= cell(height(clicksTable),1);

for y= 1:length(ID)
    temp= find(clicksTable.EventId==ID(y));
    eventID= find(rawEvents.Id==ID(y));
    temps(1:length(temp))= rawEvents.eventType(eventID);
    if ismember('Species', rawEvents.Properties.VariableNames)
        sp(1:length(temp))= rawEvents.Species(eventID);
        species(temp)= sp';
    end
    eventType(temp)= temps;
    clear temps sp
end

clicksTable.eventType= eventType;
clicksTable.Species= species;