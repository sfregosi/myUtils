function Event= calculateICI_v2(Event,ICImax)

%calculate ICI by using the date field of the click structure. 
%rawICI= all ICIs in order of click number
%filtICI= ICIs < ICImax (in sorted ascending order)
%ICImax in seconds

%Annamaria Izzi
%2/15/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for e= 1:length(Event)
    ICI= zeros(length(Event(e).Clicks)-1,1)-9;
    for c= 1:length(Event(e).Clicks)-1
        clicka= Event(e).Clicks(c).date;
        clickb= Event(e).Clicks(c+1).date;
        diff= clickb-clicka;
        diffvec= datevec(diff);
        ICI(c)= diffvec(5)*60+diffvec(6); %time in seconds
    end
    Event(e).rawICI= ICI;
    
    %filter not possible ICIs out
    sICI= sort(ICI);
    indx= find(sICI>=ICImax,1);
    if ~isempty(indx)
    Event(e).filtICI= sICI(1:indx-1);
    else
        Event(e).filtICI= sICI;
    end
end