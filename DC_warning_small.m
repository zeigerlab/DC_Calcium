function varargout = DC_warning_small(varargin)
% DC_WARNING_SMALL MATLAB code for DC_warning_small.fig
%      DC_WARNING_SMALL, by itself, creates a new DC_WARNING_SMALL or raises the existing
%      singleton*.
%
%      H = DC_WARNING_SMALL returns the handle to a new DC_WARNING_SMALL or the handle to
%      the existing singleton*.
%
%      DC_WARNING_SMALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DC_WARNING_SMALL.M with the given input arguments.
%
%      DC_WARNING_SMALL('Property','Value',...) creates a new DC_WARNING_SMALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DC_warning_small_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DC_warning_small_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DC_warning_small

% Last Modified by GUIDE v2.5 14-Apr-2016 10:52:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DC_warning_small_OpeningFcn, ...
                   'gui_OutputFcn',  @DC_warning_small_OutputFcn, ...
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


% --- Executes just before DC_warning_small is made visible.
function DC_warning_small_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DC_warning_small (see VARARGIN)

% Choose default command line output for DC_warning_small
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Warning text code, makes tone, and display warning in MATLAB command window
beep;
warning off backtrace
warning(varargin{1});
set(handles.text_error,'String',varargin{1});


% UIWAIT makes DC_warning_small wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DC_warning_small_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;

function close_Callback(hObject, eventdata, handles)
close;
