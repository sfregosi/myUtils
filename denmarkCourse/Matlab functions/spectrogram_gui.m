%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Spectrogram GUI
%  Acoustic Communication 2015
%  Leon Bonde Larsen <lelar@mmmi.sdu.dk>
%
%  The GUI can be called like this:
%     spectrogram_gui(x,f)
%  where x is the signal and f is the sampling frequency of the signal.
%
%  It can also be called without arguments like this:
%     spectrogram_gui
%
%  In both cases the GUI will return the currently selected part of the
%  signal and the sampling frequency:
%     [x,f] = spectrogram_gui;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initalisation function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = spectrogram_gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spectrogram_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @spectrogram_gui_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  User functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = normalise_signal(signal)
    % When loaded any DC offset is removed and the signal is normalised 
    s = signal - mean(signal);
    s = s ./ max(abs(signal));

function h = set_default_values(hObject,handles) 
    % The default values for the spectrogram
    nfft = 256;
    window = hanning(nfft);
    overlap = round(0.5*length(window));
    handles.window = window;
    handles.nfft = nfft;
    handles.overlap = overlap;
    
    h = handles;
    
function h = update_plots(hObject,handles)
    % This function updated the three plots
    
    % Update time plot
    axes(handles.time_axes);
    first_time = handles.first/handles.Fs;
    last_time = handles.last/handles.Fs;
    time = first_time:1/handles.Fs:last_time;
    plot(time, handles.selection);
    ylim([-1 1]);
    title('Signal');
    xlabel('Time')
    ylabel('Amplitude')

    % Save the bin values from the spectrogram
    [s,f,t,psd] = spectrogram(handles.selection, handles.window, handles.noverlap, handles.nfft, handles.Fs, 'yaxis');
    handles.spectrogram = s;
    handles.time_vector = t;
    handles.freq_vector = f;
    handles.max = max(max(abs(s)));

    % Update spectrogram plot
    axes(handles.spec_axes);
    spectrogram(handles.selection, handles.window, handles.noverlap, handles.nfft, handles.Fs, 'yaxis');
%     surf(t,f,abs(s),'EdgeColor','none')
%     view(0,90);
%     title('Spectrogram');
%     ylabel(ylbl);
%     xlabel(xlbl);

    % Move colorbar
    c = colorbar('peer',handles.spec_axes);
    axpos = handles.spec_axes.Position;
    cpos = c.Position;
    cpos(1) = cpos(1)+0.08;
    c.Position = cpos;
    
    % Update power spectrum
    axes(handles.pow_axes);
    %plot(f,10*log10(psd));
    periodogram(handles.selection, hamming(length(handles.selection)), handles.nfft, handles.Fs);
    title('Power spectrum');
    
    h = handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Below this point is only useless GUI stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before spectrogram_gui is made visible.
function spectrogram_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spectrogram_gui (see VARARGIN)

    % Initialise handles
    handles.spectrogram = [[]];
    handles.time_vector = [];
    handles.freq_vector = [];
    handles.nfft = 0;
    handles.window = 0;
    handles.noverlap = 0;
    handles.Fs = 0;
    handles.spec_rectangle = rectangle('Position',[0 0 0 0]);
    handles.max = 0;
    handles.signal = [];
    handles.selection = [];

    % Check if arbuments were passed
    if nargin<4
        % Initialise without signal
        handles.signal = [];
        handles.fileLoaded = 0;

        % Turn off axes
        axes(handles.time_axes);
        axis off
        axes(handles.spec_axes);
        axis off
        axes(handles.pow_axes);
        axis off
    elseif nargin == 5
        % Initialise with signal
        handles.signal = normalise_signal(varargin{1});
        handles.Fs = varargin{2};
        handles.fileLoaded = 1;
        handles.selection = handles.signal;
        handles.fileLoaded = 1;
        handles.first = 1;
        handles.last = length(handles.signal);

        handles = set_default_values(hObject,handles);

        handles = update_plots(hObject,handles);
    else
        % Display error message without throwing error
        fprintf(2,['spectrogram_gui takes exactly two arguments (', num2str(nargin-3), ' given). Arguments are ignored.\n'])
    end


    % Choose default command line output for spectrogram_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes spectrogram_gui wait for user response (see UIRESUME)
    uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = spectrogram_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.selection;
    varargout{2} = handles.Fs;

    delete(hObject);

% --- Executes on button press in pushbutton_load_file.
function pushbutton_load_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [FileName,PathName] = uigetfile({'*.wav'},'Load Wav File');
    [x,Fs] = audioread([PathName '/' FileName]);
    handles.signal = normalise_signal(x);
    handles.Fs = Fs;
    handles.selection = handles.signal;

    handles.fileLoaded = 1;
    handles.first = 1;
    handles.last = length(handles.signal);

    handles = set_default_values(hObject,handles);

    handles = update_plots(hObject,handles);

    guidata(hObject, handles);

% --- Executes on button press in pushbutton_make_selection.
function pushbutton_make_selection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_make_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [x,y] = ginput(2); 
    if x(1) < x(2)
        handles.first = round( x(1)*handles.Fs );
        handles.last = round( x(2)*handles.Fs );
    else
        handles.first = round( x(2)*handles.Fs );
        handles.last = round( x(1)*handles.Fs );
    end

    handles.selection = handles.signal(handles.first:handles.last);

    zoom off;
    pan off;
    linkaxes([handles.time_axes, handles.spec_axes],'off');
        
    handles = update_plots(hObject,handles);

    guidata(hObject, handles);

    % --- Executes on button press in pushbutton_reset_selection.
    function pushbutton_reset_selection_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_reset_selection (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.selection = handles.signal;
    handles.first = 1;
    handles.last = length(handles.signal);

    handles = update_plots(hObject,handles);

    guidata(hObject, handles);

% --- Executes on button press in pushbutton_play_selection.
function pushbutton_play_selection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if (handles.fileLoaded==1)
        sound(handles.selection, handles.Fs);
    end


% --- Executes on button press in pushbutton_select_bin.
function pushbutton_select_bin_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [x,y] = ginput(1);
    y = y*1000;

    [x_err, x_sample] = min( abs(handles.time_vector'-x) );
    [y_err, y_sample] = min( abs(handles.freq_vector-(y) ) );

    x_val = handles.time_vector(x_sample);
    y_val = handles.freq_vector(y_sample)/1000;
    z = handles.spectrogram(y_sample, x_sample);
    z_val = mag2db( abs( z )/handles.max );

    bin_size_x = mean(diff(handles.time_vector));
    bin_size_y = mean(diff(handles.freq_vector))/1000;

    axes(handles.spec_axes);
    hold on
    delete(handles.spec_rectangle) ;
    handles.spec_rectangle = rectangle('Position',[x_val-(bin_size_x/2) y_val-bin_size_y bin_size_x bin_size_y],'EdgeColor','b');
    hold off

    bin = {[num2str( round(x_val+(bin_size_x/2),3) ), ' s'] ; [num2str( round(y_val,3) ), ' kHz'] ; [num2str( round(z_val,3) ), ' dB']};

    set(handles.bin_info,'String',bin);

    guidata(hObject, handles);


% --- Executes on button press in pushbutton_update_spectrogram.
function pushbutton_update_spectrogram_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update_spectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.fileLoaded
        update_plots(hObject,handles);
    end


% --- Executes on selection change in select_window.
function select_window_Callback(hObject, eventdata, handles)
% hObject    handle to select_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_window contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_window
    contents = cellstr(get(hObject,'String'));
    choice = contents{get(hObject,'Value')};
    switch choice
        case 'Bartlett'
            handles.window = bartlett(handles.nfft);
        case 'Blackman'
            handles.window = blackman(handles.nfft);
        case 'Chebyshev'
            handles.window = chebwin(handles.nfft,100);
        case 'Gaussian'
            handles.window = gausswin(handles.nfft);
        case 'Hanning'
            handles.window = hann(handles.nfft);
        case 'Hamming'
            handles.window = hamming(handles.nfft,'periodic');
        case 'Kaiser'
            handles.window = kaiser(handles.nfft,0.5);
    end

    guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function select_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set(hObject,'String',{'Bartlett';'Blackman';'Chebyshev';'Gaussian';'Hanning';'Hamming';'Kaiser'});
    set(hObject,'Value',5);

% --- Executes on selection change in select_overlap.
function select_overlap_Callback(hObject, eventdata, handles)
% hObject    handle to select_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_overlap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_overlap
    contents = cellstr(get(hObject,'String'));
    choice = contents{get(hObject,'Value')};
    switch choice
        case '25%'
            handles.overlap = round(0.25*length(handles.window));
        case '50%'
            handles.overlap = round(0.5*length(handles.window));
        case '75%'
            handles.overlap = round(0.75*length(handles.window));
    end
    handles.overlap = str2num(choice);
    guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function select_overlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set(hObject,'String',{'25%', '50%', '75%'});
    set(hObject,'Value',2);


% --- Executes on selection change in select_nfft.
function select_nfft_Callback(hObject, eventdata, handles)
% hObject    handle to select_nfft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_nfft contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_nfft
    contents = cellstr(get(hObject,'String'));
    choice = contents{get(hObject,'Value')};
    handles.nfft = str2num(choice);
    guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function select_nfft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_nfft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set(hObject,'String',{num2str( (2.^[5:14])' )});
    set(hObject,'Value',4);


% --- Executes on button press in pushbutton_select_frequency.
function pushbutton_select_frequency_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [x,y] = ginput(1);
    info = {[num2str( round(x,3) ), ' kHz'] ; [num2str( round(y,3) ), ' dB']};
    set(handles.frequency_info,'String',info);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if isequal(get(hObject, 'waitstatus'), 'waiting')
        uiresume(hObject);
    else
        delete(hObject);
    end


% --------------------------------------------------------------------
function uitoggletool_zoom_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Turn on zooming if full signal is viewed
    if handles.first == 1 && handles.last == length(handles.signal)
        zoom xon;
        pan off;
        linkaxes([handles.time_axes, handles.spec_axes],'x');
    else
        zoom off;
        pan off;
        linkaxes([handles.time_axes, handles.spec_axes],'off');
        fprintf(2,'Zooming is not allowed after making selection\n')
    end


% --------------------------------------------------------------------
function uitoggletool_pan_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Turn on zooming if full signal is viewed
    if handles.first == 1 && handles.last == length(handles.signal)
        zoom off;
        pan xon;
        linkaxes([handles.time_axes, handles.spec_axes],'x');
    else
        zoom off;
        pan off;
        linkaxes([handles.time_axes, handles.spec_axes],'off');
        fprintf(2,'Panning is not allowed after making selection\n')
    end
