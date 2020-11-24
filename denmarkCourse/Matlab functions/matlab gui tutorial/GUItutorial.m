function varargout = GUItutorial(varargin)
% GUITUTORIAL M-file for GUItutorial.fig
%      GUITUTORIAL, by itself, creates a new GUITUTORIAL or raises the existing
%      singleton*.
%
%      H = GUITUTORIAL returns the handle to a new GUITUTORIAL or the handle to
%      the existing singleton*.
%
%      GUITUTORIAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUITUTORIAL.M with the given input arguments.
%
%      GUITUTORIAL('Property','Value',...) creates a new GUITUTORIAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUItutorial_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUItutorial_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUItutorial

% Last Modified by GUIDE v2.5 12-Jun-2013 12:53:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUItutorial_OpeningFcn, ...
                   'gui_OutputFcn',  @GUItutorial_OutputFcn, ...
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


% --- Executes just before GUItutorial is made visible.
function GUItutorial_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUItutorial (see VARARGIN)

% Choose default command line output for GUItutorial
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUItutorial wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUItutorial_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function loadwav_Callback(hObject, eventdata, handles)
% hObject    handle to loadwav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sig fs
[name path] = uigetfile('*.wav;*.WAV','load sound file');
[sig fs] = audioread([path name]);
t = (0:length(sig)-1)*1000/fs;
handles.axes1; %calls the axes that you drew earlier
plot(t,sig)
xlabel('Time (ms)')
ylabel('Pressure (Pa)')
axis([0 t(end) -max(abs(sig))*1.1 max(abs(sig))*1.1])



function sensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sensitivity as text
%        str2double(get(hObject,'String')) returns contents of sensitivity as a double
handles = guidata(hObject);
calc_Callback(hObject, eventdata, handles)
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function sensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cliplvl_Callback(hObject, eventdata, handles)
% hObject    handle to cliplvl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cliplvl as text
%        str2double(get(hObject,'String')) returns contents of cliplvl as a double
handles = guidata(hObject);
calc_Callback(hObject, eventdata, handles)
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function cliplvl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cliplvl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp_Callback(hObject, eventdata, handles)
% hObject    handle to amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp as text
%        str2double(get(hObject,'String')) returns contents of amp as a double
handles = guidata(hObject);
calc_Callback(hObject, eventdata, handles)
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calc.
function calc_Callback(hObject, eventdata, handles)
% hObject    handle to calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sig fs
handles = guidata(hObject);
S = str2num(get(handles.sensitivity,'string'));
c = str2num(get(handles.cliplvl,'string'));
A = str2num(get(handles.amp,'string'));

s = 10^(S/20+6);
a = 10^(A/20);
WAVClippingLevel = c/(a*s);
Sig = WAVClippingLevel * sig;
t = (0:length(sig)-1)*1000/fs;
handles.axes1;
cla %clears the axis
plot(t,Sig)
axis([0 t(end) -max(abs(Sig))*1.1 max(abs(Sig))*1.1])


peak = round(20*log10(max(abs(Sig))/1e-6));
set(handles.peak,'String',num2str(peak))


csig = cumsum(Sig.^2)/max(cumsum(Sig.^2));
int95 = find(csig > 0.025 & csig < 0.975);
rms95 = round(20*log10(sqrt(mean((Sig(int95)).^2))/1e-6));
set(handles.RMS95,'String',num2str(rms95))


thr = str2num(get(handles.ENVdur,'string'));
env = abs(hilbert(Sig));
inte = find(env > (max(env)*10^(thr/20)));
intenv = inte(1):inte(end);
rmsenv = round(20*log10(sqrt(mean((Sig(intenv)).^2))/1e-6));
set(handles.RMShilbert,'String',num2str(rmsenv))
handles.axes1;
hold on
plot(t,env,'color',[0.6 0.6 0.6])


if length(int95) > length(intenv)
handles.axes1;
plot(t(int95),Sig(int95),'k')
plot(t(intenv),Sig(intenv),'r')
else
handles.axes1;
plot(t(intenv),Sig(intenv),'r')
plot(t(int95),Sig(int95),'k')
end
guidata(hObject,handles)


% --- Executes on button press in eng95.
function eng95_Callback(hObject, eventdata, handles)
% hObject    handle to eng95 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eng95


% --- Executes on button press in hilb.
function hilb_Callback(hObject, eventdata, handles)
% hObject    handle to hilb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hilb




function ENVdur_Callback(hObject, eventdata, handles)
% hObject    handle to ENVdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ENVdur as text
%        str2double(get(hObject,'String')) returns contents of ENVdur as a double
handles = guidata(hObject);
calc_Callback(hObject, eventdata, handles)
guidata(hObject,handles)
