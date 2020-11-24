function varargout = Xwater(varargin)
% XWATER MATLAB code for Xwater.fig
%      XWATER, by itself, creates a new XWATER or raises the existing
%      singleton*.
%
%      H = XWATER returns the handle to a new XWATER or the handle to
%      the existing singleton*.
%
%      XWATER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XWATER.M with the given input arguments.
%
%      XWATER('Property','Value',...) creates a new XWATER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Xwater_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Xwater_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Xwater

% Last Modified by GUIDE v2.5 13-Jan-2017 15:14:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Xwater_OpeningFcn, ...
                   'gui_OutputFcn',  @Xwater_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Xwater is made visible.
function Xwater_OpeningFcn(hObject, eventdata, handles, varargin)
global Data
handles.output = hObject;
guidata(hObject, handles);
% Data.positioning.soundspeed = 331.4+0.607*str2num(get(handles.temp,'string'));
% set(handles.soundspeed,'string',num2str(round(Data.positioning.soundspeed)))
Data.positioning.mikes = [];
Data.positioning.coords = [];
Data.positioning.pos_chan = [];
Data.sourcelevel.calibration = [];
Data.sourcelevel.SL = [];
set(handles.wait,'visible','off')

% --- Outputs from this function are returned to the command line.
function varargout = Xwater_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function thr_Callback(hObject, eventdata, handles)
global Data
global fs
global sig
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
thr = str2num(get(handles.thr,'string'));
t = (0:length(sig(:,1))-1)/Data.samplerate;

env = abs(sig(:,get(handles.channelselect,'Value')));


axes(handles.axes1)
cla
plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
axis([0 t(end)*1000 0 max(env)])

% --- Executes during object creation, after setting all properties.
function thr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mintime_Callback(hObject, eventdata, handles)
global Data
global sig
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
if maxt < mint
    maxt = mint;
    set(handles.maxtime,'string',num2str(maxt))
end

k =get(handles.channelselect,'Value');
t = (0:length(sig(:,1))-1)/Data.samplerate;
thr = str2num(get(handles.thr,'string'));

axes(handles.axes1);
plot(t*1000,sig(:,k),'b-',[mint mint],[1 -1],'g-',[maxt maxt],[1 -1],'r-');
axis([0 t(end)*1000 -max(abs(sig(:,k)))*1.1 max(abs(sig(:,k)))*1.1])

env = abs(sig(:,k));
axes(handles.axes1);
plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
axis([0 t(end)*1000 0 max(env)])



% --- Executes during object creation, after setting all properties.
function mintime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mintime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxtime_Callback(hObject, eventdata, handles)
global Data
global sig
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
if maxt < mint
    mint = maxt;
    set(handles.mintime,'string',num2str(mint))
end
k =get(handles.channelselect,'Value');
t = (0:length(sig(:,1))-1)/Data.samplerate;
thr = str2num(get(handles.thr,'string'));

axes(handles.axes1);
plot(t*1000,sig(:,k),'b-',[mint mint],[1 -1],'g-',[maxt maxt],[1 -1],'r-');
axis([0 t(end)*1000 -max(abs(sig(:,k)))*1.1 max(abs(sig(:,k)))*1.1])


env = abs(sig(:,k));
axes(handles.axes1);
plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
axis([0 t(end)*1000 0 max(env)])


% --- Executes during object creation, after setting all properties.
function maxtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channelselect.
function channelselect_Callback(hObject, eventdata, handles)
global sig
global Data

% Data.positioning
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
thr = str2num(get(handles.thr,'string'));
t = (0:length(sig(:,1))-1)/Data.samplerate;
for k = 1:length(sig(1,:));
switch get(handles.channelselect,'Value')   
    case k
        if isempty(Data.positioning.pos_chan)
        else
            try
                Data.positioning.pos_chan(k) = [];
                Data.positioning.pos_chan = [k Data.positioning.pos_chan];
            end
        end
        axes(handles.axes1);
        plot(t*1000,sig(:,k),'b-',[mint mint],[1 -1],'g-',[maxt maxt],[1 -1],'r-');
        axis([0 t(end)*1000 -max(abs(sig(:,k)))*1.1 max(abs(sig(:,k)))*1.1])
        
        env = abs(sig(:,k));
        axes(handles.axes1)
        cla
        plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
        axis([0 t(end)*1000 0 max(env)])
    otherwise
end
end


% --- Executes during object creation, after setting all properties.
function channelselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in peakdetection.
function peakdetection_Callback(hObject, eventdata, handles)
global Data
global sig

env = abs(sig(:,get(handles.channelselect,'Value')));


peaktime = peak_detection(env,str2num(get(handles.thr,'String'))...
    ,str2num(get(handles.minipi,'String'))...
    ,Data.samplerate,str2num(get(handles.mintime,'string')),...
    str2num(get(handles.maxtime,'string')));
set(handles.uitable2,'data',round(peaktime'/Data.samplerate*1000))
Data.emissiontime = peaktime;
Data.positioning.center_channel = get(handles.channelselect,'Value');



% --- Executes on button press in arrivaltimes.
function arrivaltimes_Callback(hObject, eventdata, handles)
global xl yl Xl Yl Data sig ax

set(handles.wait,'visible','on')
pause(0.01)
Data.positioning.coords = [];
Data.positioning.peaksample = [];
cwidth = str2num(get(handles.cwidth,'string'))*Data.samplerate/1000;
Data.positioning.cwidth = cwidth;
Data.positioning.soundspeed = str2num(get(handles.soundspeed,'string'));
handles.var = 1:length(Data.emissiontime);
set(handles.callnr,'string', handles.var);
set(handles.callnr,'Value',1);
cz = str2num(get(handles.corrzoom,'string'));

chn = get(handles.channelselect,'value');
for n = 1:length(Data.emissiontime)
    seg = sig(Data.emissiontime(n) - cwidth:Data.emissiontime(n) + 2*cwidth,:);
    Data.positioning.peaksample(:,n) = rcorr(seg,chn,4);
    
end

%Data.positioning.peaksample
seg = sig(Data.emissiontime(1) - cwidth:Data.emissiontime(1) + 2*cwidth,:);

for n = 1:length(sig(1,:))
    
    tloc = Data.positioning.peaksample(chn,1)-Data.positioning.peaksample(n,1);

    subplot(floor(sqrt(length(sig(1,:)))),ceil(sqrt(length(sig(1,:)))),n,'Parent',handles.uipanel1)
    plot(sig(:,n))
    hold on 
    plot([tloc tloc]...
        +Data.emissiontime(1),ylim,'--k')
                
%     plot([Data.positioning.peaksample(n,1) Data.positioning.peaksample(n,1)]...
%         +Data.emissiontime(1),ylim,'--k')
    hold off
    xlim([Data.emissiontime(1)-cwidth Data.emissiontime(1)+cwidth*2])
    
    
    cseg = abs(hilbert(xcorr(seg(:,n),seg(:,chn))));
    loc = length(seg(:,1))+tloc;
%     loc = length(seg(:,1))+Data.positioning.peaksample(n,1);
    
    
    ax(n) = subplot(floor(sqrt(length(sig(1,:)))),ceil(sqrt(length(sig(1,:)))),n,'Parent',handles.uipanel2);
    
    plot(cseg)
    hold on
    plot(loc,max(cseg(loc-10:loc+10)),'or')
    hold off
     xlim([loc-cz loc+cz])
     
    
end

% localization

if isempty(Data.positioning.mikes)
     errordlg('Please load microphone positions')
else

    for n = 1:length(Data.positioning.pos_chan)
        receiverpositions(n,:) = Data.positioning.mikes(Data.positioning.pos_chan(n),:)...
            -Data.positioning.mikes(Data.positioning.pos_chan(1),:);
    end

    for n = 1:length(Data.emissiontime)
        if sum(isnan(Data.positioning.peaksample(:,n))) > 1
            coords(n,:) = NaN;
        else
            coords(n,:) = localization(Data.positioning.peaksample(Data.positioning.pos_chan,n)...
                /Data.samplerate,receiverpositions,Data.positioning.soundspeed,'2d');
        end
    end
    
    coords(find(imag(coords))) = NaN;
    
    for i = 1:length(coords(:,1))
        if sum(isnan(coords(i,:))) > 0
            coords(i,:) = NaN;
        end
    end
    
    for n = 1:length(Data.emissiontime)
        Data.positioning.coords(n,:) = coords(n,:)+Data.positioning.mikes(Data.positioning.pos_chan(1),:); %converts the positions back so microphone 1 is again at 0,0,0
    end
    axes(handles.axes5)
    cla
    plot(Data.positioning.coords(:,2), Data.positioning.coords(:,1),'kx')
    hold on
    plot(Data.positioning.coords(1,2), Data.positioning.coords(1,1),'ob')
    plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,1),'ro','markersize',8)
    plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
        Data.positioning.mikes(Data.positioning.pos_chan(1),1),'ko','markersize',10)
    hold off
    
    axes(handles.axes6)
    cla
    plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx')
    hold on
    plot(Data.positioning.coords(1,2), Data.positioning.coords(1,3),'ob')
    plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
    plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
        Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
    hold off
    set(gca,'xticklabel',[]);
    set(handles.xtag,'Value',1)
    set(handles.numbers,'Value',0)
end
axes(handles.axes5)
xl = xlim;
yl = ylim;
axes(handles.axes6)
Xl = xlim;
Yl = ylim;
set(handles.wait,'visible','off')
    
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function cwidth_Callback(hObject, eventdata, handles)
% hObject    handle to cwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cwidth as text
%        str2double(get(hObject,'String')) returns contents of cwidth as a double


% --- Executes during object creation, after setting all properties.
function cwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function soundspeed_Callback(hObject, eventdata, handles)
% hObject    handle to soundspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of soundspeed as text
%        str2double(get(hObject,'String')) returns contents of soundspeed as a double


% --- Executes during object creation, after setting all properties.
function soundspeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to soundspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function savemoonshine_Callback(hObject, eventdata, handles)
global Data
Data.positioning.peaksample = (Data.positioning.cwidth*3+1) - Data.positioning.peaksample;

if ispref('moonshine_path','analyzed_path')
    [pn] = getpref('moonshine_path','analyzed_path');
else
    pn = './';
end

old_dir = pwd;
try
    cd(pn);
catch
    disp('Your paths variable points to a directory that no longer exists. Please update the paths.');
end

Data.temp = str2num(get(handles.temp,'string'));
Data.humidity = str2num(get(handles.hum,'string'));
N = fieldnames(Data);

for n = 1:length(N)
    if isstruct(Data.(sprintf(N{n})))
        alph(n) = 1;
    else alph(n) = 0;
        
    end
end
seq = [sort(N(find(alph)));sort(N(find(alph == 0)))];
Data = orderfields(Data,seq);
[fname,pname]=uiputfile('*.mat','Save as...');
if ischar(fname); save([pname fname],'Data');end
cd(old_dir);

% --------------------------------------------------------------------
function loadwav_Callback(hObject, eventdata, handles)
global sig
global Data
global fs


if ispref('moonshine_path','wav')
    [pn] = getpref('moonshine_path','wav');
else
    pn = './';
end

old_dir = pwd;
try
    cd(pn);
catch
    disp('Your paths variable points to a directory that no longer exists. Please update the paths.');
end
[name,path]=uigetfile( ...
       {'*.wav;*.WAV', 'All WAV Files (*.wav, *.WAV)'; ...
        '*.*',                   'All Files (*.*)'}, ...
        'Load wav file');
if ischar(name);
    sig = [];
    [sig,fs] = audioread([path name]);
    cd(old_dir);
    t = (0:length(sig(:,1))-1)/fs;
    maxt = t(end)*1000;
    set(handles.maxtime,'string',maxt);

    
    handles.var = 1:length(sig(1,:));
    set(handles.channelselect,'string', handles.var);
    set(handles.channelselect,'Value',1);
%     set(handles.filename,'string',name);
    Data.samplerate = fs;
    Data.wavfile = name;
    
    mint = str2num(get(handles.mintime,'string'));
    maxt = str2num(get(handles.maxtime,'string'));
    thr = str2num(get(handles.thr,'string'));
    env = abs(sig(:,1));
    axes(handles.axes1)
    cla
    plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
    axis([0 t(end)*1000 0 max(env)])
else
    cd(old_dir)
end

% --------------------------------------------------------------------
function loadmikes_Callback(hObject, eventdata, handles)
global Data
if ispref('moonshine_path','mike')
    [pn] = getpref('moonshine_path','mike');
else
    pn = './';
end

old_dir = pwd;
try
    cd(pn);
catch
    disp('Your paths variable points to a directory that no longer exists. Please update the paths.');
end

[name,path]=uigetfile('*.txt','Load Receiver positions');

if ischar(name);
    Data.positioning.mikes = load([path name]);
    cd(old_dir);
    Data.positioning.pos_chan = 1:length(Data.positioning.mikes(:,1));

    chn = get(handles.channelselect,'Value');

    Data.positioning.pos_chan(chn) = [];
    Data.positioning.pos_chan = [chn Data.positioning.pos_chan];

    axes(handles.axes5)
    plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,1),'ro','markersize',8)
    axes(handles.axes6)
    plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
    set(gca,'xticklabel',[]);
    
    % set(handles.specch,'string',num2str((1:length(Data.positioning.mikes(:,1)))'))
else
    cd(old_dir)
end



function minipi_Callback(hObject, eventdata, handles)
% hObject    handle to minipi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minipi as text
%        str2double(get(hObject,'String')) returns contents of minipi as a double


% --- Executes during object creation, after setting all properties.
function minipi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minipi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in callnr.
function callnr_Callback(hObject, eventdata, handles)
global Data
global sig
global ax
set(handles.wait,'visible','on')
axes(handles.axes5)
x_l = xlim;
y_l = ylim;
axes(handles.axes6)
X_l = xlim;
Y_l = ylim;
cwidth = str2num(get(handles.cwidth,'string'))*Data.samplerate/1000;

cz = str2num(get(handles.corrzoom,'string'));

chn = Data.positioning.center_channel;

for k = 1:length(Data.emissiontime);
    switch get(handles.callnr,'Value')   
        case k
            seg = sig(Data.emissiontime(k) - cwidth:Data.emissiontime(k) + 2*cwidth,:);

            for n = 1:length(sig(1,:))
                tloc = Data.positioning.peaksample(chn,k)-Data.positioning.peaksample(n,k);


                subplot(floor(sqrt(length(sig(1,:)))),ceil(sqrt(length(sig(1,:)))),n,'Parent',handles.uipanel1)
                plot(sig(:,n))
                hold on 
                plot([tloc tloc]...
                    +Data.emissiontime(k),ylim,'--k')
                hold off
                xlim([Data.emissiontime(k)-cwidth Data.emissiontime(k)+cwidth*2])

            
                cseg = abs(hilbert(xcorr(seg(:,n),seg(:,chn))));
                loc = length(seg(:,1))+tloc;


                ax(n) = subplot(floor(sqrt(length(sig(1,:)))),ceil(sqrt(length(sig(1,:)))),n,'Parent',handles.uipanel2);
                plot(cseg)
                hold on
                plot(loc,max(cseg(loc-10:loc+10)),'or')
                hold off
                xlim([loc-cz loc+cz])
                
                
                
                
                

            end
        axes(handles.axes5)
        cla
        plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,1),'ro','markersize',8)
        hold on
        plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
            Data.positioning.mikes(Data.positioning.pos_chan(1),1),'ko','markersize',10)
        hold off

        axes(handles.axes6)
        cla
        hold on
        plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
        plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
            Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
        hold off
        
        if get(handles.xtag,'value') == 1

            axes(handles.axes5)
            hold on
            plot(Data.positioning.coords(:,2), Data.positioning.coords(:,1),'kx')
            plot(Data.positioning.coords(k,2), Data.positioning.coords(k,1),'ob')
            hold off

            axes(handles.axes6)
            hold on
            plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx')
            plot(Data.positioning.coords(k,2), Data.positioning.coords(k,3),'ob')
            hold off

            set(gca,'xticklabel',[]);
        else
            axes(handles.axes5)
            hold on
            plot(Data.positioning.coords(:,2), Data.positioning.coords(:,1),'k.')
            for n = 1:length(Data.emissiontime)
                text(Data.positioning.coords(n,2), Data.positioning.coords(n,1),num2str(n))
            end
            text(Data.positioning.coords(k,2), Data.positioning.coords(k,1),num2str(k),'color','b')
            hold off

            axes(handles.axes6)
            hold on
            plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'k.')
            for n = 1:length(Data.emissiontime)
                text(Data.positioning.coords(n,2), Data.positioning.coords(n,3),num2str(n))
            end
            text(Data.positioning.coords(k,2), Data.positioning.coords(k,3),num2str(k),'color','b')
            hold off

            set(gca,'xticklabel',[]);
        end
    end
end

axes(handles.axes5)
xlim(x_l);
ylim(y_l);
axes(handles.axes6)
xlim(X_l);
ylim(Y_l);
set(handles.wait,'visible','off')


% --- Executes during object creation, after setting all properties.
function callnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to callnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
global ax
global sig

% Data.positioning.peaksample
cz = str2num(get(handles.corrzoom,'string'));
[x,y] = ginput(1);
set(handles.wait,'visible','on')
spa = gca;
chnl = find(ax == spa);

callnr = get(handles.callnr,'Value');
mchn = get(handles.channelselect,'Value');
mseg = sig(Data.emissiontime(callnr) - Data.positioning.cwidth:Data.emissiontime(callnr) + 2*Data.positioning.cwidth,mchn);
seg = sig(Data.emissiontime(callnr) - Data.positioning.cwidth:Data.emissiontime(callnr) + 2*Data.positioning.cwidth,chnl);

cseg = abs(hilbert(xcorr(seg,mseg)));
aseg = abs(hilbert(xcorr(mseg,mseg)));
[vpks pks] = findpeaks(cseg);
[V,L] = max(aseg);
[v,l] = min(abs(pks-x));


Data.positioning.peaksample(chnl,callnr) = Data.positioning.cwidth*3 - pks(l);




subplot(floor(sqrt(length(sig(1,:)))),ceil(sqrt(length(sig(1,:)))),chnl,'Parent',handles.uipanel2);
plot(cseg)
hold on
plot(pks(l),vpks(l),'or')
hold off
xlim([pks(l)-cz pks(l)+cz])

for n = 1:length(Data.positioning.pos_chan)
    receiverpositions(n,:) = Data.positioning.mikes(Data.positioning.pos_chan(n),:)...
        -Data.positioning.mikes(Data.positioning.pos_chan(1),:);
end
Data.positioning.coords(callnr,:) = localization(Data.positioning.peaksample(Data.positioning.pos_chan,callnr)...
    /Data.samplerate,receiverpositions,Data.positioning.soundspeed,'2d')+...
    Data.positioning.mikes(Data.positioning.pos_chan(1),:);
axes(handles.axes5)
x_l = xlim;
y_l = ylim;
axes(handles.axes6)
X_l = xlim;
Y_l = ylim;

axes(handles.axes5)
cla
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,1),'ro','markersize',8)
hold on
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
    Data.positioning.mikes(Data.positioning.pos_chan(1),1),'ko','markersize',10)
hold off

axes(handles.axes6)
cla
hold on
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
    Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
hold off
                

if get(handles.xtag,'value') == 1
    axes(handles.axes5)
    hold on
    plot(Data.positioning.coords(:,2), Data.positioning.coords(:,1),'kx')
    plot(Data.positioning.coords(callnr,2), Data.positioning.coords(callnr,1),'ob')
    hold off

    axes(handles.axes6)
    hold on
    plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx')
    plot(Data.positioning.coords(callnr,2), Data.positioning.coords(callnr,3),'ob')
    hold off

    set(gca,'xticklabel',[]);
else
    axes(handles.axes5)
    hold on
    plot(Data.positioning.coords(:,2), Data.positioning.coords(:,1),'k.')
    for n = 1:length(Data.emissiontime)
        text(Data.positioning.coords(n,2), Data.positioning.coords(n,1),num2str(n))
    end
    text(Data.positioning.coords(callnr,2), Data.positioning.coords(callnr,1),num2str(callnr),'color','b')
    hold off

    axes(handles.axes6)
    hold on
    plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'k.')
    for n = 1:length(Data.emissiontime)
        text(Data.positioning.coords(n,2), Data.positioning.coords(n,3),num2str(n))
    end
    text(Data.positioning.coords(callnr,2), Data.positioning.coords(callnr,3),num2str(callnr),'color','b')
    hold off

    set(gca,'xticklabel',[]);
end
axes(handles.axes5)
xlim(x_l);
ylim(y_l);
axes(handles.axes6)
xlim(X_l);
ylim(Y_l);


set(handles.wait,'visible','off')
% --- Executes on button press in xtag.
function xtag_Callback(hObject, eventdata, handles)
global Data

set(handles.numbers,'Value',0)

k = get(handles.callnr,'value');

axes(handles.axes5)
cla
hold on
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,1),'kx')
plot(Data.positioning.coords(k,2), Data.positioning.coords(k,1),'ob')
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,1),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
    Data.positioning.mikes(Data.positioning.pos_chan(1),1),'ko','markersize',10)
hold off

axes(handles.axes6)
cla
hold on
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx')
plot(Data.positioning.coords(k,2), Data.positioning.coords(k,3),'ob')
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
    Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
hold off
set(gca,'xticklabel',[]);






% --- Executes on button press in numbers.
function numbers_Callback(hObject, eventdata, handles)
global Data

set(handles.xtag,'Value',0)

k = get(handles.callnr,'value');

axes(handles.axes5)
cla
hold on
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,1),'b.')
for n = 1:length(Data.emissiontime)
    text(Data.positioning.coords(n,2), Data.positioning.coords(n,1),num2str(n))
end
text(Data.positioning.coords(k,2), Data.positioning.coords(k,1),num2str(k),'color','b')
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,1),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
    Data.positioning.mikes(Data.positioning.pos_chan(1),1),'ko','markersize',10)
hold off

axes(handles.axes6)
cla
hold on
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'b.')
for n = 1:length(Data.emissiontime)
    text(Data.positioning.coords(n,2), Data.positioning.coords(n,3),num2str(n))
end
text(Data.positioning.coords(k,2), Data.positioning.coords(k,3),num2str(k),'color','b')
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),...
    Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
hold off

set(gca,'xticklabel',[]);



function corrzoom_Callback(hObject, eventdata, handles)
global sig
global Data



cz = str2num(get(handles.corrzoom,'string'));

k = get(handles.callnr,'Value');

for n = 1:length(sig(1,:))
    
    ax(n) = subplot(floor(sqrt(length(sig(1,:)))),ceil(sqrt(length(sig(1,:)))),n,'Parent',handles.uipanel2);
    loc = Data.positioning.cwidth*3+1-Data.positioning.peaksample(n,k);
    xlim([loc-cz loc+cz])
end

% --- Executes during object creation, after setting all properties.
function corrzoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to corrzoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_Callback(hObject, eventdata, handles)
% hObject    handle to temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp as text
%        str2double(get(hObject,'String')) returns contents of temp as a double


% --- Executes during object creation, after setting all properties.
function temp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hum_Callback(hObject, eventdata, handles)
% hObject    handle to hum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hum as text
%        str2double(get(hObject,'String')) returns contents of hum as a double


% --- Executes during object creation, after setting all properties.
function hum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global xl yl Xl Yl
axes(handles.axes5)
xlim(xl);
ylim(yl);
axes(handles.axes6)
xlim(Xl);
ylim(Yl);




% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
 key = get(gcf,'CurrentKey');
    if(strcmp (key , 'x'))
        pushbutton5_Callback(hObject, eventdata, handles)
    end
    
    
    
    
% --- Executes on button press in screencalls.
function screencalls_Callback(hObject, eventdata, handles)
% hObject    handle to screencalls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
global sig
global fs
CheckCallsWater
uiwait
set(handles.uitable2,'data',round(peaktime'/Data.samplerate*1000))
% set(handles.peaks,'String',num2str(length(Data.emissiontime)))
% set(handles.peaktime,'String',num2str(Data.emissiontime'/fs*1000))
