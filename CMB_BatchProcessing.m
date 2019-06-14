function varargout = CMB_BatchProcessing(varargin)
% CMB_BATCHPROCESSING MATLAB code for CMB_BatchProcessing.fig
%      CMB_BATCHPROCESSING, by itself, creates a new CMB_BATCHPROCESSING or raises the existing
%      singleton*.
%
%      H = CMB_BATCHPROCESSING returns the handle to a new CMB_BATCHPROCESSING or the handle to
%      the existing singleton*.
%
%      CMB_BATCHPROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CMB_BATCHPROCESSING.M with the given input arguments.
%
%      CMB_BATCHPROCESSING('Property','Value',...) creates a new CMB_BATCHPROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CMB_BatchProcessing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CMB_BatchProcessing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CMB_BatchProcessing

% Last Modified by GUIDE v2.5 03-Jan-2019 05:41:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CMB_BatchProcessing_OpeningFcn, ...
                   'gui_OutputFcn',  @CMB_BatchProcessing_OutputFcn, ...
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


% --- Executes just before CMB_BatchProcessing is made visible.
function CMB_BatchProcessing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CMB_BatchProcessing (see VARARGIN)

% Choose default command line output for CMB_BatchProcessing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CMB_BatchProcessing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CMB_BatchProcessing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function SWI_Dir_path_Callback(hObject, eventdata, handles)
% hObject    handle to SWI_Dir_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SWI_Dir_path as text
%        str2double(get(hObject,'String')) returns contents of SWI_Dir_path as a double


% --- Executes during object creation, after setting all properties.
function SWI_Dir_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SWI_Dir_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xuanzelujing.
function xuanzelujing_Callback(hObject, eventdata, handles)
% hObject    handle to xuanzelujing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir;              %读取DICOM格式的数据；
handles.SWI_Dir_path = [folder_name,'\'];
set(handles.xianshilujing,'string',[folder_name,'\']);%在edit1（文本框）中显示结果
guidata(hObject, handles);

function ScanTyple_Callback(hObject, eventdata, handles)
% hObject    handle to ScanTyple (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanTyple as text
%        str2double(get(hObject,'String')) returns contents of ScanTyple as a double
user_string = get(hObject,'String');
handles.ScanType = user_string;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ScanTyple_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanTyple (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Batch_Processing.
function Batch_Processing_Callback(hObject, eventdata, handles)
% hObject    handle to Batch_Processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Save_groundtruth_path = './ground_truth/';
mkdir(Save_groundtruth_path);    

load net;


SWI_path =  handles.SWI_Dir_path; %存储所有病人的图像目录路径；
ScanType = handles.ScanType; %读取扫描方式；
PatientPath = SWI_path;
ii = find('\'==PatientPath);
PatientName = PatientPath(ii(1,end-1)+1:(end-1));

[MRDATA, SeriesInfo, ErrorCode] = DicomSeriesRead(PatientPath, ScanType);
voxel_size = zeros(1,3);
voxel_size(1,1:2) = SeriesInfo.PixelSpacing;
voxel_size(1,3)=SeriesInfo.SpacingBetweenSlices;
[MRdata,NomalVoxel_size] = Scale_normalization(MRDATA,voxel_size); %将原始MR图像进行尺度归一化;MRDATA是原始数据；MRdata是插值后的数据
%这里做一个分辨率规定化，如果图像像素尺度大于0.5，则将图像分辨率规定为0.5*0.5*0.5；
%如果图像像素尺度小0.5，则沿用原始图像的像素值最小尺度作为分辨率；
%     fprintf('(1/3) 正在选取候选区域,这个过程可能会持续半分钟到一分钟，请稍后......\n')
message={};
message1 = '(1/3) 正在选取候选区域,这个过程可能会持续半分钟到一分钟，请稍后......;';
message = [message;message1];
pause(0.2);
set(handles.yunxingxinxi,'string',message);pause(0.5);%在edit1（文本框）中显示结果
[Mask,VOI_Centroid] = im3scan(MRdata,NomalVoxel_size);%这里传入像素分辨率是为了计算多尺度的sigma值；
VOI_Centroid_Num=size(VOI_Centroid,1);
IMVECTOR=[];%存储所有候选点的特征矩阵
message2 = '(2/3) 开始对候选区域提取特征......;';
message = [message;message2];
pause(0.2);
set(handles.yunxingxinxi,'string',message);pause(0.5);%在edit1（文本框）中显示结果
for m=1:VOI_Centroid_Num             %VOI_Centroid_Num(1) 为候选区域的个数
    candidate=MRdata(VOI_Centroid(m,2)-10:VOI_Centroid(m,2)+10,VOI_Centroid(m,1)-10:VOI_Centroid(m,1)+10,...
        VOI_Centroid(m,3)-10:VOI_Centroid(m,3)+10);
    imvector = im3vec(candidate);
    IMVECTOR=[IMVECTOR;imvector'];
end
%     fprintf('\n(3/3) 开始进行分类预测......\n')
message3 = '(3/3) 开始进行分类预测......;';
message = [message;message3];
set(handles.yunxingxinxi,'string',message);
default_label=zeros(VOI_Centroid_Num(1),1);
[predict_label, ~, ~] = svmpredict(default_label,IMVECTOR,model);
num=size(predict_label);%num(1)的大小跟Msize(1)的大小一样
ground_truth=[];
for n=1:num(1)
    if(predict_label(n,1)==1)
        ground_truth(end+1,1)=round(VOI_Centroid(n,1)*(NomalVoxel_size(1,1)/voxel_size(1,1)));
        ground_truth(end  ,2)=round(VOI_Centroid(n,2)*(NomalVoxel_size(1,2)/voxel_size(1,2)));
        ground_truth(end  ,3)=round(VOI_Centroid(n,3)*(NomalVoxel_size(1,3)/voxel_size(1,3)));%
    end
end
CMB_Num=size(ground_truth,1);
%     fprintf(['检测出图像',DICOMImag_contents(Img_k,1).name,'中CMB的个数:%d\n'],CMB_Num);
message4 = ['检测出图像',PatientName,'中CMB的个数:',num2str(CMB_Num)];
message = [message;message4];
pause(0.2);set(handles.yunxingxinxi,'string',message);pause(0.5);
ground_truth_name = PatientName;
save([Save_groundtruth_path,ground_truth_name,'.mat'],'ground_truth');



 
% --- Executes on button press in piliangjiaozheng.
function piliangjiaozheng_Callback(hObject, eventdata, handles)
% hObject    handle to piliangjiaozheng (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SWI_path =  handles.SWI_Dir_path; %存储所有病人的图像目录路径；
ScanType = handles.ScanType; %读取扫描方式；
Save_groundtruth_path ='./ground_truth/';
PatientPath = SWI_path;
ii = find('\'==PatientPath);
PatientName = PatientPath(ii(1,end-1)+1:(end-1));
[MRDATA, SeriesInfo, ErrorCode] = DicomSeriesRead(PatientPath, ScanType);
voxel_size = zeros(1,3);
voxel_size(1,1:2) = SeriesInfo.PixelSpacing;
voxel_size(1,3)=SeriesInfo.SpacingBetweenSlices;
[MRdata,NomalVoxel_size] = Scale_normalization(MRDATA,voxel_size); %将原始MR图像进行尺度归一化;MRDATA是原始数据；MRdata是插值后的数据
%这里做一个分辨率规定化，如果图像像素尺度大于0.5，则将图像分辨率规定为0.5*0.5*0.5；
%如果图像像素尺度小0.5，则沿用原始图像的像素值最小尺度作为分辨率；
groundtruth_name = [PatientName,'.mat'];
load([Save_groundtruth_path,groundtruth_name]);%加载ground_truth;
if isempty(ground_truth)
%     fprintf([PatientName,'的CMB个数为:0','\n'])
    message1=[PatientName,'的CMB个数为:0'];
    set(handles.yunxingxinxi,'string',message1);%在edit1（文本框）中显示结果
    figure;imshow3D(MRDATA);
else
    CMB_Num=size(ground_truth,1);
    TestGuiSlider(MRDATA,ground_truth);
%     fprintf([PatientName,'的CMB个数为:%d\n'],CMB_Num)
    message2 = {[PatientName,'的CMB个数为:',num2str(CMB_Num)]};
    message3 = num2str(ground_truth);
    message2 = [message2;message3];
    set(handles.yunxingxinxi,'string',message2);%在edit1（文本框）中显示结果
%     for CMB_Num_k=1:CMB_Num
%         fprintf('%d,%d,%d\n',ground_truth(CMB_Num_k,:));
%     end
end
biaoqianzhushou(ground_truth,Save_groundtruth_path,groundtruth_name);


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;clear;close all;


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
