function Event= batchLoadEventClicks2(T)

%TO BE RUN ONLY AFTER RUNNING PGEvents2Convert

%takes the table from PGEvents2Convert and searches the binary files for
%the clicks listed in the table. Function will query the user to navigate
%to the base folder where all the binary dayfolders are stored. Output are
%all the clicks segregated by Event ID into a structure "Event"
    
%Adapted from batchLoadEventClicks

%Annamaria Izzi
%12/15/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get the binaries
binaryBaseFolder= uigetdir('Select the base directory where all the binary dayfolders are stored');

uniID= unique(T.EventId); %get all the unique Event IDs
IDlen= length(uniID);

tic;
disp('Starting conversion...');

for e= 1:IDlen
    %for 1 event
    Event(e).EventID= uniID(e);
    %need to break out the different events for clicks and for binary files
    indx= find(T.EventId== uniID(e));
    %mark down event type
    Event(e).EventType= char(T.eventType(indx(1)));
    %mark down species
    if ~cellfun(@isempty,T.Species(indx(1)))
        Event(e).Species= char(T.Species(indx(1)));
    end
    %mark down number of clicks
    Event(e).nClicks= length(indx);
    
    Event(e).Clicks= loadEventClicks(binaryBaseFolder, T.BinaryFile(indx), T.ClickNo(indx));
    len= length(Event(e).Clicks);
    
    
    %extract angles
    Event(e).clickDegAngle= zeros(len,1)-999;
    counter= 1;
    for i= 1:len
        Event(e).clickDegAngle(counter)= radtodeg(Event(e).Clicks(i).angles);
        %convert 0-360 to PG's -180->180
        if Event(e).clickDegAngle(counter)> 180
            Event(e).clickDegAngle(counter)= Event(e).clickDegAngle(counter)-360; %slant angle ~ horizontal angle
        end
        counter= counter+1;
    end
    
    %let the user know where the script is
    msg= sprintf('Processed %d of %d events',e,IDlen);
    disp(msg)
end

toc


