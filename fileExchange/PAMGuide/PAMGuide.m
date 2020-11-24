% Implements the PAMGuide graphical user interface (GUI)

% This code accompanies the manuscript: 

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright © 2014 The Authors.

% Author: Nathan D. Merchant. Last modified 22 Sep 2014

function varargout = PAMGuide(varargin)
% PAMGUIDE MATLAB code for PAMGuide.fig
%      PAMGUIDE, by itself, creates a new PAMGUIDE or raises the existing
%      singleton*.
%
%      H = PAMGUIDE returns the handle to a new PAMGUIDE or the handle to
%      the existing singleton*.
%
%      PAMGUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PAMGUIDE.M with the given input arguments.
%
%      PAMGUIDE('Property','Value',...) creates a new PAMGUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PAMGuide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PAMGuide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PAMGuide

% Last Modified by GUIDE v2.5 16-Sep-2014 22:53:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PAMGuide_OpeningFcn, ...
                   'gui_OutputFcn',  @PAMGuide_OutputFcn, ...
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


% --- Executes just before PAMGuide is made visible.
function PAMGuide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PAMGuide (see VARARGIN)

% Choose default command line output for PAMGuide
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PAMGuide wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PAMGuide_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in fbv.
function fbv_Callback(hObject, eventdata, handles)
% hObject    handle to fbv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fbv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fbv
fbvval = get(hObject,'Value');
if fbvval == 2
    set(handles.browser,'string','Select folder...')
    
elseif fbvval == 1
    set(handles.browser,'string','Select file...')
    
else
    set(handles.browser,'string','Select file...')
    
end
    

% --- Executes during object creation, after setting all properties.
function fbv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fbv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browser.
function browser_Callback(hObject, eventdata, handles)
% hObject    handle to browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

oldpath = get(hObject,'UserData');    %get previous file path
fbv = get(handles.fbv,'Value');         %get single/batch/viewer selection

switch fbv
    case 1                      %ONE FILE ANALYSIS
if isempty(oldpath) == 0 && length(oldpath) ~= 1
    [ifile,path] = uigetfile(fullfile(oldpath,'*.*'),'Select input audio file...');
    set(hObject,'UserData',path)%record file path for next call
else                            %if batch processing
    [ifile,path] = uigetfile('*.*','Choose input audio file');
    set(hObject,'UserData',path)%record file path for next call
end
fprintf('Loading input file...')
tic                             %Start file-read timer
try                             %Read user-defined audio file, which MATLAB
                                % normalises to +/-1
    [xbit,Fs] = audioread(fullfile(path,ifile),'native');
    xbit = single(xbit);
catch
    try                         %for older MATLAB versions
        [xbit,Fs] = wavread(fullfile(path,ifile));  
        xbit = single(xbit);
    catch
        disp('MATLAB could not read this as an audio file.'),return
    end
end
tock = toc;
disp(['done in ' num2str(tock) ' s.'])
xbit = xbit(:,1);               %In case of multichannel input, selects 
                                %1st channel (use xDIG(:,2) for 2nd, etc.)
%set(handles.RUN,'UserData',xbit)%store audio data
set(handles.filetext,'string',ifile)      
                                %display filename in GUI  
set(handles.textspec,'string','Current filename') 
set(handles.filetext,'userdata',ifile)
                                %store ifile for future use
set(handles.fstext,'string',num2str(Fs))                                  
                                %display Fs for future use
set(handles.xltext,'string',num2str(round(10*length(xbit)/Fs)/10))                                  
                                %display file length for future use
set(handles.htext,'string',num2str(floor(Fs/2)))
                                %set high frequency cit-off to Nyquist
                                clear xbit
    set(handles.text31,'string','File length:')
    set(handles.text29,'visible','on')
    case 2
        ds = uigetdir(cd,'Select target folder...');
        nowd = cd;                          %record current directory
        cd(ds);                             %change to source directory
        files = dir('*.wav');               %get wav filenames in source directory
        files(1).name
        if length(files) < 1;files = dir('*.aif');end
        cd(nowd);                           %return to original directory
        set(handles.filetext,'String',files(1).name)
        ifile = files(1).name;          %sample filename
        path = ds;
try                             %get sample rate
    info = audioinfo(fullfile(path,ifile));
    Fs = info.SampleRate;
catch
    try                         %for older MATLAB versions
        [~,Fs] = wavread(fullfile(path,ifile));  
    catch
        disp('MATLAB could not read this as an audio file.'),return
    end
end
set(handles.fstext,'string',num2str(Fs))                                  
                                %display Fs for future use
set(handles.textspec,'string','Example filename from folder')
set(handles.xltext,'string',[])                                  
                                %clear file length display
set(handles.htext,'string',num2str(floor(Fs/2)))
                                %set high frequency cit-off to Nyquist
set(handles.browser,'UserData',ds)  %store target directory path
set(handles.filetext,'UserData',files(1).name)  
set(handles.RUN,'userdata',files)   %store file list for later
set(handles.text31,'string','Number of files:')
set(handles.text29,'visible','off')
set(handles.xltext,'string',num2str(length(files)))
    case 3
        if isempty(oldpath) == 0 && length(oldpath) ~= 1
        [ifile,path] = uigetfile(fullfile(oldpath,'*.*'),'Select PAMGuide-analysed file...');
        else                           
        [ifile,path] = uigetfile('*.*','Select PAMGuide-analysed file...');
        end
    fprintf('Loading file...'),tic
        try                             
            A = csvread(fullfile(path,ifile));
        catch
        try                        
            A = load(fullfile(path,ifile));
        catch
        disp('MATLAB could not read this as a CSV file.'),return
        end
        end
    tock = toc;
    fprintf(['done in ' num2str(tock) ' s.\n'])
    set(hObject,'UserData',path)%record file path for next call
    set(handles.filetext,'String',ifile)
    set(handles.filetext,'UserData',ifile)
    set(handles.textspec,'string','File loaded to Viewer')
    set(handles.RUN,'UserData',A)
    set(handles.text31,'string','File length:')
    set(handles.text29,'visible','on')
    set(handles.xltext,'string',[])
    set(handles.fstext,'string',[])
end
              

% --- Executes on button press in caltick.
function caltick_Callback(hObject, eventdata, handles)
% hObject    handle to caltick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of caltick
onoff = get(hObject,'Value');
if onoff == 1
    envi = get(handles.domdrop,'Value');
    if envi == 1
        set(handles.text34,'string','1 V/Pa')
        set(handles.text9,'string','Microphone')
    elseif envi == 2
        set(handles.text34,'string','1 V/uPa')
        set(handles.text9,'string','Hydrophone')
    end
    set(handles.domdrop,'Enable','on')
    set(handles.caldrop,'Enable','on')
    set(handles.text5,'Enable','on')
    set(handles.text6,'Enable','on')
    
    ctype = get(handles.caldrop,'Value');
    switch ctype
        case 1
            set(handles.mhtext,'Enable','on')
            set(handles.gtext,'Enable','on')
            set(handles.adctext,'Enable','on')
            set(handles.text9,'Enable','on')
            set(handles.text10,'Enable','on')
            set(handles.text11,'Enable','on')
            set(handles.text12,'Enable','on')
            set(handles.text13,'Enable','on')
            set(handles.text14,'Enable','on')
            set(handles.text33,'Enable','on')
            set(handles.text34,'Enable','on')
        case 2
            set(handles.text7,'Enable','on')
            set(handles.text41,'Enable','on')
            set(handles.text8,'Enable','on')
            set(handles.stext,'Enable','on')
        case 3
            set(handles.text7,'Enable','on')
            set(handles.text41,'Enable','on')
            set(handles.text8,'Enable','on')
            set(handles.stext,'Enable','on')
            set(handles.mhtext,'Enable','on')
            set(handles.text9,'Enable','on')
            set(handles.text10,'Enable','on') 
            set(handles.text33,'Enable','on')
            set(handles.text34,'Enable','on')            
    end
elseif onoff == 0
    set(handles.domdrop,'Enable','off')
    set(handles.caldrop,'Enable','off')
    set(handles.mhtext,'Enable','off')
    set(handles.gtext,'Enable','off')
    set(handles.adctext,'Enable','off')
    set(handles.stext,'Enable','off')
    set(handles.text5,'Enable','off')
    set(handles.text6,'Enable','off')
    set(handles.text7,'Enable','off')
    set(handles.text41,'Enable','off')
    set(handles.text8,'Enable','off')
    set(handles.text9,'Enable','off')
    set(handles.text10,'Enable','off')
    set(handles.text11,'Enable','off')
    set(handles.text12,'Enable','off')
    set(handles.text13,'Enable','off')
    set(handles.text14,'Enable','off')
    set(handles.text33,'Enable','off')
    set(handles.text34,'Enable','off')
end

% --- Executes on selection change in domdrop.
function domdrop_Callback(hObject, eventdata, handles)
% hObject    handle to domdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns domdrop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from domdrop
ddrop = get(hObject,'Value');
if ddrop == 1
    set(handles.text34,'string','1 V/Pa')
    set(handles.text9,'string','Microphone')
elseif ddrop == 2
    set(handles.text34,'string','1 V/uPa')
    set(handles.text9,'string','Hydrophone')
end

% --- Executes during object creation, after setting all properties.
function domdrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to domdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in text11.
function caldrop_Callback(hObject, eventdata, handles)
% hObject    handle to text11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns text11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from text11
    ctype = get(hObject,'Value');
    switch ctype
        case 1
            set(handles.mhtext,'Enable','on')
            set(handles.gtext,'Enable','on')
            set(handles.adctext,'Enable','on')
            set(handles.text9,'Enable','on')
            set(handles.text10,'Enable','on')
            set(handles.text11,'Enable','on')
            set(handles.text12,'Enable','on')
            set(handles.text13,'Enable','on')
            set(handles.text14,'Enable','on')
            set(handles.text33,'Enable','on')
            set(handles.text34,'Enable','on')
            set(handles.text7,'Enable','off')
            set(handles.text41,'Enable','off')
            set(handles.text8,'Enable','off')
            set(handles.stext,'Enable','off')
        case 2
            set(handles.mhtext,'Enable','off')
            set(handles.gtext,'Enable','off')
            set(handles.adctext,'Enable','off')
            set(handles.text9,'Enable','off')
            set(handles.text10,'Enable','off')
            set(handles.text11,'Enable','off')
            set(handles.text12,'Enable','off')
            set(handles.text13,'Enable','off')
            set(handles.text14,'Enable','off')
            set(handles.text33,'Enable','off')
            set(handles.text34,'Enable','off')
            set(handles.text7,'Enable','on')
            set(handles.text7,'string','System')
            set(handles.text41,'Enable','on')
            set(handles.text8,'Enable','on')
            set(handles.stext,'Enable','on')
        case 3
            set(handles.gtext,'Enable','off')
            set(handles.adctext,'Enable','off')
            set(handles.text11,'Enable','off')
            set(handles.text12,'Enable','off')
            set(handles.text13,'Enable','off')
            set(handles.text14,'Enable','off')            
            set(handles.mhtext,'Enable','on')
            set(handles.text9,'Enable','on')
            set(handles.text10,'Enable','on') 
            set(handles.text33,'Enable','on')
            set(handles.text34,'Enable','on') 
            set(handles.text7,'Enable','on')
            set(handles.text7,'string','Recorder')
            set(handles.text41,'Enable','on')
            set(handles.text8,'Enable','on')
            set(handles.stext,'Enable','on')
    end

% --- Executes during object creation, after setting all properties.
function text11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tstick.
function tstick_Callback(hObject, eventdata, handles)
% hObject    handle to tstick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tstick
onoff = get(hObject,'Value');
if onoff == 1
    set(handles.text3,'Enable','on')
    set(handles.tsedit,'Enable','on')
    set(handles.tscheck,'Enable','on')
    set(handles.tstext,'Enable','on')
elseif onoff == 0
    set(handles.text3,'Enable','off')
    set(handles.tsedit,'Enable','off')
    set(handles.tscheck,'Enable','off')
    set(handles.tstext,'Enable','off')
end


function tsedit_Callback(hObject, eventdata, handles)
% hObject    handle to tsedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tsedit as text
%        str2double(get(hObject,'String')) returns contents of tsedit as a double


% --- Executes during object creation, after setting all properties.
function tsedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tsedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tscheck.
function tscheck_Callback(hObject, eventdata, handles)
% hObject    handle to tscheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tstring = get(handles.tsedit,'string');
ifile = get(handles.filetext,'userdata');

if ~isempty(tstring)
    if ~isempty(tstring)             %if time stamp provided
    y = str2double((ifile(tstring == 'y')));    %year
    m = str2double((ifile(tstring == 'm')));    %month
    d = str2double((ifile(tstring == 'd')));    %day
    H = str2double((ifile(tstring == 'H')));    %hour
    M = str2double((ifile(tstring == 'M')));    %minute
    S = str2double((ifile(tstring == 'S')));    %second
    MS = str2double((ifile(tstring == 'F')))/1000;  %millisecond
    if isnan(MS)                    %if no milliseconds defined, MS = 0
        MS = 0;
    end
    try
        tstamp = datenum(y,m,d,H,M,S+MS);               %date in datenum format
        set(handles.tstext,'string',datestr(tstamp,'dd mmm yyyy, HH:MM:SS'))
    catch
        set(handles.tstext,'string','ERROR: Check format')
    end
    end
end


function mhtext_Callback(hObject, eventdata, handles)
% hObject    handle to mhtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mhtext as text
%        str2double(get(hObject,'String')) returns contents of mhtext as a double


% --- Executes during object creation, after setting all properties.
function mhtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mhtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gtext_Callback(hObject, eventdata, handles)
% hObject    handle to gtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gtext as text
%        str2double(get(hObject,'String')) returns contents of gtext as a double


% --- Executes during object creation, after setting all properties.
function gtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function adctext_Callback(hObject, eventdata, handles)
% hObject    handle to adctext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of adctext as text
%        str2double(get(hObject,'String')) returns contents of adctext as a double


% --- Executes during object creation, after setting all properties.
function adctext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to adctext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stext_Callback(hObject, eventdata, handles)
% hObject    handle to stext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stext as text
%        str2double(get(hObject,'String')) returns contents of stext as a double


% --- Executes during object creation, after setting all properties.
function stext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in windrop.
function windrop_Callback(hObject, eventdata, handles)
% hObject    handle to windrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns windrop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from windrop


% --- Executes during object creation, after setting all properties.
function windrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in samdrop.
function samdrop_Callback(hObject, eventdata, handles)
% hObject    handle to samdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns samdrop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from samdrop
sval = get(hObject,'Value');
Fs = str2double(get(handles.fstext,'string'));
winlength = str2double(get(handles.winlength,'string'));
if ~isempty(Fs) && ~isnan(Fs)
if sval == 2 && winlength < 100
    set(handles.winlength,'string',num2str(round(winlength*Fs)))
elseif sval == 1 && winlength > 100
    set(handles.winlength,'string',num2str(winlength/Fs))
end
end

% --- Executes during object creation, after setting all properties.
function samdrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function winlength_Callback(hObject, eventdata, handles)
% hObject    handle to winlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of winlength as text
%        str2double(get(hObject,'String')) returns contents of winlength as a double


% --- Executes during object creation, after setting all properties.
function winlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to winlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function olap_Callback(hObject, eventdata, handles)
% hObject    handle to olap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of olap as text
%        str2double(get(hObject,'String')) returns contents of olap as a double


% --- Executes during object creation, after setting all properties.
function olap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to olap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ltext_Callback(hObject, eventdata, handles)
% hObject    handle to ltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ltext as text
%        str2double(get(hObject,'String')) returns contents of ltext as a double


% --- Executes during object creation, after setting all properties.
function ltext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function htext_Callback(hObject, eventdata, handles)
% hObject    handle to htext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of htext as text
%        str2double(get(hObject,'String')) returns contents of htext as a double


% --- Executes during object creation, after setting all properties.
function htext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to htext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotdrop.
function plotdrop_Callback(hObject, eventdata, handles)
% hObject    handle to plotdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotdrop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotdrop

% --- Executes during object creation, after setting all properties.
function plotdrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function caldrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to caldrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RUN.
function RUN_Callback(hObject, eventdata, handles)
% hObject    handle to RUN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Fs = str2num(get(handles.fstext,'string'));
atypec = cellstr(get(handles.atypedrop,'String'));
atypeid = get(handles.atypedrop,'Value');
atype = atypec{atypeid};
plottypec = cellstr(get(handles.plotdrop,'String'));
plottypeid = get(handles.plotdrop,'Value');
plottype = plottypec{plottypeid};
enviid = get(handles.domdrop,'Value');
switch enviid
    case 1,envi = 'Air';
    case 2, envi = 'Wat';
end
calib = get(handles.caltick,'Value');
if calib == 1
    calstring = 'Abs';
    ctypeid = get(handles.caldrop,'Value');
    switch ctypeid
        case 1,ctype = 'TS';
        case 2,ctype = 'EE';
        case 3,ctype = 'RC';
    end
    Si = str2double(get(handles.stext,'string'));
    Mh = str2double(get(handles.mhtext,'string'));
    G = str2double(get(handles.gtext,'string'));
    vADC = str2double(get(handles.adctext,'string'));
else
    calstring = 'Rel';
    ctype = [];
    Si = [];
    Mh = [];
    G = [];
    vADC = [];
end

r  = (str2double(get(handles.olap,'string')))/100;

ssam = get(handles.samdrop,'Value');
switch ssam
    case 1
        N = round(str2double(get(handles.winlength,'string'))*Fs);
    case 2
        N = str2double(get(handles.winlength,'string'));
end
winc = cellstr(get(handles.windrop,'string'));
winid = get(handles.windrop,'Value');
winname = winc{winid};
if strcmp(winname,'Rectangular'),winname = 'None';end
lcut = str2double(get(handles.ltext,'string'));
hcut = str2double(get(handles.htext,'string'));
tstick = get(handles.tstick,'Value');
if tstick == 1
    tstring = get(handles.tsedit,'string');
else
    tstring = [];
end
writeout = get(handles.writeout,'Value');
wtick = get(handles.wtick,'value');
wnum = str2double(get(handles.wstring,'string'));
secfacdrop = get(handles.secfacdrop,'value');
if wtick == 1
    if secfacdrop == 1
        if strcmp(atype,'TOLf')
            welch = wnum*(Fs/N);
        else
            welch = wnum*(Fs/N)/(1-r);  %ratio of new to original window lengths in Welch method
        end
    elseif secfacdrop == 2
        if wnum == 1
            welch = [];
        else
            welch = wnum;
        end
    end
else
    welch = [];
end
chunktick = get(handles.chunktick,'Value');
if chunktick == 1
    chunksize = str2double(get(handles.chunksize,'string'));
else
    chunksize = [];
end
linlog = get(handles.linlog,'value');
switch linlog
    case 1
        linlog = 0;
    case 2
        linlog = 1;
end

fbv = get(handles.fbv,'Value');
switch fbv
    case 1
        ifile = get(handles.filetext,'userdata');
        path = get(handles.browser,'userdata');
        metadir = []; batch = 0;
        PG_Func(ifile,path,atype,plottype,envi,calib,ctype,Fs,Si,Mh,G,vADC,r,N,winname,lcut,hcut,tstring,metadir,writeout,1,welch,chunksize,batch,linlog);
    case 2
        path = get(handles.browser,'userdata');
        metadir = ['PAMGuide_Batch_' atype '_' calstring '_' num2str(N) 'pt' winname 'Window' '_' num2str(r*100) 'pcOlap'];
        batch = 1;
        if writeout == 1,mkdir(path,metadir);end
        files = get(handles.RUN,'UserData');
        nf = length(files);
        disp(['No. of audio files in selected directory: ' num2str(nf)])
        tall = tic;
        for i = 1:nf
            if i == 1,disppar = 1;else disppar = 0;end
            tic
            [A] = PG_Func(files(i).name,path,atype,'None',envi,calib,ctype,Fs,Si,Mh,G,vADC,r,N,winname,lcut,hcut,tstring,metadir,writeout,disppar,welch,chunksize,batch,linlog);
            if i == 1                   %initialise concatenated array on first iteration
                conk = A;
            elseif length(conk(1,:)) == length(A(1,:))
                [ra,~] = size(A);
                if isempty(tstring);tdiff = conk(3,1)-conk(2,1);A(2:ra,1) = A(2:ra,1)+conk(length(conk(:,1)),1)+tdiff;end
                conk = [conk; A(2:ra,:)];
                clear A
            else
                disp('Sample rates of files not equal. Concatenation aborted.')
            end
            tock = toc;
            fprintf(['File ' num2str(i) '/' num2str(nf) ': ' files(i).name ' analysed in ' num2str(tock) ' s\n'])
        end
        tockall = toc(tall);
        disp(['Analysis complete in ' num2str(tockall) ' s.'])
        
        ofile = ['PAMGuide_Batch_' atype '_' calstring '_' num2str(N) 'pt' winname 'Window' '_' num2str(r*100) 'pcOlap.csv'];
        PG_Viewer(conk,plottype,ofile,linlog)
        %encode A(1,1) with analysis metadata
        aid = 0;
        switch atype
            case 'PSD',aid = aid + 1;
            case 'PowerSpec',aid = aid + 2;
            case 'TOL',aid = aid + 3;
            case 'Broadband',aid = aid + 4;
            case 'Waveform',aid = aid + 5;
            case 'TOLf',aid = aid + 3;
        end
        if calib == 1,aid = aid + 10;else aid = aid + 20;end
        if strcmp(envi,'Air'), aid = aid + 100;else aid = aid + 200;end
        if tstick == 1, aid = aid + 1000;else aid = aid + 2000;end
        conk(1,1) = aid;
        fprintf('Writing concatenated output array...'),tic
        if tstick == 1
            dlmwrite(fullfile(path,ofile),conk,'precision',15,'delimiter',',');
        else
            dlmwrite(fullfile(path,ofile),conk,'precision',9,'delimiter',',');
        end
        tock = toc;
        fprintf(['done in ' num2str(tock) ' s.\n'])

    case 3                  %VIEWER
    ifile = get(handles.filetext,'UserData');
    A = get(handles.RUN,'UserData');    
    PG_Viewer(A,plottype,ifile,linlog)
end
        





% --- Executes on selection change in atypedrop.
function atypedrop_Callback(hObject, eventdata, handles)
% hObject    handle to atypedrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns atypedrop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from atypedrop
val = get(hObject,'Value');
if val == 1 || val == 5
    set(handles.text40,'enable','on')
    set(handles.linlog,'enable','on')
else
    set(handles.text40,'enable','off')
    set(handles.linlog,'enable','off')
end

% --- Executes during object creation, after setting all properties.
function atypedrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atypedrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in writeout.
function writeout_Callback(hObject, eventdata, handles)
% hObject    handle to writeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of writeout


% --- Executes on button press in wtick.
function wtick_Callback(hObject, eventdata, handles)
% hObject    handle to wtick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wtick

onoff = get(hObject,'Value');
if onoff == 1
    set(handles.text36,'enable','on')
    set(handles.text37,'enable','on')
    set(handles.wstring,'enable','on')
    set(handles.secfacdrop,'enable','on')
elseif onoff == 0
    set(handles.text36,'enable','off')
    set(handles.text37,'enable','off')
    set(handles.wstring,'enable','off')
    set(handles.secfacdrop,'enable','off')
end

function wstring_Callback(hObject, eventdata, handles)
% hObject    handle to wstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wstring as text
%        str2double(get(hObject,'String')) returns contents of wstring as a double


% --- Executes during object creation, after setting all properties.
function wstring_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in secfacdrop.
function secfacdrop_Callback(hObject, eventdata, handles)
% hObject    handle to secfacdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns secfacdrop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from secfacdrop
val = get(hObject,'Value');
if val == 1
    set(handles.text37,'string','to')
    set(handles.text36,'string','s')
elseif val == 2
    set(handles.text37,'string','by')
    set(handles.text36,'string','x')
end

% --- Executes during object creation, after setting all properties.
function secfacdrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secfacdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chunktick.
function chunktick_Callback(hObject, eventdata, handles)
% hObject    handle to chunktick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chunktick

onoff = get(hObject,'Value');
if onoff == 1
    set(handles.text38,'enable','on')
    set(handles.text39,'enable','on')
    set(handles.chunksize,'enable','on')
elseif onoff == 0
    set(handles.text38,'enable','off')
    set(handles.text39,'enable','off')
    set(handles.chunksize,'enable','off')
end


function chunksize_Callback(hObject, eventdata, handles)
% hObject    handle to chunksize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chunksize as text
%        str2double(get(hObject,'String')) returns contents of chunksize as a double


% --- Executes during object creation, after setting all properties.
function chunksize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chunksize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in linlog.
function linlog_Callback(hObject, eventdata, handles)
% hObject    handle to linlog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns linlog contents as cell array
%        contents{get(hObject,'Value')} returns selected item from linlog


% --- Executes during object creation, after setting all properties.
function linlog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linlog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
