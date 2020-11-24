function varargout = checkcalls(varargin)
%CHECKCALLS M-file for checkcalls.fig
%      CHECKCALLS, by itself, creates a new CHECKCALLS or raises the existing
%      singleton*.
%
%      H = CHECKCALLS returns the handle to a new CHECKCALLS or the handle to
%      the existing singleton*.
%
%      CHECKCALLS('Property','Value',...) creates a new CHECKCALLS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to checkcalls_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CHECKCALLS('CALLBACK') and CHECKCALLS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CHECKCALLS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help checkcalls

% Last Modified by GUIDE v2.5 29-Aug-2013 11:39:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @checkcalls_OpeningFcn, ...
                   'gui_OutputFcn',  @checkcalls_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before checkcalls is made visible.
function checkcalls_OpeningFcn(hObject, eventdata, handles, varargin)
global sig
global fs
global Data
global ch
global Xl
axes(handles.axes3)
set(gca,'xtick',[],'ytick',[],'color','none')
box off
ch = Data.positioning.center_channel;
t = (0:length(sig)-1)*1000/fs;
axes(handles.axes1)
plot(t,sig(:,ch))
if Data.emissiontime(1)*1000/fs < 500
    Xl = 0;
else
    Xl = Data.emissiontime(1)*1000/fs - 500;;
end
axis([Xl Xl+1000 min(sig(:,ch))*1.2 max(sig(:,ch))*1.2])
axes(handles.axes3)
plot(Data.emissiontime(:)*1000/fs,zeros(length(Data.emissiontime),1),'r*')
hold on
plot(Data.emissiontime(1)*1000/fs,0,'ok')
axis([Xl Xl+1000 -1 1])
set(gca,'xtick',[],'ytick',[],'color','none')
box off

axes(handles.axes2)
T = Data.emissiontime(1)-3e-3*fs:Data.emissiontime(1)+7e-3*fs;
plot(T*1000/fs,sig(T,ch))
hold on
plot((T(1)+(3e-3*fs))*1000/fs,min(sig(T,ch)),'r*')
axis([T(1)*1000/fs T(end)*1000/fs min(sig(T,ch))*1.2 max(sig(T,ch))*1.2])
handles.var = 1:length(Data.emissiontime);
set(handles.callnr,'string', handles.var);
set(handles.callnr,'Value',1);

handles.output = hObject;
guidata(hObject, handles);
% UIWAIT makes checkcalls wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = checkcalls_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in nextcall.
function nextcall_Callback(hObject, eventdata, handles)
global Data
k = get(handles.callnr,'Value');
if k < length(Data.emissiontime)
set(handles.callnr,'Value',k+1);
handles = guidata(hObject);
callnr_Callback(hObject, eventdata, handles)
guidata(hObject,handles)
end


% hObject    handle to nextcall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nocall.
function nocall_Callback(hObject, eventdata, handles)
global Data
k = get(handles.callnr,'Value');
Data.emissiontime(k) = [];
handles.var = 1:length(Data.emissiontime);
set(handles.callnr,'string', handles.var);
if k > length(Data.emissiontime)
    set(handles.callnr,'Value',k-1);
else
    set(handles.callnr,'Value',k);
end
handles = guidata(hObject);
callnr_Callback(hObject, eventdata, handles)
guidata(hObject,handles)
% hObject    handle to nocall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in callnr.
function callnr_Callback(hObject, eventdata, handles)
global Data
global sig
global fs
global ch
global Xl
tz = Data.emissiontime(1);

axes(handles.axes1)
currentview = xlim;
for k = 1:length(Data.emissiontime);
switch get(handles.callnr,'Value')   
    case k
        axes(handles.axes1);
        nodge = (Data.emissiontime(k)-tz)*1000/fs;
        xlim([Xl Xl+1000]+nodge)
        axes(handles.axes3)
        cla
        plot(Data.emissiontime(:)*1000/fs,zeros(length(Data.emissiontime),1),'r*')
        hold on
        plot(Data.emissiontime(k)*1000/fs,0,'ok')
        set(gca,'xtick',[],'ytick',[],'color','none')
        xlim([Xl Xl+1000]+nodge)
        
        axes(handles.axes2)
        cla
        T = Data.emissiontime(k)-3e-3*fs:Data.emissiontime(k)+7e-3*fs;
        plot(T*1000/fs,sig(T,ch))
        hold on
        plot((T(1)+(3e-3*fs))*1000/fs,min(sig(T,ch)),'r*')
        axis([T(1)*1000/fs T(end)*1000/fs min(sig(T,ch))*1.2 max(sig(T,ch))*1.2])
    otherwise
end
end


% --- Executes during object creation, after setting all properties.
function callnr_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closeGUI.
function closeGUI_Callback(hObject, eventdata, handles)
% hObject    handle to closeGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume
close checkcalls
