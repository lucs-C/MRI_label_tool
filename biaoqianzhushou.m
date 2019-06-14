function varargout = biaoqianzhushou(varargin)
% BIAOQIANZHUSHOU MATLAB code for biaoqianzhushou.fig
%      BIAOQIANZHUSHOU, by itself, creates a new BIAOQIANZHUSHOU or raises the existing
%      singleton*.
%
%      H = BIAOQIANZHUSHOU returns the handle to a new BIAOQIANZHUSHOU or the handle to
%      the existing singleton*.
%
%      BIAOQIANZHUSHOU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIAOQIANZHUSHOU.M with the given input arguments.
%
%      BIAOQIANZHUSHOU('Property','Value',...) creates a new BIAOQIANZHUSHOU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before biaoqianzhushou_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to biaoqianzhushou_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help biaoqianzhushou

% Last Modified by GUIDE v2.5 10-Jan-2019 01:04:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @biaoqianzhushou_OpeningFcn, ...
                   'gui_OutputFcn',  @biaoqianzhushou_OutputFcn, ...
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


% --- Executes just before biaoqianzhushou is made visible.
function biaoqianzhushou_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to biaoqianzhushou (see VARARGIN)

% Choose default command line output for biaoqianzhushou
handles.output = hObject;

handles.ground_truth = varargin{1};
handles.load_ground_truth_path = varargin{2};
handles.ground_truth_name = varargin{3};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes biaoqianzhushou wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = biaoqianzhushou_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ground_truth = handles.ground_truth;
CMBx_entry = str2double(get(handles.edit3,'string'));
CMBy_entry = str2double(get(handles.edit4,'string'));
CMBz_entry = str2double(get(handles.edit5,'string'));
new_CMB = [CMBx_entry,CMBy_entry,CMBz_entry];
if (sum(new_CMB)==0)
    jinggaotishi;
    pause(0.5);
    close(jinggaotishi);
else
    ground_truth = cat(1, ground_truth, new_CMB);
    handles.ground_truth = ground_truth;
    guidata(hObject, handles);
    TestGuiSlider(MRDATA,ground_truth);
    xiugaichenggong;
    pause(0.5);
    close(xiugaichenggong);
    set(handles.edit3,'string','0');
    set(handles.edit4,'string','0');
    set(handles.edit5,'string','0');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ground_truth = handles.ground_truth;
nonCMBx_entry = str2double(get(handles.edit9,'string'));
nonCMBy_entry = str2double(get(handles.edit10,'string'));
nonCMBz_entry = str2double(get(handles.edit11,'string'));
new_nonCMB = [nonCMBx_entry,nonCMBy_entry,nonCMBz_entry];
if (sum(new_nonCMB)==0)
    jinggaotishi;
    pause(0.5);
    close(jinggaotishi);
else
    [row,~] = size(new_nonCMB);
    if ~isempty(row)
        ground_truth = setdiff(ground_truth,new_nonCMB,'rows');%去除ground_truth 中包含矩阵enw_CMB的行；
    end
    handles.ground_truth = ground_truth;
    guidata(hObject, handles);
     TestGuiSlider(MRDATA,ground_truth);
    xiugaichenggong;
    pause(0.5);
    close(xiugaichenggong);
    set(handles.edit9,'string','0');
    set(handles.edit10,'string','0');
    set(handles.edit11,'string','0');
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles,vargin)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_ground_truth_path = handles.load_ground_truth_path;
ground_truth_name = handles.ground_truth_name;
ground_truth = handles.ground_truth;
save([save_ground_truth_path,ground_truth_name],'ground_truth');
% pause(2);
% close(biaoqianzhushou);
pause(2);
set(handles.figure1,'visible','off');

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
% CMBx_entry=str2double(get(hObject,'string'));%转换为双精度
% handles.CMBx_entry = CMBx_entry;
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
% CMBy_entry=str2double(get(hObject,'string'));%转换为双精度
% handles.CMBy_entry = CMBy_entry;
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
% CMBz_entry=str2double(get(hObject,'string'));%转换为双精度
% handles.CMBz_entry = CMBz_entry;
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
% nonCMBx_entry=str2double(get(hObject,'string'));%转换为双精度
% handles.nonCMBx_entry = nonCMBx_entry;
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
% nonCMBy_entry=str2double(get(hObject,'string'));%转换为双精度
% handles.nonCMBy_entry = nonCMBy_entry;
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
% nonCMBz_entry=str2double(get(hObject,'string'));%转换为双精度
% handles.nonCMBz_entry = nonCMBz_entry;
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
