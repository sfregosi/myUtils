function varargout = moonshine_v4_1(varargin)
% Last Modified by GUIDE v2.5 02-Nov-2015 11:07:34
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @moonshine_v4_1_OpeningFcn, ...
                   'gui_OutputFcn',  @moonshine_v4_1_OutputFcn, ...
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


% --- Executes just before moonshine_v4_1 is made visible.
function moonshine_v4_1_OpeningFcn(hObject, eventdata, handles, varargin)
global Data
visibility_start
handles.output = hObject;
guidata(hObject, handles);
Data.positioning.soundspeed = 331.4+0.607*str2num(get(handles.temp,'string'));
set(handles.soundspeed,'string',num2str(round(Data.positioning.soundspeed)))
Data.positioning.mikes = [];
Data.positioning.coords = [];
Data.positioning.pos_chan = [];
Data.sourcelevel.calibration = [];
Data.sourcelevel.SL = [];
freq = str2num(get(handles.thirdoct,'string'));
set(handles.thirdoctbands,'string',num2str(freq'))

% --- Outputs from this function are returned to the command line.
function varargout = moonshine_v4_1_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)

function Untitled_2_Callback(hObject, eventdata, handles)

function filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loadwavfile_Callback(hObject, eventdata, handles)
global sig
global fs
global Data
global env
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
if ischar(name)
    sig = [];
    [sig,fs] = audioread([path name]);
    cd(old_dir);
    t = (0:length(sig(:,1))-1)/fs;
    maxt = t(end)*1000;
    set(handles.maxtime,'string',maxt);
    checkboxStatus = get(handles.HPfilter,'Value');
    
    if(checkboxStatus)
        f_cut = 15000 / (fs/2);
        [b, a] = butter(2, f_cut, 'high');   
        sig = filtfilt(b, a, sig);
    end
    
    axes(handles.axes1)
    plot(t*1000,sig(:,1),'b-',[0 0],[1 -1],'g-',[maxt maxt],[1 -1],'r-');
    axis([0 t(end)*1000 -1 1])
    handles.var = 1:length(sig(1,:));
    set(handles.channelselect,'string', handles.var);
    set(handles.channelselect,'Value',1);
    set(handles.filename,'string',name);
    Data.samplerate = fs;
    Data.wavfile = name;
    axes(handles.axes2)
    cla

    mint = str2num(get(handles.mintime,'string'));
    maxt = str2num(get(handles.maxtime,'string'));
    thr = str2num(get(handles.amplitudethr,'string'));
    env = abs(sig(:,1));
    axes(handles.axes2)
    cla
    plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
    axis([0 t(end)*1000 0 max(env)])
else
    cd(old_dir)
end

     
     
function loadreceiverpositions_Callback(hObject, eventdata, handles)
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
[name,path]=uigetfile('*.txt','Receiver positions');
if ischar(name)
Data.positioning.mikes = load([path name]);
cd(old_dir);
Data.positioning.pos_chan = 1:length(Data.positioning.mikes(:,1));
chn = get(handles.channelselect,'Value');
Data.positioning.pos_chan(chn) = [];
Data.positioning.pos_chan = [chn Data.positioning.pos_chan];

axes(handles.axes3)
plot3(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
view ([0 90])
set(handles.specch,'string',num2str((1:length(Data.positioning.mikes(:,1)))'))
else
    cd(old_dir)
end

function savemoonshinefile_Callback(hObject, eventdata, handles)
global Data
global fs
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
Data.samplerate = fs;
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

function mintime_Callback(hObject, eventdata, handles)
global sig
global fs
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
k =get(handles.channelselect,'Value');
t = (0:length(sig(:,1))-1)/fs;
axes(handles.axes1);
plot(t*1000,sig(:,k),'b-',[mint mint],[1 -1],'g-',[maxt maxt],[1 -1],'r-');
axis([0 t(end)*1000 -1 1])

function mintime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxtime_Callback(hObject, eventdata, handles)
global sig
global fs
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
k =get(handles.channelselect,'Value');
t = (0:length(sig(:,1))-1)/fs;
axes(handles.axes1);
plot(t*1000,sig(:,k),'b-',[mint mint],[1 -1],'g-',[maxt maxt],[1 -1],'r-');
axis([0 t(end)*1000 -1 1])

function maxtime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function channelselect_Callback(hObject, eventdata, handles)
global sig
global fs
global env
global Data
% Data.positioning
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
thr = str2num(get(handles.amplitudethr,'string'));
t = (0:length(sig(:,1))-1)/fs;
for k = 1:length(sig(1,:));
switch get(handles.channelselect,'Value')   
    case k
        if isempty(Data.positioning.pos_chan)
        else
            Data.positioning.pos_chan(k) = [];
            Data.positioning.pos_chan = [k Data.positioning.pos_chan];
        end
        axes(handles.axes1);
        plot(t*1000,sig(:,k),'b-',[mint mint],[1 -1],'g-',[maxt maxt],[1 -1],'r-');
        axis([0 t(end)*1000 -1 1])
        env = abs(sig(:,k));
        axes(handles.axes2)
        cla
        plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
        axis([0 t(end)*1000 0 max(env)])
    otherwise
end
end

function channelselect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function amplitudethr_Callback(hObject, eventdata, handles)
global env
global fs
thr = str2num(get(handles.amplitudethr,'string'));
mint = str2num(get(handles.mintime,'string'));
maxt = str2num(get(handles.maxtime,'string'));
if isempty(env)
else
t = (0:length(env(:,1))-1)/fs;
axes(handles.axes2)
plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
axis([0 t(end)*1000 0 max(env)])
end

function amplitudethr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function envelope_Callback(hObject, eventdata, handles)
% global sig
% global env
% global fs
% t = (0:length(sig(:,1))-1)/fs;
% k = get(handles.channelselect,'Value');
% thr = str2num(get(handles.amplitudethr,'string'));
% mint = str2num(get(handles.mintime,'string'));
% maxt = str2num(get(handles.maxtime,'string'));
% env = abs(sig(:,k));
% axes(handles.axes2)
% cla
% plot(t*1000,env,'b-',[0 t(end)*1000],[thr thr],'m-',[mint mint],[max(env) 0],'g-',[maxt maxt],[max(env) 0],'r-')
% axis([0 t(end)*1000 0 max(env)])

function zoomtoggle_Callback(hObject, eventdata, handles)
checkbox = get(handles.zoomtoggle,'Value');
if(checkbox)
zoom on
 else
zoom off
end

function peakdetection_Callback(hObject, eventdata, handles)
global env
global fs
global Data

peaktime = peak_detection(env,str2num(get(handles.amplitudethr,'String'))...
    ,str2num(get(handles.minipi,'String'))...
,fs,str2num(get(handles.mintime,'string')),...
str2num(get(handles.maxtime,'string')));
set(handles.peaks,'String',num2str(length(peaktime)))
set(handles.peaktime,'String',num2str(peaktime'/fs*1000))
Data.emissiontime = peaktime;
Data.positioning.center_channel = get(handles.channelselect,'Value');

function peaktime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function peaks_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function soundspeed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cwidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cwidth_Callback(hObject, eventdata, handles)

function minipi_Callback(hObject, eventdata, handles)

function calculatepos_Callback(hObject, eventdata, handles)
global sig
global fs
global Data
Data.positioning.coords = [];

if isempty(Data.positioning.mikes)
     errordlg('Please load microphone positions')
else
    
    
cwidth = str2num(get(handles.cwidth,'string'))*fs/1000;
center_chan = get(handles.channelselect,'Value');
Data.positioning.center_channel = center_chan;
Data.positioning.cwidth = cwidth;
Data.positioning.peaksample = [];
    
S = [(Data.emissiontime-cwidth)' (Data.emissiontime+2*cwidth)'];
for n = 1:length(Data.emissiontime)
    if Data.emissiontime(n)+2*cwidth > length(sig(:,1))
        Data.positioning.peaksample(:,n) = NaN;
    else
       for m = 1:length(sig(1,:));
   cross = xcorr(sig(int32(S(n,1)):int32(S(n,2)),center_chan),sig(int32(S(n,1)):int32(S(n,2)),m)); 
   [peakval Data.positioning.peaksample(m,n)] = max(abs(cross));
   clear ('cross','Cross','peakval')
       end
    end
end

%this element enables the changing of the number of receivers used in
%positioning and the receiver used as reference for the calculation, the
%first microphone in the Data.positioning.pos_chan vector is always used as reference.
for n = 1:length(Data.positioning.pos_chan)
receiverpositions(n,:) = Data.positioning.mikes(Data.positioning.pos_chan(n),:)-Data.positioning.mikes(Data.positioning.pos_chan(1),:);
end
%-------------------------------------------------------------------------
Data.positioning.soundspeed = str2num(get(handles.soundspeed,'string'));
set(handles.soundspeed,'string',num2str(round(Data.positioning.soundspeed)))

for n = 1:length(Data.emissiontime)
    if sum(isnan(Data.positioning.peaksample(:,n))) > 1
        coords(n,:) = NaN;
    else
    coords(n,:) = localization(Data.positioning.peaksample(Data.positioning.pos_chan,n)/fs,receiverpositions,Data.positioning.soundspeed,'2d');
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
axes(handles.axes3)
cla
plot(Data.positioning.coords(:,1), Data.positioning.coords(:,2),'kx')
hold on
plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),1),Data.positioning.mikes(Data.positioning.pos_chan(1),2),'ko','markersize',10)
hold off
set(handles.xtag,'Value',1)
set(handles.numbers,'Value',0)
end

function selectchannels_Callback(hObject, eventdata, handles)
global Data
prompts = {'Positioning channels'};
title = 'Channel select';
lineno = 1;
channel.var = num2str(Data.positioning.pos_chan);
defaultanswers = {channel.var};
inp = inputdlg(prompts,title,lineno,defaultanswers);
Data.positioning.pos_chan=str2num(inp{1});


function xyview_Callback(hObject, eventdata, handles)
global Data
axes(handles.axes3)
cla
if get(handles.xtag,'value') == 1;
plot(Data.positioning.coords(:,1), Data.positioning.coords(:,2),'kx')
hold on
plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),1),Data.positioning.mikes(Data.positioning.pos_chan(1),2),'ko','markersize',10)
hold off
else
    numeric_indication = 1:length(Data.positioning.coords(:,1));
plot(Data.positioning.coords(:,1), Data.positioning.coords(:,2),'kx','markersize',0.5)
for n = 1:length(Data.positioning.coords(:,1))
    text(Data.positioning.coords(n,1),Data.positioning.coords(n,2),int2str(numeric_indication(n)))
end
hold on
plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),1),Data.positioning.mikes(Data.positioning.pos_chan(1),2),'ko','markersize',10)
end    
set(handles.view_indicator,'String','xy');

function yzview_Callback(hObject, eventdata, handles)
global Data
axes(handles.axes3)
cla
if get(handles.xtag,'value') == 1;
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx')
hold on
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
hold off
else
    numeric_indication = 1:length(Data.positioning.coords(:,1));
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx','markersize',0.5)
for n = 1:length(Data.positioning.coords(:,1))
    text(Data.positioning.coords(n,2),Data.positioning.coords(n,3),int2str(numeric_indication(n)))
end
hold on
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
end
set(handles.view_indicator,'String','yz');

function numbers_Callback(hObject, eventdata, handles)
global Data
set(handles.xtag,'Value',0)
axes(handles.axes3)
cla
if get(handles.view_indicator,'String') == 'xy';
numeric_indication = 1:length(Data.positioning.coords(:,1));
plot(Data.positioning.coords(:,1), Data.positioning.coords(:,2),'kx','markersize',0.5)
for n = 1:length(Data.positioning.coords(:,1))
    text(Data.positioning.coords(n,1),Data.positioning.coords(n,2),int2str(numeric_indication(n)))
end
hold on
plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),1),Data.positioning.mikes(Data.positioning.pos_chan(1),2),'ko','markersize',10)
set(handles.view_indicator,'String','xy')
hold off
else
numeric_indication = 1:length(Data.positioning.coords(:,1));
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx','markersize',0.5)
for n = 1:length(Data.positioning.coords(:,1))
    text(Data.positioning.coords(n,2),Data.positioning.coords(n,3),int2str(numeric_indication(n)))
end
hold on
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
set(handles.view_indicator,'String','yz')
hold off
end
    
function xtag_Callback(hObject, eventdata, handles)
global Data

set(handles.numbers,'Value',0)

axes(handles.axes3)
cla
if get(handles.view_indicator,'String') == 'xy';
plot(Data.positioning.coords(:,1), Data.positioning.coords(:,2),'kx','markersize',6)
hold on
plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),1),Data.positioning.mikes(Data.positioning.pos_chan(1),2),'ko','markersize',10)
set(handles.view_indicator,'String','xy')
hold off
else
plot(Data.positioning.coords(:,2), Data.positioning.coords(:,3),'kx','markersize',6)
hold on
plot(Data.positioning.mikes(:,2),Data.positioning.mikes(:,3),'ro','markersize',8)
plot(Data.positioning.mikes(Data.positioning.pos_chan(1),2),Data.positioning.mikes(Data.positioning.pos_chan(1),3),'ko','markersize',10)
set(handles.view_indicator,'String','yz')
hold off
end

function positioning_Callback(hObject, eventdata, handles)
visibility_positioning

function temp_Callback(hObject, eventdata, handles)
checkboxStatus = get(handles.water,'Value');
if (checkboxStatus)
    Data.positioning.soundspeed = str2num(get(handles.soundspeed,'string'));
else
    Data.positioning.soundspeed = 331.4+0.607*str2num(get(handles.temp,'string'));
    set(handles.soundspeed,'string',num2str(round(Data.positioning.soundspeed)))
end

function hum_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_paths_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function select_paths_Callback(hObject, eventdata, handles)
[pathname] = uigetdir(pwd, 'Locate sound file folder (cancel to skip)');
if ~(pathname==0)
    setpref('moonshine_path','wav',[pathname]);
end

[pathname] = uigetdir(pwd, 'Locate receiver position folder (cancel to skip)');
if ~(pathname==0)
    setpref('moonshine_path','mike',[pathname]);
end

[pathname] = uigetdir(pwd, 'Locate folder to save analyzed files (cancel to skip)');
if ~(pathname==0)
    setpref('moonshine_path','analyzed_path',[pathname]);
end

[pathname] = uigetdir(pwd, 'Locate calibration folder (cancel to skip)');
if ~(pathname==0)
    setpref('moonshine_path','calibration',[pathname]);
end


% --------------------------------------------------------------------
function load_moonshine_Callback(hObject, eventdata, handles)
% hObject    handle to load_moonshine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data

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
[name,path]=uigetfile('*.mat','Moonshine file');
load([path name]);
set(handles.filename,'string',name);
cd(old_dir);
set(handles.specch,'string',num2str((1:length(Data.positioning.mikes(:,1)))'))

function minipi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function temp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function intensity_Callback(hObject, eventdata, handles)
global Data
global sig
visibility_intensity
set(handles.speccall,'string',num2str((1:length(Data.emissiontime))'))
set(handles.axes29,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')
set(handles.axes30,'xtick',[],'ytick',[],'ycolor','w','xcolor','w') 
set(handles.axes31,'xtick',[],'ytick',[],'ycolor','w','xcolor','w') 
set(handles.axes32,'xtick',[],'ytick',[],'ycolor','w','xcolor','w') 
set(handles.axes34,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')
set(handles.axes35,'xtick',[],'ytick',[],'ycolor','w','xcolor','w') 
set(handles.axes36,'xtick',[],'ytick',[],'ycolor','w','xcolor','w') 
set(handles.axes37,'xtick',[],'ytick',[],'ycolor','w','xcolor','w') 

if isempty(Data.positioning.coords)
else
    rms1 = str2num(get(handles.rms1,'string'))*Data.samplerate/1000;
    rms2 = str2num(get(handles.rms2,'string'))*Data.samplerate/1000;    
    set(handles.speccall,'value',1)
    set(handles.specch,'value',Data.positioning.center_channel)
    int = Data.emissiontime(1)-rms1:Data.emissiontime(1)+rms2;
    ch = Data.positioning.center_channel;
    axes(handles.axes33)
    cla
    spectrumplot(sig(int,ch),Data.samplerate)
    axis([0 Data.samplerate/2000 -60 60])
    set(handles.axes33,'ytick',-60:20:0)
    
    axes(handles.axes40)
    ti = linspace(0,(rms1+rms2)*1000/Data.samplerate,length(int));
    plot(ti,sig(int,ch))
    box off
    set(gca,'ycolor','w','ytick',[])
    axis([0 ti(end) -max(abs(sig(int,ch)))*1.1 max(abs(sig(int,ch)))*1.1])
    axes(handles.axes41)
    img_spec(sig(int,ch),128,120,1024,Data.samplerate/1000,50)
    box off
    
end

function SN_Callback(hObject, eventdata, handles)
% hObject    handle to SN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SN as text
%        str2double(get(hObject,'String')) returns contents of SN as a double


% --- Executes during object creation, after setting all properties.
function SN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rms2_Callback(hObject, eventdata, handles)
% hObject    handle to rms2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rms2 as text
%        str2double(get(hObject,'String')) returns contents of rms2 as a double


% --- Executes during object creation, after setting all properties.
function rms2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rms2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rms1_Callback(hObject, eventdata, handles)
% hObject    handle to rms1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rms1 as text
%        str2double(get(hObject,'String')) returns contents of rms1 as a double


% --- Executes during object creation, after setting all properties.
function rms1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rms1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function est_max_dur_Callback(hObject, eventdata, handles)
% hObject    handle to est_max_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of est_max_dur as text
%        str2double(get(hObject,'String')) returns contents of est_max_dur as a double


% --- Executes during object creation, after setting all properties.
function est_max_dur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to est_max_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SLscreen.
function SLscreen_Callback(hObject, eventdata, handles)
% hObject    handle to SLscreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
global sig
Data.sourcelevel.arrivaltime_at_mic = [];
for i = 1:length(Data.emissiontime)
    Data.sourcelevel.arrivaltime_at_mic(i,:) = arrival_at_microphones(Data.emissiontime(i),Data.positioning.coords(i,:),Data.positioning.mikes,Data.positioning.center_channel,Data.samplerate,Data.positioning.soundspeed);
end
Data.temp = str2num(get(handles.temp,'string'));
Data.humidity = str2num(get(handles.hum,'string'));

if isempty(Data.sourcelevel.calibration)
    Data.sourcelevel.calibration = ones(length(Data.positioning.mikes(:,1)),1);
else
end
if isempty(Data.positioning.coords)
     errordlg('Please complete positioning')
else
    figure(1);
    figure(2);
    close([1 2])
rms(1) = round(str2num(get(handles.rms1,'string'))*Data.samplerate/1000);
rms(2) = round(str2num(get(handles.rms2,'string'))*Data.samplerate/1000);
rmsmin = round(str2num(get(handles.rmsmin,'string'))*Data.samplerate/1000);
if mod(sum(rms),2)
else
rms(2) = rms(2)+1;    
end
if mod(rms(1)+rmsmin,2)
else
    rmsmin = rmsmin+1;
end
rmswindow = ones(length(Data.emissiontime),1)*rms;
for n = 1:length(Data.emissiontime)-1
    deltaT = Data.emissiontime(n+1)-Data.emissiontime(n);
    if deltaT < rms(2)
        rmswindow(n,2) = rmsmin;
        rmswindow(n+1,2) = rmsmin;
    end    
end
est_max_dur = str2num(get(handles.est_max_dur,'string'))*Data.samplerate/1000;
SN = str2num(get(handles.SN,'string'));
Data.sourcelevel.SL = [];
n = fieldnames(Data.sourcelevel);
if length(n) > 4
    for i = 5:length(n)
        Data.sourcelevel.(sprintf(n{i})) = [];
    end
else
end

Data.sourcelevel.mike_vektor = ones(length(Data.positioning.mikes(:,1)),1)*[0 1 0];
Data.sourcelevel.RMS95 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));
Data.sourcelevel.RMS75 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));

if min(Data.positioning.coords(:,1)) < 0
fig2lim(1) = min(Data.positioning.coords(:,1))*1.1;
else fig2lim(1) = 0;
end

if max(Data.positioning.coords(:,1)) > max(Data.positioning.mikes(:,1))
    fig2lim(2) = max(Data.positioning.coords(:,1))*1.1;
else fig2lim(2) = max(Data.positioning.mikes(:,1))*1.1;
end
fig2lim(3) = 0;

if max(Data.positioning.coords(:,2)) > 10
    fig2lim(4) = 10;
else
fig2lim(4) = max(Data.positioning.coords(:,2))*1.1;
end

for k = 1:length(Data.emissiontime)
times = Data.sourcelevel.arrivaltime_at_mic(k,:);

if sum(isnan(times)) < 1
bat = Data.positioning.coords(k,:);
[range(1) minloc] = min(times-rmswindow(k,1));
[range(2) maxloc] = max(times+rmswindow(k,2));
diff = times-times(minloc)+1;

seg = sig(range(1):range(2),:);

compsig = [];
for i = 1:length(Data.positioning.mikes(:,1));
    Sig = [];
    Sig = seg(diff(i):diff(i)+sum(rmswindow(k,:)),i);
    compsig(:,i) = impcomp(Sig,Data.samplerate,Data.positioning.mikes(i,:),bat,Data.temp,Data.humidity,Data.sourcelevel.mike_vektor(i,:));

end
int = [];
int75 = [];
[SL int dur] = rms95_multi(compsig,'h');
[SL75 int75 dur75] = rms95_multi(compsig,'l');
Data.sourcelevel.RMS95(k,:) = SL;
Data.sourcelevel.duration95(k,:) = length(int(:,1))/Data.samplerate;
Data.sourcelevel.RMS75(k,:) = SL75;
Data.sourcelevel.duration75(k,:) = length(int75(:,1))/Data.samplerate;
fh2 = figure(2);
clf
figure(2)
plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'or')
hold on
plot(Data.positioning.coords(k:end,1),Data.positioning.coords(k:end,2),'*')
plot(bat(1),bat(2),'ok')
axis(fig2lim)
movegui(fh2,'west')


prompt = {'valid position','valid calls','95% ?'};
dlg_title = 'checklist';
num_lines = 1;
if length(int(:,1)) > est_max_dur
    lvl = 0;
    chnls = find(SL75./std(compsig) > SN);
    chkcol = 'y'; 
else lvl = 1;
    chnls = find(SL./std(compsig) > SN);
    chkcol = 'g'; 
end
if isempty(chnls)
    validcall = 0;
else     validcall = 1;
end

chnls(find(ismember(chnls,str2num(get(handles.exclch,'string'))))) = [];

chnls(find(ismember(chnls,find(max(abs(seg)) > 0.99)))) = [];

fh1 = figure(1);
clf

movegui(fh1,'east') 
R = ceil(sqrt(length(Data.positioning.mikes(:,1))));
C = ceil(length(Data.positioning.mikes(:,1))/R);
figure(1)
for i = 1:length(Data.positioning.mikes(:,1))
    subplot(R,C,i)
    plot(compsig(:,i))
    hold on
    plot(int(:,i),compsig(int(:,i),i),'r')
    plot(int75(:,i),compsig(int75(:,i),i),'k')
    if max(abs(seg(:,i))) > 0.99
        title('Overload','color','r')
    else
    end
    if ismember(i,chnls)
        set(gca,'color',chkcol)
    else
    end
    axis([1 length(compsig(:,1)) -max(max(abs(compsig)))*1.2 max(max(abs(compsig)))*1.2])
end

def = {num2str(validcall),num2str(chnls),num2str(lvl)};

inp = inputdlg(prompt,dlg_title,num_lines,def);
Data.sourcelevel.validcalls(k,:)=str2num(inp{1});
Data.sourcelevel.chklist(k,:) = 0;
Data.sourcelevel.chklist(k,str2num(inp{2})) = 1;
Data.sourcelevel.RMSlvl(k,:)=str2num(inp{3});
else

    fh2 = figure(2);
    clf
    movegui(fh2,'west')
    fh1 = figure(1);
    clf
    movegui(fh1,'east')
    prompt = {'valid position','valid calls','95% ?'};
    dlg_title = 'checklist';
    num_lines = 1;
    def = {'0',num2str(1:length(Data.positioning.mikes(:,1))),'1'};

    inp = inputdlg(prompt,dlg_title,num_lines,def);
    Data.sourcelevel.validcalls(k,:)=str2num(inp{1});
    Data.sourcelevel.chklist(k,str2num(inp{2})) = 1;
    Data.sourcelevel.RMSlvl(k,:)=str2num(inp{3});
end


end

close([fh1 fh2])

for i = 1:length(Data.emissiontime)
    if Data.sourcelevel.RMSlvl(i) == 1
        RMSfin(i,:) = Data.sourcelevel.RMS95(i,:);
    else RMSfin(i,:) = Data.sourcelevel.RMS75(i,:);
    end
    Data.sourcelevel.SL(i,:) = 94+20*log10(RMSfin(i,:)./Data.sourcelevel.calibration');
    if Data.sourcelevel.validcalls(i) == 0
        Data.sourcelevel.SL(i,:) = NaN;
    else
    end
end
   
Data.sourcelevel.SL(find(Data.sourcelevel.chklist==0)) = NaN;

[val loc] = max(Data.sourcelevel.SL,[],2);
    
for i = 1:length(Data.emissiontime)
    vec = Data.positioning.coords(i,:)-Data.positioning.mikes(loc(i),:);
[T P dist(i)] = cart2sph(vec(1),vec(2),vec(3));
end 
dist(isnan(val)) = [];
val(isnan(val)) = [];
if isempty(dist)
else
if mean(Data.sourcelevel.calibration) == 1
    axes(handles.axes28)
    cla
    plot(dist,val,'*')
    hold on
    text(0.5,mean(val),'No calibration loaded','color','r','fontweight','bold','fontsize',18)
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
else
    axes(handles.axes28)
    cla
    plot(dist,val,'*')
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
end
end
Data.sourcelevel.rmswindow = rmswindow;
Data.sourcelevel.SignalNoiseThreshold = SN;
Data.sourcelevel.durationThreshold = est_max_dur;

end

% --- Executes on button press in DirScreen.
function DirScreen_Callback(hObject, eventdata, handles)
% hObject    handle to DirScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
global sig
figure(1)
figure(2)
close([1 2])
if isempty(Data.positioning.coords)
     errordlg('Please complete positioning and SL screen')
elseif isempty(Data.sourcelevel.SL)
     errordlg('Please complete  SL screen')
else
    Data.horizontalmikes = find(Data.positioning.mikes(:,3) == mode(Data.positioning.mikes(:,3)));
    Data.verticalmikes = find(Data.positioning.mikes(:,1) == mode(Data.positioning.mikes(:,1)));
    anglim = str2num(get(handles.anglim,'string'));
    for i = 1:length(Data.emissiontime)
    [h(i,:) v(i,:)] = angcalc(Data.positioning.coords(i,:),Data.positioning.mikes);
    hm = [];
    hm = Data.horizontalmikes(ismember(Data.horizontalmikes,find(Data.sourcelevel.chklist(i,:))));
        if isempty(hm)
        aim_h(i) = NaN;
        else
        aim_h(i) = polybeamaim(Data.sourcelevel.SL(i,hm),h(i,hm));
        end
    
    vm = [];
    vm = Data.verticalmikes(ismember(Data.verticalmikes,find(Data.sourcelevel.chklist(i,:))));
        if isempty(vm)
        aim_v(i) = NaN;
        else
        aim_v(i) = polybeamaim(Data.sourcelevel.SL(i,vm),v(i,vm));
        end
    end

Data.directionality.horizontalang = h(:,Data.horizontalmikes)-aim_h'*ones(1,length(Data.horizontalmikes));
Data.directionality.verticalang = v(:,Data.verticalmikes)-aim_v'*ones(1,length(Data.verticalmikes));
Data.directionality.horizontalSL = Data.sourcelevel.SL(:,Data.horizontalmikes);
Data.directionality.verticalSL = Data.sourcelevel.SL(:,Data.verticalmikes);
Data.directionality.horizontalaim = aim_h(:);
Data.directionality.verticalaim = aim_v(:);
    
figure(1)
figure(2)
fh2 = figure(2);
clf
movegui(fh2,'east')
fh1 = figure(1);
clf
movegui(fh1,'west')

hor_ind = find(ismember(Data.horizontalmikes,Data.verticalmikes));
vert_ind = find(ismember(Data.verticalmikes,Data.horizontalmikes));
Data.directionality.horizontalCheck = [];
Data.directionality.verticalCheck = [];

for i = 1:length(Data.emissiontime)
    ha = Data.directionality.horizontalang(i,:).*180/pi;
    hp = Data.directionality.horizontalSL(i,:)-max(Data.directionality.horizontalSL(i,:));
    va = Data.directionality.verticalang(i,:).*180/pi;
    vp = Data.directionality.verticalSL(i,:)-max(Data.directionality.verticalSL(i,:));
    if mean(isnan(ha)) == 1 || mean(isnan(va)) == 1 || mean(isnan(va)) == 1 || mean(isnan(vp)) == 1
        figure(1)
        clf
        plot([-anglim -anglim],[1 3],'--w','linewidth',2)
        plot([anglim anglim],[1 3],'--w','linewidth',2)
        
        figure(2)
        clf
        plot([1 3],[-anglim -anglim],'--w','linewidth',2)
        plot([1 3],[anglim anglim],'--w','linewidth',2)
        Data.directionality.horizontalCheck(i,:) = 0;
        Data.directionality.verticalCheck(i,:) = 0;
    else
    figure(1)
    clf
    plot(ha,hp,'*','markersize',10)
    hold on
    plot(ha(hor_ind),hp(hor_ind),'ok','markersize',10)
    plot([-anglim -anglim],[1 3],'--w','linewidth',2)
    plot([anglim anglim],[1 3],'--w','linewidth',2)
    
    figure(2)
    clf
    plot(vp,va,'*','markersize',10)
    hold on
    plot(vp(vert_ind),va(vert_ind),'ok','markersize',10)
    plot([1 3],[-anglim -anglim],'--w','linewidth',2)
    plot([1 3],[anglim anglim],'--w','linewidth',2)
   
    if isnan(aim_v(i)) || isnan(aim_h(i))
    hor_check = 0;
    vert_check = 0;
    else
        if abs(va(vert_ind)) < anglim
            hor_check = 1;
            figure(1)
            set(gca,'color','g')
        else hor_check = 0;
            figure(1)
            set(gca,'color','r')
        end
    
        if abs(ha(hor_ind)) < anglim
            vert_check = 1;
            figure(2)
            set(gca,'color','g')
        else vert_check = 0;
            figure(2)
            set(gca,'color','r')
        end
    end
    prompt = {'valid horizontal','valid vertical'};
    dlg_title = ['Beam ' num2str(i) '/' num2str(length(Data.emissiontime))];
    num_lines = 1;
    def = {num2str(hor_check),num2str(vert_check)};
    inp = inputdlg(prompt,dlg_title,num_lines,def);
    Data.directionality.horizontalCheck(i,:) = str2num(inp{1});
    Data.directionality.verticalCheck(i,:) = str2num(inp{2});
    end
    
end    
close([fh1 fh2])
    
a = find(Data.directionality.horizontalCheck);
b = find(Data.directionality.verticalCheck);
HA = Data.directionality.horizontalang(a,:).*180/pi;
HP = Data.directionality.horizontalSL(a,:)-max(Data.directionality.horizontalSL(a,:),[],2)*ones(1,length(Data.directionality.horizontalang(1,:)));
VA = Data.directionality.verticalang(b,:).*180/pi;
VP = Data.directionality.verticalSL(b,:)-max(Data.directionality.verticalSL(b,:),[],2)*ones(1,length(Data.directionality.verticalang(1,:)));

axes(handles.axes29)
cla
polar_plot(HA(:),HP(:),[],[],[],'b*')
axis([-33 33 0 33])
pbaspect([2,1,1])
set(handles.axes29,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')

axes(handles.axes30)
cla
polar_plot(-VA(:),VP(:),[],[],90,'b*')
axis([0 33 -33 33])
pbaspect([1,2,1])
set(handles.axes30,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')    
    
    
    
    
end    


function anglim_Callback(hObject, eventdata, handles)
% hObject    handle to anglim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of anglim as text
%        str2double(get(hObject,'String')) returns contents of anglim as a double


% --- Executes during object creation, after setting all properties.
function anglim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anglim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SLLuck.
function SLLuck_Callback(hObject, eventdata, handles)
global Data
global sig
Data.sourcelevel.arrivaltime_at_mic = [];
for i = 1:length(Data.emissiontime)
    Data.sourcelevel.arrivaltime_at_mic(i,:) = arrival_at_microphones(Data.emissiontime(i),Data.positioning.coords(i,:),Data.positioning.mikes,Data.positioning.center_channel,Data.samplerate,Data.positioning.soundspeed);
end
Data.temp = str2num(get(handles.temp,'string'));
Data.humidity = str2num(get(handles.hum,'string'));

if isempty(Data.sourcelevel.calibration)
    Data.sourcelevel.calibration = ones(length(Data.positioning.mikes(:,1)),1);
else
end
if isempty(Data.positioning.coords)
     errordlg('Please complete positioning')
else
    figure(1);
    figure(2);
    close([1 2])
rms(1) = round(str2num(get(handles.rms1,'string'))*Data.samplerate/1000);
rms(2) = round(str2num(get(handles.rms2,'string'))*Data.samplerate/1000);
rmsmin = round(str2num(get(handles.rmsmin,'string'))*Data.samplerate/1000);
if mod(sum(rms),2)
else
rms(2) = rms(2)+1;    
end
if mod(rms(1)+rmsmin,2)
else
    rmsmin = rmsmin+1;
end
rmswindow = ones(length(Data.emissiontime),1)*rms;
for n = 1:length(Data.emissiontime)-1
    deltaT = Data.emissiontime(n+1)-Data.emissiontime(n);
    if deltaT < rms(2)
        rmswindow(n,2) = rmsmin;
        rmswindow(n+1,2) = rmsmin;
    end    
end
est_max_dur = str2num(get(handles.est_max_dur,'string'))*Data.samplerate/1000;
SN = str2num(get(handles.SN,'string'));
Data.sourcelevel.SL = [];
n = fieldnames(Data.sourcelevel);
if length(n) > 4
    for i = 5:length(n)
        Data.sourcelevel.(sprintf(n{i})) = [];
    end
else
end

Data.sourcelevel.mike_vektor = ones(length(Data.positioning.mikes(:,1)),1)*[0 1 0];

Data.sourcelevel.RMS95 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));
Data.sourcelevel.RMS75 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));
if min(Data.positioning.coords(:,1)) < 0
fig2lim(1) = min(Data.positioning.coords(:,1))*1.1;
else fig2lim(1) = 0;
end

if max(Data.positioning.coords(:,1)) > max(Data.positioning.mikes(:,1))
    fig2lim(2) = max(Data.positioning.coords(:,1))*1.1;
else fig2lim(2) = max(Data.positioning.mikes(:,1))*1.1;
end
fig2lim(3) = 0;

if max(Data.positioning.coords(:,2)) > 10
    fig2lim(4) = 10;
else
fig2lim(4) = max(Data.positioning.coords(:,2))*1.1;
end

for k = 1:length(Data.emissiontime)
times = Data.sourcelevel.arrivaltime_at_mic(k,:);

if sum(isnan(times)) < 1
bat = Data.positioning.coords(k,:);



[range(1) minloc] = min(times-rmswindow(k,1));
[range(2) maxloc] = max(times+rmswindow(k,2));
diff = times-times(minloc)+1;
seg = sig(range(1):range(2),:);
compsig = [];
for i = 1:length(Data.positioning.mikes(:,1));
    Sig = [];
    Sig = seg(diff(i):diff(i)+sum(rmswindow(k,:)),i);
    compsig(:,i) = impcomp(Sig,Data.samplerate,Data.positioning.mikes(i,:),bat,Data.temp,Data.humidity,Data.sourcelevel.mike_vektor(i,:));
end
int = [];
int75 = [];
[SL int dur] = rms95_multi(compsig,'h');
[SL75 int75 dur75] = rms95_multi(compsig,'l');
Data.sourcelevel.RMS95(k,:) = SL;
Data.sourcelevel.duration95(k,:) = length(int(:,1))/Data.samplerate;
Data.sourcelevel.RMS75(k,:) = SL75;
Data.sourcelevel.duration75(k,:) = length(int75(:,1))/Data.samplerate;
fh2 = figure(2);
clf
plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'or')
hold on
plot(Data.positioning.coords(k:end,1),Data.positioning.coords(k:end,2),'*')
plot(bat(1),bat(2),'ok')
axis(fig2lim)
movegui(fh2,'west')

if length(int(:,1)) > est_max_dur
    lvl = 0;
    chnls = find(SL75./std(compsig) > SN);
    chkcol = 'y'; 
else lvl = 1;
    chnls = find(SL./std(compsig) > SN);
    chkcol = 'g'; 
end
if isempty(chnls)
    validcall = 0;
else     validcall = 1;
end

chnls(find(ismember(chnls,str2num(get(handles.exclch,'string'))))) = []; 
chnls(find(ismember(chnls,find(max(abs(seg)) > 0.99)))) = [];
fh1 = figure(1);
clf
movegui(fh1,'east') 
R = ceil(sqrt(length(Data.positioning.mikes(:,1))));
C = ceil(length(Data.positioning.mikes(:,1))/R);
for i = 1:length(Data.positioning.mikes(:,1))
    subplot(R,C,i)
    plot(compsig(:,i))
    hold on
    plot(int(:,i),compsig(int(:,i),i),'r')
    plot(int75(:,i),compsig(int75(:,i),i),'k')
    if max(abs(seg(:,i))) > 0.99
        title('Overload','color','r')
    else
    end
    if ismember(i,chnls)
        set(gca,'color',chkcol)
    else
    end
    axis([1 length(compsig(:,1)) -max(max(abs(compsig)))*1.2 max(max(abs(compsig)))*1.2])
end

Data.sourcelevel.validcalls(k,:) = validcall;
Data.sourcelevel.chklist(k,:) = 0;
Data.sourcelevel.chklist(k,chnls) = 1;
Data.sourcelevel.RMSlvl(k,:)=lvl;
else

    fh2 = figure(2);
    clf
    movegui(fh2,'west')
    fh1 = figure(1);
    clf
    movegui(fh1,'east')
    Data.sourcelevel.validcalls(k,:) = 0;
    Data.sourcelevel.chklist(k,:) = 1;
    Data.sourcelevel.RMSlvl(k,:)=1;
end
pause(0.1)

end
close([fh1 fh2])

for i = 1:length(Data.emissiontime)
    if Data.sourcelevel.RMSlvl(i) == 1
        RMSfin(i,:) = Data.sourcelevel.RMS95(i,:);
    else RMSfin(i,:) = Data.sourcelevel.RMS75(i,:);
    end
    Data.sourcelevel.SL(i,:) = 94+20*log10(RMSfin(i,:)./Data.sourcelevel.calibration');
    if Data.sourcelevel.validcalls(i) == 0
        Data.sourcelevel.SL(i,:) = NaN;
    else
    end
end
   
Data.sourcelevel.SL(find(Data.sourcelevel.chklist==0)) = NaN;

[val loc] = max(Data.sourcelevel.SL,[],2);

for i = 1:length(Data.emissiontime)
    vec = Data.positioning.coords(i,:)-Data.positioning.mikes(loc(i),:);
[T P dist(i)] = cart2sph(vec(1),vec(2),vec(3));
end 
dist(isnan(val)) = [];
val(isnan(val)) = [];
if isempty(dist)
else
if mean(Data.sourcelevel.calibration) == 1
    axes(handles.axes28)
    cla
    plot(dist,val,'*')
    hold on
    text(0.5,mean(val),'No calibration loaded','color','r','fontweight','bold','fontsize',18)
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
else
    axes(handles.axes28)
    cla
    plot(dist,val,'*')
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
end
end
Data.sourcelevel.rmswindow = rmswindow;
Data.sourcelevel.SignalNoiseThreshold = SN;
Data.sourcelevel.durationThreshold = est_max_dur;

end

% --- Executes on button press in DirLuck.
function DirLuck_Callback(hObject, eventdata, handles)
% hObject    handle to DirLuck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Data
global sig
figure(1)
figure(2)
close([1 2])
if isempty(Data.positioning.coords)
     errordlg('Please complete positioning and SL screen')
elseif isempty(Data.sourcelevel.SL)
     errordlg('Please complete  SL screen')
else
    Data.horizontalmikes = find(Data.positioning.mikes(:,3) == mode(Data.positioning.mikes(:,3)));
    Data.verticalmikes = find(Data.positioning.mikes(:,1) == mode(Data.positioning.mikes(:,1)));
    anglim = str2num(get(handles.anglim,'string'));
    for i = 1:length(Data.emissiontime)
    [h(i,:) v(i,:)] = angcalc(Data.positioning.coords(i,:),Data.positioning.mikes);
    hm = [];
    hm = Data.horizontalmikes(ismember(Data.horizontalmikes,find(Data.sourcelevel.chklist(i,:))));
        if isempty(hm)
        aim_h(i) = NaN;
        else
        aim_h(i) = polybeamaim(Data.sourcelevel.SL(i,hm),h(i,hm));
        end
    
    vm = [];
    vm = Data.verticalmikes(ismember(Data.verticalmikes,find(Data.sourcelevel.chklist(i,:))));
        if isempty(vm)
        aim_v(i) = NaN;
        else
        aim_v(i) = polybeamaim(Data.sourcelevel.SL(i,vm),v(i,vm));
        end
    end

Data.directionality.horizontalang = h(:,Data.horizontalmikes)-aim_h'*ones(1,length(Data.horizontalmikes));
Data.directionality.verticalang = v(:,Data.verticalmikes)-aim_v'*ones(1,length(Data.verticalmikes));
Data.directionality.horizontalSL = Data.sourcelevel.SL(:,Data.horizontalmikes);
Data.directionality.verticalSL = Data.sourcelevel.SL(:,Data.verticalmikes);
Data.directionality.horizontalaim = aim_h(:);
Data.directionality.verticalaim = aim_v(:);
    
    figure(1)
figure(2)
fh2 = figure(2);
clf
movegui(fh2,'east')
fh1 = figure(1);
clf
movegui(fh1,'west')

hor_ind = find(ismember(Data.horizontalmikes,Data.verticalmikes));
vert_ind = find(ismember(Data.verticalmikes,Data.horizontalmikes));
Data.directionality.horizontalCheck = [];
Data.directionality.verticalCheck = [];

for i = 1:length(Data.emissiontime)
    ha = Data.directionality.horizontalang(i,:).*180/pi;
    hp = Data.directionality.horizontalSL(i,:)-max(Data.directionality.horizontalSL(i,:));
    va = Data.directionality.verticalang(i,:).*180/pi;
    vp = Data.directionality.verticalSL(i,:)-max(Data.directionality.verticalSL(i,:));
    figure(1)
    clf
    plot(ha,hp,'*','markersize',10)
    hold on
    plot(ha(hor_ind),hp(hor_ind),'ok','markersize',10)
    plot([-anglim -anglim],[1 3],'--w','linewidth',2)
    plot([anglim anglim],[1 3],'--w','linewidth',2)
    
    figure(2)
    clf
    plot(vp,va,'*','markersize',10)
    hold on
    plot(vp(vert_ind),va(vert_ind),'ok','markersize',10)
    plot([1 3],[-anglim -anglim],'--w','linewidth',2)
    plot([1 3],[anglim anglim],'--w','linewidth',2)
   
    if isnan(aim_v(i)) || isnan(aim_h(i))
    hor_check = 0;
    vert_check = 0;
    else
        if abs(va(vert_ind)) < anglim
        hor_check = 1;
        figure(1)
        set(gca,'color','g')
        else hor_check = 0;
        figure(1)
        set(gca,'color','r')
        end
    
        if abs(ha(hor_ind)) < anglim
            vert_check = 1;
            figure(2)
            set(gca,'color','g')
        else vert_check = 0;
            figure(2)
            set(gca,'color','r')
        end
    end
%     prompt = {'valid horizontal','valid vertical'};
%     dlg_title = ['Beam ' num2str(i) '/' num2str(length(Data.emissiontime))];
%     num_lines = 1;
%     def = {num2str(hor_check),num2str(vert_check)};
%     inp = inputdlg(prompt,dlg_title,num_lines,def);
    Data.directionality.horizontalCheck(i,:) = hor_check;
    Data.directionality.verticalCheck(i,:) = vert_check;
    
    
end    
close([fh1 fh2])

a = find(Data.directionality.horizontalCheck);
b = find(Data.directionality.verticalCheck);
HA = Data.directionality.horizontalang(a,:).*180/pi;
HP = Data.directionality.horizontalSL(a,:)-max(Data.directionality.horizontalSL(a,:),[],2)*ones(1,length(Data.directionality.horizontalang(1,:)));
VA = Data.directionality.verticalang(b,:).*180/pi;
VP = Data.directionality.verticalSL(b,:)-max(Data.directionality.verticalSL(b,:),[],2)*ones(1,length(Data.directionality.verticalang(1,:)));

axes(handles.axes29)
cla
polar_plot(HA(:),HP(:),[],[],[],'*','b')
axis([-33 33 0 33])
pbaspect([2,1,1])
set(handles.axes29,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')

axes(handles.axes30)
cla
polar_plot(-VA(:),VP(:),[],[],90,'*','b')
axis([0 33 -33 33])
pbaspect([1,2,1])
set(handles.axes30,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')    
    
    
    
    
end    

% --------------------------------------------------------------------
function loadcalibration_Callback(hObject, eventdata, handles)
global Data

if ispref('moonshine_path','calibration')
    [pn] = getpref('moonshine_path','calibration');
else
    pn = './';
end

old_dir = pwd;
try
    cd(pn);
catch
    disp('Your paths variable points to a directory that no longer exists. Please update the paths.');
end
[name,path]=uigetfile('*.txt','load calibration file');
Data.sourcelevel.calibration = load([path name]);
cd(old_dir);



function thirdoct_Callback(hObject, eventdata, handles)
freq = str2num(get(handles.thirdoct,'string'));

set(handles.thirdoctbands,'string',num2str(freq'))

% --- Executes during object creation, after setting all properties.
function thirdoct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thirdoct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit54_Callback(hObject, eventdata, handles)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit54 as text
%        str2double(get(hObject,'String')) returns contents of edit54 as a double


% --- Executes during object creation, after setting all properties.
function edit54_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit55_Callback(hObject, eventdata, handles)
% hObject    handle to edit55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit55 as text
%        str2double(get(hObject,'String')) returns contents of edit55 as a double


% --- Executes during object creation, after setting all properties.
function edit55_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit56_Callback(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit56 as text
%        str2double(get(hObject,'String')) returns contents of edit56 as a double


% --- Executes during object creation, after setting all properties.
function edit56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in thirdoctscreen.
function thirdoctscreen_Callback(hObject, eventdata, handles)
% hObject    handle to thirdoctscreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
global sig
figure(1)
figure(2)
close([1 2])
Data.temp = str2num(get(handles.temp,'string'));
Data.humidity = str2num(get(handles.hum,'string'));
if isempty(Data.positioning.coords)
     errordlg('Please complete positioning and SL screen')
elseif isempty(Data.sourcelevel.SL)
     errordlg('Please complete  SL screen')
else
    
    rmswindow = Data.sourcelevel.rmswindow;
    est_max_dur = str2num(get(handles.edit54,'string'))*Data.samplerate/1000;
    SN = str2num(get(handles.edit55,'string'));
    angmin = str2num(get(handles.edit56,'string'));
    freq = str2num(get(handles.thirdoct,'string'))*1000;
Data.thirdoctave = [];
for n = 1:length(freq)
    A = [];
    B = [];
[B,A] = oct3dsgn(freq(n),Data.samplerate,6);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS95 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS75 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));
    for k = 1:length(Data.emissiontime)
    times = Data.sourcelevel.arrivaltime_at_mic(k,:);
        if sum(isnan(times)) < 1
            bat = Data.positioning.coords(k,:);
            [range(1) minloc] = min(times-rmswindow(k,1));
            [range(2) maxloc] = max(times+rmswindow(k,2));
            diff = times-times(minloc)+1;

            seg = sig(range(1):range(2),:);
            
            compsig = [];
            for i = 1:length(Data.positioning.mikes(:,1));
                Sig = [];
                Sig = seg(diff(i):diff(i)+sum(rmswindow(k,:)),i);
                compsig(:,i) = impcomp(Sig,Data.samplerate,Data.positioning.mikes(i,:),bat,Data.temp,Data.humidity,Data.sourcelevel.mike_vektor(i,:));
                
            end
            
            filtsig = [];
            filtsig = filter(B,A,compsig);
            int = [];
            int75 = [];
            [SL int dur] = rms95_multi(filtsig,'h');
            [SL75 int75 dur75] = rms95_multi(filtsig,'l');
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS95(k,:) = SL;
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).duration95(k,:) = length(int(:,1))/Data.samplerate;
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS75(k,:) = SL75;
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).duration75(k,:) = length(int75(:,1))/Data.samplerate;
    fh2title = sprintf([num2str(freq(n)/1000) 'kHz ' num2str(k) '/' num2str(length(Data.emissiontime))]);
    fh2 = figure(2);
    clf
    plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'or')
    hold on
    plot(Data.positioning.coords(k:end,1),Data.positioning.coords(k:end,2),'*')
    plot(bat(1),bat(2),'ok')
    title(fh2title)
    movegui(fh2,'west')


    prompt = {'valid position','valid calls','95% ?'};
    dlg_title = sprintf([num2str(freq(n)/1000) 'kHz ' num2str(k) '/' num2str(length(Data.emissiontime))]);
    num_lines = 1;
                    if length(int(:,1)) > est_max_dur
                    lvl = 0;
                    chnls = find(SL75./std(filtsig) > SN);
                    chkcol = 'y'; 
                    else lvl = 1;
                    chnls = find(SL./std(filtsig) > SN);
                    chkcol = 'g'; 
                    end
                        if isempty(chnls)
                            validcall = 0;
                        else     validcall = 1;
                        end
                chnls(find(ismember(chnls,str2num(get(handles.exclch,'string'))))) = [];
                chnls(find(ismember(chnls,find(max(abs(seg)) > 0.99)))) = [];
    fh1 = figure(1);
    clf
    movegui(fh1,'east') 
    R = ceil(sqrt(length(Data.positioning.mikes(:,1))));
    C = ceil(length(Data.positioning.mikes(:,1))/R);
                            for i = 1:length(Data.positioning.mikes(:,1))
                                subplot(R,C,i)
                                plot(compsig(:,i))
                                hold on
                                plot(filtsig(:,i),'color',[0.4 0.4 0.4])
                                plot(int(:,i),filtsig(int(:,i),i),'r')
                                plot(int75(:,i),filtsig(int75(:,i),i),'k')
                                if max(abs(seg(:,i))) > 0.99
                                    title('Overload','color','r')
                                else
                                end
                                if ismember(i,chnls)
                                    set(gca,'color',chkcol)
                                else
                                end
                                axis([1 length(compsig(:,1)) -max(max(abs(compsig)))*1.2 max(max(abs(compsig)))*1.2])
                            end

    def = {num2str(validcall),num2str(chnls),num2str(lvl)};

    inp = inputdlg(prompt,dlg_title,num_lines,def);
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).validcalls(k,:)=str2num(inp{1});
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(k,:) = 0;
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(k,str2num(inp{2})) = 1;
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMSlvl(k,:)=str2num(inp{3});

        else
            fh2 = figure(2);
        clf
        movegui(fh2,'west')
        fh1 = figure(1);
        clf
        movegui(fh1,'east')
        prompt = {'valid position','valid calls','95% ?'};
        dlg_title = 'checklist';
        num_lines = 1;
        def = {'0',num2str(1:length(Data.positioning.mikes(:,1))),'1'};

        inp = inputdlg(prompt,dlg_title,num_lines,def);
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).validcalls(k,:)=str2num(inp{1});
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(k,str2num(inp{2})) = 1;
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMSlvl(k,:)=str2num(inp{3});
        end
    end

close([fh1 fh2])

for i = 1:length(Data.emissiontime)
    if Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMSlvl(i) == 1
        RMSfin(i,:) = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS95(i,:);
    else RMSfin(i,:) = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS75(i,:);
    end
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,:) = 94+20*log10(RMSfin(i,:)./Data.sourcelevel.calibration');
    if Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).validcalls(i) == 0
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,:) = NaN;
    else
    end
end   
end
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist==0)) = NaN;
[val loc] = max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).SL,[],2);
    
for i = 1:length(Data.emissiontime)
    vec = Data.positioning.coords(i,:)-Data.positioning.mikes(loc(i),:);
[T P dist(i)] = cart2sph(vec(1),vec(2),vec(3));
end 
dist(isnan(val)) = [];
val(isnan(val)) = [];
if isempty(val)
    axes(handles.axes39)
    cla
    text(0.2,0.2,'No valid values','color','r','fontweight','bold','fontsize',18)
elseif mean(Data.sourcelevel.calibration) == 1
    axes(handles.axes39)
    cla
    plot(dist,val,'*')
    hold on
    text(0.5,mean(val),'No calibration loaded','color','r','fontweight','bold','fontsize',18)
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
else
    axes(handles.axes39)
    cla
    plot(dist,val,'*')
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
end
Data.thirdoctave.rmswindow = rmswindow;
Data.thirdoctave.SignalNoiseThreshold = SN;
Data.thirdoctave.durationThreshold = est_max_dur;
end

% --- Executes on button press in thirdoctcalc.
function thirdoctcalc_Callback(hObject, eventdata, handles)
% hObject    handle to thirdoctcalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
global sig
figure(1)
figure(2)
close([1 2])
Data.temp = str2num(get(handles.temp,'string'));
Data.humidity = str2num(get(handles.hum,'string'));
if isempty(Data.positioning.coords)
     errordlg('Please complete positioning and SL screen')
elseif isempty(Data.sourcelevel.SL)
     errordlg('Please complete  SL screen')
else
    rmswindow = Data.sourcelevel.rmswindow;
    est_max_dur = str2num(get(handles.edit54,'string'))*Data.samplerate/1000;
    SN = str2num(get(handles.edit55,'string'));
    angmin = str2num(get(handles.edit56,'string'));
    freq = str2num(get(handles.thirdoct,'string'))*1000;
  Data.thirdoctave = [];
for n = 1:length(freq)
[B(n,:),A(n,:)] = oct3dsgn(freq(n),Data.samplerate,6);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS95 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS75 = zeros(length(Data.emissiontime),length(Data.positioning.mikes(:,1)));
    for k = 1:length(Data.emissiontime)
    times = Data.sourcelevel.arrivaltime_at_mic(k,:);
        if sum(isnan(times)) < 1
            bat = Data.positioning.coords(k,:);
            [range(1) minloc] = min(times-rmswindow(k,1));
            [range(2) maxloc] = max(times+rmswindow(k,2));
            diff = times-times(minloc)+1;

            seg = sig(range(1):range(2),:);
            compsig = [];
            for i = 1:length(Data.positioning.mikes(:,1));
                Sig = [];
                Sig = seg(diff(i):diff(i)+sum(rmswindow(k,:)),i);
                compsig(:,i) = impcomp(Sig,Data.samplerate,Data.positioning.mikes(i,:),bat,Data.temp,Data.humidity,Data.sourcelevel.mike_vektor(i,:));

            end
            filtsig = [];
            filtsig = filter(B(n,:),A(n,:),compsig);
            int = [];
            int75 = [];
            [SL int dur] = rms95_multi(filtsig,'h');
            [SL75 int75 dur75] = rms95_multi(filtsig,'l');
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS95(k,:) = SL;
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).duration95(k,:) = length(int(:,1))/Data.samplerate;
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS75(k,:) = SL75;
            Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).duration75(k,:) = length(int75(:,1))/Data.samplerate;
    fh2title = sprintf([num2str(freq(n)/1000) 'kHz ' num2str(k) '/' num2str(length(Data.emissiontime))]);
    fh2 = figure(2);
    clf
    plot(Data.positioning.mikes(:,1),Data.positioning.mikes(:,2),'or')
    hold on
    plot(Data.positioning.coords(k:end,1),Data.positioning.coords(k:end,2),'*')
    plot(bat(1),bat(2),'ok')
    title(fh2title)
    movegui(fh2,'west')


    
                    if length(int(:,1)) > est_max_dur
                    lvl = 0;
                    chnls = find(SL75./std(filtsig) > SN);
                    chkcol = 'y'; 
                    else lvl = 1;
                    chnls = find(SL./std(filtsig) > SN);
                    chkcol = 'g'; 
                    end
                        if isempty(chnls)
                            validcall = 0;
                        else     validcall = 1;
                        end
                chnls(find(ismember(chnls,str2num(get(handles.exclch,'string'))))) = [];
                chnls(find(ismember(chnls,find(max(abs(seg)) > 0.99)))) = [];
    fh1 = figure(1);
    clf
    movegui(fh1,'east') 
    R = ceil(sqrt(length(Data.positioning.mikes(:,1))));
    C = ceil(length(Data.positioning.mikes(:,1))/R);
                            for i = 1:length(Data.positioning.mikes(:,1))
                                subplot(R,C,i)
                                plot(compsig(:,i))
                                hold on
                                plot(filtsig(:,i),'color',[0.4 0.4 0.4])
                                plot(int(:,i),filtsig(int(:,i),i),'r')
                                plot(int75(:,i),filtsig(int75(:,i),i),'k')
                                if max(abs(seg(:,i))) > 0.99
                                title('Overload','color','r')
                                else
                                end
                                if ismember(i,chnls)
                                    set(gca,'color',chkcol)
                                else
                                end
                                axis([1 length(compsig(:,1)) -max(max(abs(compsig)))*1.2 max(max(abs(compsig)))*1.2])
                            end

    
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).validcalls(k,:)=validcall;
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(k,:) = 0;
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(k,chnls) = 1;
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMSlvl(k,:)=lvl;

        else
            fh2 = figure(2);
        clf
        movegui(fh2,'west')
        fh1 = figure(1);
        clf
        movegui(fh1,'east')
        
        
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).validcalls(k,:)=0;
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(k,:) = 1;
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMSlvl(k,:)=1;
        end
    end
end
close([fh1 fh2])
for n = 1:length(freq)
for i = 1:length(Data.emissiontime)
    if Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMSlvl(i) == 1
        RMSfin(i,:) = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS95(i,:);
    else RMSfin(i,:) = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).RMS75(i,:);
    end
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,:) = 94+20*log10(RMSfin(i,:)./Data.sourcelevel.calibration');
    if Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).validcalls(i) == 0
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,:) = NaN;
    else
    end
end
end  
for n = 1:length(freq)
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist==0)) = NaN;
end

    [val loc] = max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).SL,[],2);
    
for i = 1:length(Data.emissiontime)
    vec = Data.positioning.coords(i,:)-Data.positioning.mikes(loc(i),:);
[T P dist(i)] = cart2sph(vec(1),vec(2),vec(3));
end 
dist(isnan(val)) = [];
val(isnan(val)) = [];
if isempty(val)
    axes(handles.axes39)
    cla
    text(0.2,0.2,'No valid values','color','r','fontweight','bold','fontsize',18)
elseif mean(Data.sourcelevel.calibration) == 1
    axes(handles.axes39)
    cla
    plot(dist,val,'*')
    hold on
    text(0.5,mean(val),'No calibration loaded','color','r','fontweight','bold','fontsize',18)
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
else
    axes(handles.axes39)
    cla
    plot(dist,val,'*')
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
end
Data.thirdoctave.rmswindow = rmswindow;
Data.thirdoctave.SignalNoiseThreshold = SN;
Data.thirdoctave.durationThreshold = est_max_dur;
    
end

% --- Executes on selection change in thirdoctbands.
function thirdoctbands_Callback(hObject, eventdata, handles)
global Data
freq = str2num(get(handles.thirdoct,'string'))*1000;

for i = 1:length(str2num(get(handles.thirdoct,'string')));
    
switch get(handles.thirdoctbands,'Value')   
    case i
        val = [];
        [val loc] = max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).SL,[],2);
for n = 1:length(Data.emissiontime)
    vec = Data.positioning.coords(n,:)-Data.positioning.mikes(loc(n),:);
[T P dist(n)] = cart2sph(vec(1),vec(2),vec(3));
end 
dist(isnan(val)) = [];
val(isnan(val)) = [];

if isempty(val)
    axes(handles.axes39)
    cla
    text(0.2,0.2,'No valid values','color','r','fontweight','bold','fontsize',18)
    axis([0 1 0 1])
elseif mean(Data.sourcelevel.calibration) == 1
    axes(handles.axes39)
    cla
    plot(dist,val,'*')
    hold on
    text(0.5,mean(val),'No calibration loaded','color','r','fontweight','bold','fontsize',18)
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
else
    axes(handles.axes39)
    cla
    plot(dist,val,'*')
    axis([0 ceil(max(dist)) round(min(val))-6 round(max(val))+6])
end   
        if isfield(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])),'horizontalCheck')
a = find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).horizontalCheck);
b = find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).verticalCheck);
HA = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).horizontalang(a,:).*180/pi;
HP = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).horizontalSL(a,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).horizontalSL(a,:),[],2)*ones(1,length(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).horizontalang(1,:)));
VA = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).verticalang(b,:).*180/pi;
VP = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).verticalSL(b,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).verticalSL(b,:),[],2)*ones(1,length(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(i)/1000)])).verticalang(1,:)));

axes(handles.axes35)
cla
polar_plot(HA(:),HP(:),[],[],[],'*','b')
axis([-33 33 0 33])
pbaspect([2,1,1])
set(handles.axes35,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')

axes(handles.axes37)
cla
polar_plot(-VA(:),VP(:),[],[],90,'*','b')
axis([0 33 -33 33])
pbaspect([1,2,1])
set(handles.axes37,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')    
   

        else
            
        end
        
    end
end
% --- Executes during object creation, after setting all properties.
function thirdoctbands_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thirdoctbands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in speccall.
function speccall_Callback(hObject, eventdata, handles)
global Data
global sig
rms1 = str2num(get(handles.rms1,'string'))*Data.samplerate/1000;
rms2 = str2num(get(handles.rms2,'string'))*Data.samplerate/1000;
ch = get(handles.specch,'value');
for i = 1:length(Data.emissiontime);
switch get(handles.speccall,'Value')   
    case i
    int = Data.sourcelevel.arrivaltime_at_mic(i,ch)-rms1:Data.sourcelevel.arrivaltime_at_mic(i,ch)+rms2;
    axes(handles.axes33)
    cla
    spectrumplot(sig(int,ch),Data.samplerate)
    axis([0 Data.samplerate/2000 -60 60])
    set(gca,'ytick',-60:20:0)  
    axes(handles.axes40)
    ti = linspace(0,(rms1+rms2)*1000/Data.samplerate,length(int));
    plot(ti,sig(int,ch))
    box off
    set(gca,'ycolor','w','ytick',[])
    axis([0 ti(end) -max(abs(sig(int,ch)))*1.1 max(abs(sig(int,ch)))*1.1])
    axes(handles.axes41)
    img_spec(sig(int,ch),128,120,1024,Data.samplerate/1000,50)
    box off
    
end
end

% --- Executes during object creation, after setting all properties.
function speccall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speccall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in thirdoctdirscreen.
function thirdoctdirscreen_Callback(hObject, eventdata, handles)
global sig
global Data

freq = str2num(get(handles.thirdoct,'string'))*1000;
anglim = str2num(get(handles.edit56,'string'));
for n = 1:length(freq)
for i = 1:length(Data.emissiontime)
    [h(i,:) v(i,:)] = angcalc(Data.positioning.coords(i,:),Data.positioning.mikes);
    hm = [];
    hm = Data.horizontalmikes(ismember(Data.horizontalmikes,find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(i,:))));
        if isempty(hm)
        aim_h(i) = NaN;
        else
        aim_h(i) = polybeamaim(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,hm),h(i,hm));
        end
    
    vm = [];
    vm = Data.verticalmikes(ismember(Data.verticalmikes,find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(i,:))));
        if isempty(vm)
        aim_v(i) = NaN;
        else
        aim_v(i) = polybeamaim(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,vm),v(i,vm));
        end
end


Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalang = h(:,Data.horizontalmikes)-aim_h'*ones(1,length(Data.horizontalmikes));
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalang = v(:,Data.verticalmikes)-aim_v'*ones(1,length(Data.verticalmikes));
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalSL = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(:,Data.horizontalmikes);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalSL = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(:,Data.verticalmikes);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalaim = aim_h(:);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalaim = aim_v(:);

figure(1)
figure(2)
fh2 = figure(2);
clf
movegui(fh2,'east')
fh1 = figure(1);
clf
movegui(fh1,'west')

hor_ind = find(ismember(Data.horizontalmikes,Data.verticalmikes));
vert_ind = find(ismember(Data.verticalmikes,Data.horizontalmikes));


for i = 1:length(Data.emissiontime)
    ha = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalang(i,:).*180/pi;
    hp = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalSL(i,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalSL(i,:));
    va = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalang(i,:).*180/pi;
    vp = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalSL(i,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalSL(i,:));
    if mean(isnan(ha)) == 1 || mean(isnan(hp)) == 1 || mean(isnan(va)) == 1 || mean(isnan(vp)) == 1
        figure(1)
        clf
        plot([-anglim -anglim],[1 3],'--w','linewidth',2)
        plot([anglim anglim],[1 3],'--w','linewidth',2)
        
        figure(2)
        clf
        plot([1 3],[-anglim -anglim],'--w','linewidth',2)
        plot([1 3],[anglim anglim],'--w','linewidth',2)
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalCheck(i,:) = 0;
        Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalCheck(i,:) = 0;
    else
    figure(1)
    clf
    plot(ha,hp,'*','markersize',10)
    hold on
    plot(ha(hor_ind),hp(hor_ind),'ok','markersize',10)
    plot([-anglim -anglim],[1 3],'--w','linewidth',2)
    plot([anglim anglim],[1 3],'--w','linewidth',2)
    
    figure(2)
    clf
    plot(vp,va,'*','markersize',10)
    hold on
    plot(vp(vert_ind),va(vert_ind),'ok','markersize',10)
    plot([1 3],[-anglim -anglim],'--w','linewidth',2)
    plot([1 3],[anglim anglim],'--w','linewidth',2)
   
    if isnan(aim_v(i)) || isnan(aim_h(i))
    hor_check = 0;
    vert_check = 0;
    else
        if abs(va(vert_ind)) < anglim
        hor_check = 1;
        figure(1)
        set(gca,'color','g')
    else hor_check = 0;
        figure(1)
        set(gca,'color','r')
    end
    
    if abs(ha(hor_ind)) < anglim
        vert_check = 1;
        figure(2)
        set(gca,'color','g')
    else vert_check = 0;
        figure(2)
        set(gca,'color','r')
    end
    end
    prompt = {'valid horizontal','valid vertical'};
    dlg_title = ['Beam ' num2str(i) '/' num2str(length(Data.emissiontime))];
    num_lines = 1;
    def = {num2str(hor_check),num2str(vert_check)};
    inp = inputdlg(prompt,dlg_title,num_lines,def);
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalCheck(i,:) = str2num(inp{1});
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalCheck(i,:) = str2num(inp{2});
    end  
    
end   
end
close([fh1 fh2])

a = find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalCheck);
b = find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalCheck);
HA = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalang(a,:).*180/pi;
HP = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalSL(a,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalSL(a,:),[],2)*ones(1,length(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalang(1,:)));
VA = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalang(b,:).*180/pi;
VP = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalSL(b,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalSL(b,:),[],2)*ones(1,length(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalang(1,:)));

axes(handles.axes35)
cla
polar_plot(HA(:),HP(:),[],[],[],'*','b')
axis([-33 33 0 33])
pbaspect([2,1,1])
set(handles.axes35,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')

axes(handles.axes37)
cla
polar_plot(-VA(:),VP(:),[],[],90,'*','b')
axis([0 33 -33 33])
pbaspect([1,2,1])
set(handles.axes37,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')    
   
 


% --- Executes on button press in thirdoctdircalc.
function thirdoctdircalc_Callback(hObject, eventdata, handles)
global sig
global Data

freq = str2num(get(handles.thirdoct,'string'))*1000;
anglim = str2num(get(handles.edit56,'string'));
for n = 1:length(freq)
for i = 1:length(Data.emissiontime)
    [h(i,:) v(i,:)] = angcalc(Data.positioning.coords(i,:),Data.positioning.mikes);
    hm = [];
    hm = Data.horizontalmikes(ismember(Data.horizontalmikes,find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(i,:))));
        if isempty(hm)
        aim_h(i) = NaN;
        else
        aim_h(i) = polybeamaim(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,hm),h(i,hm));
        end
    
    vm = [];
    vm = Data.verticalmikes(ismember(Data.verticalmikes,find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).chklist(i,:))));
        if isempty(vm)
        aim_v(i) = NaN;
        else
        aim_v(i) = polybeamaim(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(i,vm),v(i,vm));
        end
end


Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalang = h(:,Data.horizontalmikes)-aim_h'*ones(1,length(Data.horizontalmikes));
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalang = v(:,Data.verticalmikes)-aim_v'*ones(1,length(Data.verticalmikes));
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalSL = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(:,Data.horizontalmikes);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalSL = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).SL(:,Data.verticalmikes);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalaim = aim_h(:);
Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalaim = aim_v(:);

figure(1)
figure(2)
fh2 = figure(2);
clf
movegui(fh2,'east')
fh1 = figure(1);
clf
movegui(fh1,'west')

hor_ind = find(ismember(Data.horizontalmikes,Data.verticalmikes));
vert_ind = find(ismember(Data.verticalmikes,Data.horizontalmikes));


for i = 1:length(Data.emissiontime)
    ha = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalang(i,:).*180/pi;
    hp = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalSL(i,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalSL(i,:));
    va = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalang(i,:).*180/pi;
    vp = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalSL(i,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalSL(i,:));
    figure(1)
    clf
    plot(ha,hp,'*','markersize',10)
    hold on
    plot(ha(hor_ind),hp(hor_ind),'ok','markersize',10)
    plot([-anglim -anglim],[1 3],'--w','linewidth',2)
    plot([anglim anglim],[1 3],'--w','linewidth',2)
    
    figure(2)
    clf
    plot(vp,va,'*','markersize',10)
    hold on
    plot(vp(vert_ind),va(vert_ind),'ok','markersize',10)
    plot([1 3],[-anglim -anglim],'--w','linewidth',2)
    plot([1 3],[anglim anglim],'--w','linewidth',2)
   
    if isnan(aim_v(i)) || isnan(aim_h(i))
    hor_check = 0;
    vert_check = 0;
    else
        if abs(va(vert_ind)) < anglim
        hor_check = 1;
        figure(1)
        set(gca,'color','g')
        else hor_check = 0;
        figure(1)
        set(gca,'color','r')
        end
    
    if abs(ha(hor_ind)) < anglim
        vert_check = 1;
        figure(2)
        set(gca,'color','g')
    else vert_check = 0;
        figure(2)
        set(gca,'color','r')
    end
    end
%     prompt = {'valid horizontal','valid vertical'};
%     dlg_title = ['Beam ' num2str(i) '/' num2str(length(Data.emissiontime))];
%     num_lines = 1;
%     def = {num2str(hor_check),num2str(vert_check)};
%     inp = inputdlg(prompt,dlg_title,num_lines,def);
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).horizontalCheck(i,:) = hor_check;
    Data.thirdoctave.(sprintf(['kHz_' num2str(freq(n)/1000)])).verticalCheck(i,:) = vert_check;
    
    
end   
end
close([fh1 fh2])

a = find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalCheck);
b = find(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalCheck);
HA = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalang(a,:).*180/pi;
HP = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalSL(a,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalSL(a,:),[],2)*ones(1,length(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).horizontalang(1,:)));
VA = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalang(b,:).*180/pi;
VP = Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalSL(b,:)-max(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalSL(b,:),[],2)*ones(1,length(Data.thirdoctave.(sprintf(['kHz_' num2str(freq(1)/1000)])).verticalang(1,:)));

axes(handles.axes35)
cla
polar_plot(HA(:),HP(:),[],[],[],'*','b')
axis([-33 33 0 33])
pbaspect([2,1,1])
set(handles.axes35,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')

axes(handles.axes37)
cla
polar_plot(-VA(:),VP(:),[],[],90,'*','b')
axis([0 33 -33 33])
pbaspect([1,2,1])
set(handles.axes37,'xtick',[],'ytick',[],'ycolor','w','xcolor','w')    
   


% --- Executes on selection change in specch.
function specch_Callback(hObject, eventdata, handles)
global Data
global sig
rms1 = str2num(get(handles.rms1,'string'))*Data.samplerate/1000;
rms2 = str2num(get(handles.rms2,'string'))*Data.samplerate/1000;
call = get(handles.speccall,'value');
for i = 1:length(Data.positioning.mikes(:,1));
switch get(handles.specch,'Value')   
    case i
    int = Data.sourcelevel.arrivaltime_at_mic(call,i)-rms1:Data.sourcelevel.arrivaltime_at_mic(call,i)+rms2;
    axes(handles.axes33)
    cla
    spectrumplot(sig(int,i),Data.samplerate)
    axis([0 Data.samplerate/2000 -60 60])
    set(gca,'ytick',-60:20:0)
    axes(handles.axes40)
    ti = linspace(0,(rms1+rms2)*1000/Data.samplerate,length(int));
    plot(ti,sig(int,i))
    box off
    set(gca,'ycolor','w','ytick',[])
    axis([0 ti(end) -max(abs(sig(int,i)))*1.1 max(abs(sig(int,i)))*1.1])
    axes(handles.axes41)
    img_spec(sig(int,i),128,120,1024,Data.samplerate/1000,50)
    box off
end
end


% --- Executes during object creation, after setting all properties.
function specch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function exclch_Callback(hObject, eventdata, handles)
% hObject    handle to exclch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exclch as text
%        str2double(get(hObject,'String')) returns contents of exclch as a double


% --- Executes during object creation, after setting all properties.
function exclch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exclch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rmsmin_Callback(hObject, eventdata, handles)
% hObject    handle to rmsmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmsmin as text
%        str2double(get(hObject,'String')) returns contents of rmsmin as a double


% --- Executes during object creation, after setting all properties.
function rmsmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmsmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in screencalls.
function screencalls_Callback(hObject, eventdata, handles)
% hObject    handle to screencalls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data
global sig
global fs
checkcalls
uiwait
set(handles.peaks,'String',num2str(length(Data.emissiontime)))
set(handles.peaktime,'String',num2str(Data.emissiontime'/fs*1000))


% --- Executes on button press in water.
function water_Callback(hObject, eventdata, handles)
% hObject    handle to water (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of water

function soundspeed_Callback(hObject, eventdata, handles)
