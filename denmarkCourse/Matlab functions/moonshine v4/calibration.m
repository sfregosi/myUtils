function varargout = calibration(varargin)
% LOGCALIBRATION M-file for logcalibration.fig
% Last Modified by GUIDE v2.5 04-Nov-2009 20:38:37
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibration_OpeningFcn, ...
                   'gui_OutputFcn',  @calibration_OutputFcn, ...
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


% --- Executes just before logcalibration is made visible.
function calibration_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = calibration_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function loadcalibration_Callback(hObject, eventdata, handles)
global siglist
global fs
global peakvalue
global savepeak
a = pwd;
% cd('/Volumes/ARCHIMEDES/a-Universitets lir/Artikler/Spatial mem/')
[name,path]=uigetfile('*.wav','load calibration files','MultiSelect','on');
name = sort(name);
savepeak = [];

[~,Fs] = audioread([path name{1}]);

cd(a)

for i = 1:length(name)
    
[sig fs] = audioread([path name{i}],[1 Fs]);
siglist(1,i).sig = sig(:,i);
siglist(1,i).name = name{i};
clear 'sig'
end
set(handles.sampledelay,'String',num2str(round(length(siglist(1,1).sig)/100)));
set(handles.slider,'Value',1);
figure(1);
clf
x = str2num(get(handles.sampledelay,'String'));
for n = 1:length(siglist(1,:))
subplot(3,4,n)
plot(siglist(1,n).sig(x:x+fs/1000+fs/5000))
axis([0 fs/1000+fs/5000 -1 1])
[pmax locmax] = max(siglist(1,n).sig(x:x+fs/1000+fs/5000));
[pmin locmin] = min(siglist(1,n).sig(x:x+fs/1000+fs/5000));
hold on
plot(locmax,pmax,'or')
plot(locmin,pmin,'ok')
peakvalue(n) = (abs(pmax)+abs(pmin))/2;
end
hold off
set(handles.peak_dB,'String',num2str(peakvalue'))

function logcalibration_Callback(hObject, eventdata, handles)
global savepeak
Peakvalue = mean(savepeak)';
Peakvalue = Peakvalue / sqrt(2);
prompts = {'Channels'};
title = 'Channels';
lineno = 1;
channel.var = num2str(Peakvalue');
defaultanswers = {channel.var};
inp = inputdlg(prompts,title,lineno,defaultanswers);
actual_channels=str2num(inp{1})';

[fname,pname]=uiputfile('*.txt','Save as...');
if ischar(fname); save([pname fname],'actual_channels','-ascii');end

function sampledelay_Callback(hObject, eventdata, handles)

function sampledelay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function peak_dB_Callback(hObject, eventdata, handles)

function peak_dB_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function slider_Callback(hObject, eventdata, handles)
global siglist
global fs
global peakvalue
sliderValue = get(handles.slider,'Value');
if (isempty(sliderValue) || sliderValue < 1)
    set(handles.slider,'Value',1);
    set(handles.sampledelay,'String',num2str(round(length(siglist(1,1).sig)/100)))
elseif sliderValue > 99
    set(handles.slider,'Value',99);
    set(handles.sampledelay,'String',num2str(round(99*length(siglist(1,1).sig)/100)))
else
    set(handles.slider,'Value',sliderValue)
    set(handles.sampledelay,'String',num2str(round(sliderValue*length(siglist(1,1).sig)/100)));    
end

figure(1);
clf
x = str2num(get(handles.sampledelay,'String'))-(fs/1000-1);
for n = 1:length(siglist(1,:))
subplot(3,4,n)
plot(siglist(1,n).sig(x:x+fs/1000+fs/5000))
axis([0 fs/1000+fs/5000 -1 1])
[pmax locmax] = max(siglist(1,n).sig(x:x+fs/1000+fs/5000));
[pmin locmin] = min(siglist(1,n).sig(x:x+fs/1000+fs/5000));
hold on
plot(locmax,pmax,'or')
plot(locmin,pmin,'ok')
peakvalue(n) = (abs(pmax)+abs(pmin))/2;
end
hold off
set(handles.peak_dB,'String',num2str(peakvalue'))

function slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function logvalues_Callback(hObject, eventdata, handles)
global peakvalue
global savepeak
savepeak = [savepeak;peakvalue];







