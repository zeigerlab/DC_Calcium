function varargout = DC_roi_refine(varargin)
% DC_ROI_REFINE MATLAB code for DC_roi_refine.fig
%      DC_ROI_REFINE, by itself, creates a new DC_ROI_REFINE or raises the existing
%      singleton*.
%
%      H = DC_ROI_REFINE returns the handle to a new DC_ROI_REFINE or the handle to
%      the existing singleton*.
%
%      DC_ROI_REFINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DC_ROI_REFINE.M with the given input arguments.
%
%      DC_ROI_REFINE('Property','Value',...) creates a new DC_ROI_REFINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DC_roi_refine_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DC_roi_refine_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DC_roi_refine

% Last Modified by GUIDE v2.5 14-Aug-2018 09:59:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DC_roi_refine_OpeningFcn, ...
                   'gui_OutputFcn',  @DC_roi_refine_OutputFcn, ...
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


% --- Executes just before DC_roi_refine is made visible.
function DC_roi_refine_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DC_roi_refine (see VARARGIN)

% Choose default command line output for DC_roi_refine
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% Choose default command line output for DC_motion_correction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

autosave_file='autosave_DC_refine.mat'; %Name autosave file

%Check if autoload exists
if exist('autosave_DC_refine.mat','file')==2 %Checks for autosave file
    load('autosave_DC_refine.mat'); %loads file into workspace
    write_refine_roi(handles,refine_roi,2) %Load settings into GUI
else
    DC_autoload_fail(autosave_file) %Runs dialog box to find and move an autoload file
    if exist('autosave_DC_refine.mat','file')==2 %If no autoload selected, create default
        load('autosave_DC_refine.mat'); %loads file into workspace
        %Check if valid save file
        if exist('refine','var')~=1
            warning_text='The selected file is not a valid settings file.';
            DC_warning_small(warning_text);
            return
        else
            write_refine_roi(handles,refine_roi,2) %Load settings into GUI
        end
    end
end
% UIWAIT makes DC_roi_refine wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DC_roi_refine_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This runs the motion correction

refine_roi=parse_refine_roi(handles); %read GUI

%Autosave
save('autosave_DC_refine_roi.mat','refine_roi');

%Move files to process highlight to first position
set(handles.processed_list,'Value',1);

%Find number of files to be run
file_num=size(get(handles.to_process_list,'String'),1);

%-----Initiatlize Progress variables-----
progress.to_process_size=file_num; %Check number of files in list

progress.current_file=0; %current file progress

progress.overall=0; %overall progress

progress.time_remaining=0; %estimated time remaining

progress.tic=tic; %mark start of motion correction process

progress.status_bar=[];

for i=1:file_num
    progress.current_file=i; %Marks current file number
    
    filename=refine_roi.to_process_list{1};
    
    [progress]=DC_roi_detect_process(filename,refine_roi,handles,progress); 
    
    %-----------------Update lists and Autosave-------------------
    %Update files list
    if isempty(refine_roi.processed_list{1})==1
        refine_roi.processed_list{1}=progress.newfile;
    else
        refine_roi.processed_list{end+1}=progress.newfile;
    end
    refine_roi.to_process_list(1)=[];
    
    %Update files to process list
    set(handles.to_process_list,'String',refine_roi.to_process_list');
    
    %Update processed Files list
    set(handles.processed_list,'String',refine_roi.processed_list);
    drawnow %Updates GUI
    
    %Autosave
    save('autosave_DC_refine_roi.mat','refine_roi');
    %---------------End Update lists and Autosave-----------------
end

% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('Calcium_Analysis_Documentation.pdf');

function status_bar_Callback(hObject, eventdata, handles)
% hObject    handle to status_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of status_bar as text
%        str2double(get(hObject,'String')) returns contents of status_bar as a double


% --- Executes during object creation, after setting all properties.
function status_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_settings_button.
function load_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function loads saved settings
refine_roi_load_settings(handles)


% --- Executes on button press in save_settings_button.
function save_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function saves the settings for future use as a csv
refine_roi_save_settings(handles)


function input_merge_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to input_merge_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_merge_thresh as text
%        str2double(get(hObject,'String')) returns contents of input_merge_thresh as a double


% --- Executes during object creation, after setting all properties.
function input_merge_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_merge_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_components_Callback(hObject, eventdata, handles)
% hObject    handle to input_components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_components as text
%        str2double(get(hObject,'String')) returns contents of input_components as a double


% --- Executes during object creation, after setting all properties.
function input_components_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in load_ROI.
function load_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to load_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[add_file,add_filepath]=uigetfile('*.mat','Choose _roi.mat file to be processed.','MultiSelect','off');

if iscell(add_file)||ischar(add_file) %Checks to see if anything was selected
    
    %Load Data
    full_filepath=[add_filepath add_file]; %Concatenate file path and name
    handles.ROI=load(full_filepath); %Creates a new handle, ROI, and loads file data into it
    guidata( hObject, handles); %Saves new handle so that it can be passed within the GUI
    
    if  isfield(handles.ROI,'C_or') %check to make sure data are compatible and raw data available
        ROI_length=size(handles.ROI.C_or,1); %Find longest length of data
    else 
         warning_text='The selected file is not a compatible data file. Compatible data files should end with _roi.mat';
            DC_warning_small(warning_text);
            return
    end   
    
    if ~isfield(handles.ROI,'ROI_names') %Check if names are already generated
        handles.ROI.ROI_names=1:ROI_length; %populate the list of default ROI names
    end
    
    set(handles.ROI_list,'Value',1); %reset selection bar to 1
    
    set(handles.ROI_list,'string',handles.ROI.ROI_names); %Update the ROI list
    
    drawnow %update GUI

    view_ROI_function(hObject, eventdata, handles) %Automatically load first ROI
    
end

% --- Executes on selection change in ROI_list.
function ROI_list_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view_ROI_function(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns ROI_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROI_list



% --- Executes during object creation, after setting all properties.
function ROI_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in include_ROI.
function include_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to include_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_number=get(handles.ROI_list,'Value'); %Get the number of the selected ROI
ROI_new_string=get(handles.ROI_list,'String');
ROI_new_string(ROI_number,:)=[num2str(ROI_number) ' '];
set(handles.ROI_list,'String',ROI_new_string);

view_ROI_function(hObject, eventdata, handles);



% --- Executes on button press in view_ROI.
function view_ROI_function(hObject, eventdata, handles)
% hObject    handle to view_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROI_number=get(handles.ROI_list,'Value'); %Get the number of the selected ROI

%Display Map
axes(handles.whole_field); %Select whole field axes
% map=im2double(handles.ROI.Cn);
% image(map)

%Display Isolated ROI
axes(handles.isolated_ROI); %Select whole field axes

%Display raw dF/F trace (if exists)
axes(handles.ROI_dF_trace);
plot(handles.ROI.C2_raw_or(ROI_number,:))
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Display fitted trace (if exists)
axes(handles.ROI_fitted_trace);
plot(handles.ROI.C_df(ROI_number,:))
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Display deconvolved trace (if exists)
axes(handles.ROI_deconvolved_trace);
plot(handles.ROI.S_or(ROI_number,:))
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Display Big Map
%map_size=size(handles.ROI.Cn);
axes(handles.whole_field);
%whole_map=(reshape(handles.ROI.A_or(:,ROI_number),map_size(1),map_size(2)));
imagesc(handles.ROI.Cn);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Display Isolated ROI
map_size=size(handles.ROI.Cn);
axes(handles.isolated_ROI);
single_ROI=(reshape(handles.ROI.A_or(:,ROI_number),map_size(1),map_size(2)));
imagesc(single_ROI);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
set(gca,'box','off')

%Read if included or excluded, update exclusion list
ROI_name=get(handles.ROI_list,'String');
if strcmp(ROI_name(ROI_number,end),'X')
    set(handles.exclusion_status,'String',['ROI ' num2str(ROI_number) ' - Excluded'])
    set(handles.exclusion_status,'ForegroundColor','white')
    set(handles.exclusion_status,'BackgroundColor',[0.6350, 0.0780, 0.1840])
else
    set(handles.exclusion_status,'String',['ROI ' num2str(ROI_number) ' - Included'])
    set(handles.exclusion_status,'ForegroundColor','black')
    set(handles.exclusion_status,'BackgroundColor','white')
end

drawnow;



% --- Executes on button press in next_ROI.
function next_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to next_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_position=get(handles.ROI_list,'Value'); %Finds the position of the highlight
list_length=length(get(handles.ROI_list,'String')); %Finds the length of the list
if list_position == list_length %Checks to see if end of the list
    new_position=1; %Start back at the start
else
    new_position=list_position+1; %Move to the next position
end
set(handles.ROI_list,'Value',new_position); %Change position of highlight
drawnow %update GUI

view_ROI_function(hObject, eventdata, handles) %Run as if the View ROI button were pressed



% --- Executes on button press in previous_ROI.
function previous_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to previous_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

list_position=get(handles.ROI_list,'Value'); %Finds the position of the highlight
list_length=length(get(handles.ROI_list,'String')); %Finds the length of the list
if list_position == 1 %Checks to see if at the start of the list
    new_position=list_length; %Move to the end of the list
else
    new_position=list_position-1; %Move to the previous position
end
set(handles.ROI_list,'Value',new_position); %Change position of highlight
drawnow %update GUI

view_ROI_function(hObject, eventdata, handles) %Run as if the View ROI button were pressed


% --- Executes on selection change in input_dF_activity_style.
function input_dF_activity_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_dF_activity_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_dF_activity_style


% --- Executes during object creation, after setting all properties.
function input_dF_activity_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_dF_activity_value_Callback(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_dF_activity_value as text
%        str2double(get(hObject,'String')) returns contents of input_dF_activity_value as a double


% --- Executes during object creation, after setting all properties.
function input_dF_activity_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_dF_activity_frames_Callback(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_dF_activity_frames as text
%        str2double(get(hObject,'String')) returns contents of input_dF_activity_frames as a double


% --- Executes during object creation, after setting all properties.
function input_dF_activity_frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_dF_activity_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function input_roundness_Callback(hObject, eventdata, handles)
% hObject    handle to input_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_roundness as text
%        str2double(get(hObject,'String')) returns contents of input_roundness as a double


% --- Executes during object creation, after setting all properties.
function input_roundness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_baseline_stability_Callback(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_baseline_stability as text
%        str2double(get(hObject,'String')) returns contents of input_baseline_stability as a double


% --- Executes during object creation, after setting all properties.
function input_baseline_stability_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_oblongness_Callback(hObject, eventdata, handles)
% hObject    handle to input_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_oblongness as text
%        str2double(get(hObject,'String')) returns contents of input_oblongness as a double


% --- Executes during object creation, after setting all properties.
function input_oblongness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ROI_roundness_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_roundness as text
%        str2double(get(hObject,'String')) returns contents of ROI_roundness as a double


% --- Executes during object creation, after setting all properties.
function ROI_roundness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_roundness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_width_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_width as text
%        str2double(get(hObject,'String')) returns contents of ROI_width as a double


% --- Executes during object creation, after setting all properties.
function ROI_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_baseline_stability_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_baseline_stability as text
%        str2double(get(hObject,'String')) returns contents of ROI_baseline_stability as a double


% --- Executes during object creation, after setting all properties.
function ROI_baseline_stability_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_baseline_stability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_oblongness_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_oblongness as text
%        str2double(get(hObject,'String')) returns contents of ROI_oblongness as a double


% --- Executes during object creation, after setting all properties.
function ROI_oblongness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_oblongness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function exclusion_status_Callback(hObject, eventdata, handles)
% hObject    handle to exclusion_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exclusion_status as text
%        str2double(get(hObject,'String')) returns contents of exclusion_status as a double


% --- Executes during object creation, after setting all properties.
function exclusion_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exclusion_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_baseline_stability_percent_Callback(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability_percent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_baseline_stability_percent as text
%        str2double(get(hObject,'String')) returns contents of input_baseline_stability_percent as a double


% --- Executes during object creation, after setting all properties.
function input_baseline_stability_percent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_baseline_stability_percent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_area_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_area_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_area_max as text
%        str2double(get(hObject,'String')) returns contents of input_area_max as a double


% --- Executes during object creation, after setting all properties.
function input_area_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_area_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_area_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_area_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_area_min as text
%        str2double(get(hObject,'String')) returns contents of input_area_min as a double


% --- Executes during object creation, after setting all properties.
function input_area_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_area_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_area_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_area as text
%        str2double(get(hObject,'String')) returns contents of ROI_area as a double


% --- Executes during object creation, after setting all properties.
function ROI_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ROI_kurtosis_dF_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_kurtosis_dF as text
%        str2double(get(hObject,'String')) returns contents of ROI_kurtosis_dF as a double


% --- Executes during object creation, after setting all properties.
function ROI_kurtosis_dF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_skewness_deconvolved_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_skewness_deconvolved as text
%        str2double(get(hObject,'String')) returns contents of ROI_skewness_deconvolved as a double


% --- Executes during object creation, after setting all properties.
function ROI_skewness_deconvolved_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_kurtosis_deconvolved_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_kurtosis_deconvolved as text
%        str2double(get(hObject,'String')) returns contents of ROI_kurtosis_deconvolved as a double


% --- Executes during object creation, after setting all properties.
function ROI_kurtosis_deconvolved_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_kurtosis_deconvolved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_skewness_dF_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_skewness_dF as text
%        str2double(get(hObject,'String')) returns contents of ROI_skewness_dF as a double


% --- Executes during object creation, after setting all properties.
function ROI_skewness_dF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_skewness_dF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in input_skewness_kurtosis_style.
function input_skewness_kurtosis_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_skewness_kurtosis_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_skewness_kurtosis_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_skewness_kurtosis_style


% --- Executes during object creation, after setting all properties.
function input_skewness_kurtosis_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_skewness_kurtosis_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_borderline_value_Callback(hObject, eventdata, handles)
% hObject    handle to input_borderline_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_borderline_value as text
%        str2double(get(hObject,'String')) returns contents of input_borderline_value as a double


% --- Executes during object creation, after setting all properties.
function input_borderline_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_borderline_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_width_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_width_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_width_max as text
%        str2double(get(hObject,'String')) returns contents of input_width_max as a double


% --- Executes during object creation, after setting all properties.
function input_width_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_width_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_width_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_width_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_width_min as text
%        str2double(get(hObject,'String')) returns contents of input_width_min as a double


% --- Executes during object creation, after setting all properties.
function input_width_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_width_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_skewness_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_skewness_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_skewness_max as text
%        str2double(get(hObject,'String')) returns contents of input_skewness_max as a double


% --- Executes during object creation, after setting all properties.
function input_skewness_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_skewness_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_kurtosis_max_Callback(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_kurtosis_max as text
%        str2double(get(hObject,'String')) returns contents of input_kurtosis_max as a double


% --- Executes during object creation, after setting all properties.
function input_kurtosis_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_skewness_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_skewness_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_skewness_min as text
%        str2double(get(hObject,'String')) returns contents of input_skewness_min as a double


% --- Executes during object creation, after setting all properties.
function input_skewness_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_skewness_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_kurtosis_min_Callback(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_kurtosis_min as text
%        str2double(get(hObject,'String')) returns contents of input_kurtosis_min as a double


% --- Executes during object creation, after setting all properties.
function input_kurtosis_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_kurtosis_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function input_borderline_allowance_Callback(hObject, eventdata, handles)
% hObject    handle to input_borderline_allowance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_borderline_allowance as text
%        str2double(get(hObject,'String')) returns contents of input_borderline_allowance as a double


% --- Executes during object creation, after setting all properties.
function input_borderline_allowance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_borderline_allowance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exclude_ROI.
function exclude_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to exclude_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_number=get(handles.ROI_list,'Value'); %Get the number of the selected ROI
ROI_new_string=get(handles.ROI_list,'String');
ROI_new_string(ROI_number,:)=[num2str(ROI_number) 'X'];
set(handles.ROI_list,'String',ROI_new_string);

view_ROI_function(hObject, eventdata, handles);

% --- Executes on selection change in input_borderline_style.
function input_borderline_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_borderline_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_borderline_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_borderline_style


% --- Executes during object creation, after setting all properties.
function input_borderline_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_borderline_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_settings_button.
function load_settings_Callback(hObject, eventdata, handles)
% hObject    handle to load_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_settings_button.
function save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA).

% --- Executes on button press in box_eps.
function box_eps_Callback(hObject, eventdata, handles)
% hObject    handle to box_eps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_eps


% --- Executes on button press in box_pdf.
function box_pdf_Callback(hObject, eventdata, handles)
% hObject    handle to box_pdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_pdf


% --- Executes on button press in box_fig.
function box_fig_Callback(hObject, eventdata, handles)
% hObject    handle to box_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_fig


% --- Executes on button press in box_csv.
function box_csv_Callback(hObject, eventdata, handles)
% hObject    handle to box_csv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_csv


% --- Executes on button press in box_mat.
function box_mat_Callback(hObject, eventdata, handles)
% hObject    handle to box_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_mat


% --- Executes on button press in box_xlsx.
function box_xlsx_Callback(hObject, eventdata, handles)
% hObject    handle to box_xlsx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_xlsx




function refine_roi_save_settings(handles)
%Manually save settings from GUI

[refine_roi]=parse_refine_roi(handles); %reads GUI

%Open save box
[filename,filepath] = uiputfile('*.mat');

%Check if anything was selected
if filename==0
    return
end

%Concatenate file name
full_filename=[filepath filename];

%Write to .mat file
save(full_filename,'refine_roi');


function refine_roi_load_settings(handles)
%Manually loads settings into GUI

%Open load box
[filename,filepath] = uigetfile('*.mat');

%Check if anything was selected
if filename==0
    return
end

%Concatenate file name
full_filename=[filepath filename];

%Load .mat file
load(full_filename);

%Check if valid save file
if exist('refine_roi','var')~=1
    warning_text='The selected file is not a valid settings file.';
    DC_warning_small(warning_text);
    return
end

write_refine_roi(handles,refine_roi)


function [refine_roi]=parse_refine_roi(handles)
%Reads GUI, stores data into refine_roi variable

%==============Read Menus==============
%dF/F Activity
refine_roi.input_dF_activity_style=get(handles.input_dF_activity_style,'Value');

%Borderline Style
refine_roi.input_borderline_style=get(handles.input_borderline_style,'Value');

%Saturation Frames Style
refine_roi.input_sat_style=get(handles.input_sat_style,'Value');

%Skewness Kurtosis Style
refine_roi.input_skewness_kurtosis_style=get(handles.input_skewness_kurtosis_style,'Value');

%============Read Check Boxes===========
%Export CSV
refine_roi.box_csv=get(handles.box_csv,'Value');

%Export MAT
refine_roi.box_mat=get(handles.box_mat,'Value');

%Export XLSX
refine_roi.box_xlsx=get(handles.box_xlsx,'Value');

%Export EPS
refine_roi.box_eps=get(handles.box_eps,'Value');

%Export FIG
refine_roi.box_fig=get(handles.box_fig,'Value');

%Export PDF
refine_roi.box_pdf=get(handles.box_pdf,'Value');

%============Read Input Boxes===========
%dF_activity_value
refine_roi.input_dF_activity_value=get(handles.input_dF_activity_value,'String');

%dF activity frames
refine_roi.input_dF_activity_frames=get(handles.input_dF_activity_frames,'String');

%Baseline stability
refine_roi.input_baseline_stability=get(handles.input_baseline_stability,'String');

%Baseline stability percent
refine_roi.input_baseline_stability_percent=get(handles.input_baseline_stability_percent,'String');

%Roundness
refine_roi.input_roundness=get(handles.input_roundness,'String');

%Oblongness
refine_roi.input_oblongness=get(handles.input_oblongness,'String');

%Borderline Value
refine_roi.input_borderline_value=get(handles.input_borderline_value,'String');

%Borderline Allowance
refine_roi.input_borderline_allowance=get(handles.input_borderline_allowance,'String');

%Saturated Value
refine_roi.input_sat_value=get(handles.input_sat_value,'String');

%Area Min
refine_roi.input_area_min=get(handles.input_area_min,'String');

%Area Max
refine_roi.input_area_max=get(handles.input_area_max,'String');

%Width Min
refine_roi.input_width_min=get(handles.input_width_min,'String');

%Width Max
refine_roi.input_width_max=get(handles.input_width_max,'String');

%Skewness Min
refine_roi.input_skewness_min=get(handles.input_skewness_min,'String');

%Skewness Max
refine_roi.input_skewness_max=get(handles.input_skewness_max,'String');

%Kurtosis Min
refine_roi.input_kurtosis_min=get(handles.input_kurtosis_min,'String');

%Kurtosis Max
refine_roi.input_kurtosis_max=get(handles.input_kurtosis_max,'String');



function write_refine_roi(handles,refine_roi)
%This function writes to the GUI

%Writes to GUI, loading data from refine_roi variable

%==============Write Menus==============
%dF/F Activity
set(handles.input_dF_activity_style,'Value',refine_roi.input_dF_activity_style);

%Borderline Style
set(handles.input_borderline_style,'Value',refine_roi.input_borderline_style);

%Saturation Frames Style
set(handles.input_sat_style,'Value',refine_roi.input_sat_style);

%Skewness Kurtosis Style
set(handles.input_skewness_kurtosis_style,'Value',refine_roi.input_skewness_kurtosis_style);

%============Write Check Boxes===========
%Export CSV
set(handles.box_csv,'Value',refine_roi.box_csv);

%Export MAT
set(handles.box_mat,'Value',refine_roi.box_mat);

%Export XLSX
set(handles.box_xlsx,'Value',refine_roi.box_xlsx);

%Export EPS
set(handles.box_eps,'Value',refine_roi.box_eps);

%Export FIG
set(handles.box_fig,'Value',refine_roi.box_fig);

%Export PDF
set(handles.box_pdf,'Value',refine_roi.box_pdf);

%============Write Input Boxes===========
%dF_activity_value
set(handles.input_dF_activity_value,'String',refine_roi.input_dF_activity_value);

%dF activity frames
set(handles.input_dF_activity_frames,'String',refine_roi.input_dF_activity_frames);

%Baseline stability
set(handles.input_baseline_stability,'String',refine_roi.input_baseline_stability);

%Baseline stability percent
set(handles.input_baseline_stability_percent,'String',refine_roi.input_baseline_stability_percent);

%Roundness
set(handles.input_roundness,'String',refine_roi.input_roundness);

%Oblongness
set(handles.input_oblongness,'String',refine_roi.input_oblongness);

%Borderline Value
set(handles.input_borderline_value,'String',refine_roi.input_borderline_value);

%Borderline Style
set(handles.input_borderline_style,'String',refine_roi.input_borderline_style);

%Borderline Allowance
set(handles.input_borderline_allowance,'String',refine_roi.input_borderline_allowance);

%Saturated Value
set(handles.input_sat_value,'String',refine_roi.input_sat_value);

%Area Min
set(handles.input_area_min,'String',refine_roi.input_area_min);

%Area Max
set(handles.input_area_max,'String',refine_roi.input_area_max);

%Width Min
set(handles.input_width_min,'String',refine_roi.input_width_min);

%Width Max
set(handles.input_width_max,'String',refine_roi.input_width_max);

%Skewness Min
set(handles.input_skewness_min,'String',refine_roi.input_skewness_min);

%Skewness Max
set(handles.input_skewness_max,'String',refine_roi.input_skewness_max);

%Kurtosis Min
set(handles.input_kurtosis_min,'String',refine_roi.input_kurtosis_min);

%Kurtosis Max
set(handles.input_kurtosis_max,'String',refine_roi.input_kurtosis_max);





function input_sat_value_Callback(hObject, eventdata, handles)
% hObject    handle to input_sat_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_sat_value as text
%        str2double(get(hObject,'String')) returns contents of input_sat_value as a double


% --- Executes during object creation, after setting all properties.
function input_sat_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_sat_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in input_sat_style.
function input_sat_style_Callback(hObject, eventdata, handles)
% hObject    handle to input_sat_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_sat_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_sat_style


% --- Executes during object creation, after setting all properties.
function input_sat_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_sat_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_saturated_frames_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_saturated_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_saturated_frames as text
%        str2double(get(hObject,'String')) returns contents of ROI_saturated_frames as a double


% --- Executes during object creation, after setting all properties.
function ROI_saturated_frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_saturated_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
