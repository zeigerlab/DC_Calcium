function varargout = DC_Analyze3(varargin)
% DCLW_ANALYZE2 M-file for DC_Analyze3.fig
%      DCLW_ANALYZE2, by itself, creates a new DCLW_ANALYZE2 or raises the existing
%      singleton*.
%
%      H = DCLW_ANALYZE2 returns the handle to a new DCLW_ANALYZE2 or the handle to
%      the existing singleton*.
%
%      DCLW_ANALYZE2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DCLW_ANALYZE2.M with the given input arguments.
%
%      DCLW_ANALYZE2('Property','Value',...) creates a new DCLW_ANALYZE2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DCLW_Analyze2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DCLW_Analyze2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DCLW_Analyze2

% Last Modified by GUIDE v2.5 04-Jan-2016 06:15:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DC_Analyze3_OpeningFcn, ...
                   'gui_OutputFcn',  @DC_Analyze3_OutputFcn, ...
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


% --- Executes just before DCLW_Analyze2 is made visible.
function DC_Analyze3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DCLW_Analyze2 (see VARARGIN)

% Choose default command line output for DCLW_Analyze2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DCLW_Analyze2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DC_Analyze3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function badframes_Callback(hObject, eventdata, handles)
% hObject    handle to badframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of badframes as text
%        str2double(get(hObject,'String')) returns contents of badframes as a double


% --- Executes during object creation, after setting all properties.
function badframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to badframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in selectdata.
function selectdata_Callback(hObject, eventdata, handles)
% hObject    handle to selectdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   %load F file
[Ffile,Ffilepath]=uigetfile('*.mat','pick the F file');
fullFfile=[Ffilepath Ffile];
set(hObject,'String',fullFfile);

% --- Executes on button press in excelbox.
function excelbox_Callback(hObject, eventdata, handles)
% hObject    handle to excelbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of excelbox

% --- Executes on button press in activeROIbox.
function activeROIbox_Callback(hObject, eventdata, handles)
% hObject    handle to activeROIbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of activeROIbox


% --- Executes on button press in goscience.
function goscience_Callback(hObject, eventdata, handles)
% hObject    handle to goscience (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%----------Simple parse---------------------
experimenttype=(get(handles.exptype,'Value'));
baselineframes=str2double(get(handles.baselineframes,'String'));
fullFfile=(get(handles.selectdata,'String')); %file name
fullxlsfile=(get(handles.loadinfo,'String')); %time data

deleted=str2double(get(handles.deleted,'String'));
corrbins=str2double(get(handles.corrbin,'String'));
%----------End Simple Parse------------------

%--------------------Parse Bad Frame String into Matrix--------------
badframesstr=(get(handles.badframes,'String'));
stringpos=2; % initial position of string
spaces=0;
spaces(1)=0; %sets first space at 0

for i=2:length(badframesstr)
    if badframesstr(i)==' ' %Detects spaces and uses them as bounds
        spaces(stringpos)=i;
        stringpos=stringpos+1;
    end
end
spaces((length(spaces)+1))=length(badframesstr)+1; %sets last space at end
for i=1:(length(spaces)-1)
    badframes(i)=str2double(badframesstr(spaces(i)+1:spaces(i+1)-1));
end
%---------------------End Bad Frame Parse------------------------------

% %--------------------Parse ROI Select String into Matrix--------------
roiselect=str2num(get(handles.selectrois,'String'));
% %---------------------End ROI Select Parse------------------------------

%-------------Output Selection----------------------------------------
% 4=Excel Data
outputs(4)=get(handles.excelbox,'Value');
% 5=Pref Direction
outputs(5)=get(handles.checkbox6,'Value');
% 6=Pref Orientation
outputs(6)=get(handles.checkbox7,'Value');
%7=Active ROI plots (similar to Raw plots but only active ROIs)
outputs(7)=get(handles.activeROIbox,'Value');
%-------------End Output Selection------------------------------------

%--------------------Run Analysis-------------------------------------
DC_Analyze_Control3(badframes,outputs,deleted,corrbins,roiselect,...
        fullFfile,experimenttype,baselineframes,fullxlsfile);
%------------------End Run Analysis-----------------------------------

% --- Executes on selection change in exptype.
function exptype_Callback(hObject, eventdata, handles)
% hObject    handle to exptype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns exptype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exptype


% --- Executes during object creation, after setting all properties.
function exptype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exptype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in loadinfo.
function loadinfo_Callback(hObject, eventdata, handles)
% hObject    handle to loadinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[xlsfile,xlsfilepath]=uigetfile('*.xls','pick the matching Excel file');
fullxlsfile=[xlsfilepath xlsfile];
set(hObject,'String',fullxlsfile);



function baselineframes_Callback(hObject, eventdata, handles)
% hObject    handle to baselineframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselineframes as text
%        str2double(get(hObject,'String')) returns contents of baselineframes as a double


% --- Executes during object creation, after setting all properties.
function baselineframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselineframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function deleted_Callback(hObject, eventdata, handles)
% hObject    handle to deleted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deleted as text
%        str2double(get(hObject,'String')) returns contents of deleted as a double


% --- Executes during object creation, after setting all properties.
function deleted_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deleted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function corrbin_Callback(hObject, eventdata, handles)
% hObject    handle to corrbin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of corrbin as text
%        str2double(get(hObject,'String')) returns contents of corrbin as a double


% --- Executes during object creation, after setting all properties.
function corrbin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to corrbin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function selectrois_Callback(hObject, eventdata, handles)
% hObject    handle to selectrois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selectrois as text
%        str2double(get(hObject,'String')) returns contents of selectrois as a double


% --- Executes during object creation, after setting all properties.
function selectrois_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectrois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
