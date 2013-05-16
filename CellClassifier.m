function varargout = CellClassifier(varargin)
% CELLCLASSIFIER M-file for CellClassifier.fig
%      CELLCLASSIFIER, by itself, creates a new CELLCLASSIFIER or raises the existing
%      singleton*.
%
%      H = CELLCLASSIFIER returns the handle to a new CELLCLASSIFIER or the handle to
%      the existing singleton*.
%
%      CELLCLASSIFIER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLCLASSIFIER.M with the given input arguments.
%
%      CELLCLASSIFIER('Property','Value',...) creates a new CELLCLASSIFIER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CellClassifier_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CellClassifier_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CellClassifier

% Last Modified by GUIDE v2.5 08-Apr-2009 10:44:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CellClassifier_OpeningFcn, ...
                   'gui_OutputFcn',  @CellClassifier_OutputFcn, ...
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


% --- Executes just before CellClassifier is made visible.
function CellClassifier_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CellClassifier (see VARARGIN)

% Choose default command line output for CellClassifier
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CellClassifier wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CellClassifier_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function File_File_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function File_New_Callback(hObject, eventdata, handles)

try
    handles = guidata(hObject);
    [str_CellProfiler_Output_name, str_CellProfiler_Output_path] = uigetfile('*.mat', 'Load a CellProfiler Output file');
    File_Name=[str_CellProfiler_Output_path,str_CellProfiler_Output_name];
    disp('Please wait, loading data...')
    CellProfiler_Output_File=load(File_Name);

    handles.CC.Settings=struct;
    handles.CC.Settings.OutPut_File_Name=File_Name;
    try
        handles.CC.Image_File_Names=CellProfiler_Output_File.handles.Pipeline;
    catch
        disp('WARNING: The file you are trying to load is not a CellProfiler output file')
        return
    end
    handles.CC.Measurements=CellProfiler_Output_File.handles.Measurements;

    handles=Setup_CellClassifier(handles);
    guidata(hObject, handles);
    
    Load_Image;
    Draw_Image;
end
% --------------------------------------------------------------------
% Setting up the tool. Measurements and Image_File_Names (in Pipeline) must be loaded before
function handles=Setup_CellClassifier(handles)
% Emptying the memory and resetting the gui
try
    delete(handles.CC.Object_Handles.Image);
end
try
    delete(handles.CC.Object_Handles.Class_Numbers);
end
try
    delete(handles.CC.Object_Handles.Middle_Points);
end
try
    delete(handles.CC.Object_Handles.Class);
end
try
    rmfield(handles,'CC'); %removing all old fields (if any)
end
% getting the available channel names
str_channels=fieldnames(handles.CC.Image_File_Names);
handles.CC.Settings.Channel_Names={};
index=0;
for i=1:length(str_channels)
   if strcmp(str_channels{i}(1:8),'FileList')
       index=index+1;
       handles.CC.Settings.Channel_Names{index}=str_channels{i}(9:end);
   end
end

handles.CC.Picture = cell(0); %the currently displayed picture is stored here
handles.CC.Settings.Rescale_Colors = zeros(length(handles.CC.Settings.Channel_Names),2); % multiplicative and additive rescaling factors
handles.CC.Settings.Rescale_Colors(:,1)=1;
handles.CC.Settings.Channel_Colors=zeros(length(handles.CC.Settings.Channel_Names),3);
handles.CC.Settings.Channel_Colors(1,1)=1;
handles.CC.Settings.Channel_Colors(2,2)=1;
handles.CC.Settings.Channel_Colors(3,3)=1;
handles.CC.Settings.Invert_Colors=0;
handles.CC.Settings.Image_Bit_Depth=[0 1 0];
handles.CC.Settings.Class_Names = cell(0,0);
handles.CC.Settings.Show_Classified = 0; % 0: current training, 1: classified cells
handles.CC.Settings.Current_Image = 1;
handles.CC.Settings.Current_Class = 0; 
handles.CC.Settings.Class_Names = {};
handles.CC.Settings.Items={};
handles.CC.Settings.Items_raw=[];
% default settings & default advanced settings
handles.CC.Settings.Unit_List={'Image','All'}; %get this automatically from the data (needs the parsing module)
handles.CC.Settings.Panel_Size=[1600 1000];
handles.CC.Settings.Panel_Box_Size = 100 ;
handles.CC.Settings.Show_Segmentation = 2; %1=on, 2=off
handles.CC.Settings.Show_Middle_Points = 1;
handles.CC.Settings.Export_data = 'Image';
handles.CC.Settings.Normalize_measurements = 'All';
handles.CC.Settings.Normalize_measurements_List = handles.CC.Settings.Unit_List; handles.CC.Settings.Normalize_measurements_List{end+1} = 'No normalization';
handles.CC.Settings.Normalization_method = 'log Z-score';
handles.CC.Settings.Normalization_method_List = {'log Z-score','log MAD','Z-Score','MAD','log'};
handles.CC.Settings.SVM_optimizer = 'smo';
handles.CC.Settings.SVM_kernel = 'Radial basis function (Gaussian)';
handles.CC.Settings.SVM_kernel_List = {'Radial basis function (Gaussian)','Linear','Polynomial','Sigmoid'};
handles.CC.Settings.Classificator='SVM';
handles.CC.Settings.Classificator_List = {'SVM','Mperceptron','KNN','Custom'};
handles.CC.Settings.SVM_arg = '10';
handles.CC.Settings.SVM_arg_List = {'1','5','10','50','100'};
handles.CC.Settings.SVM_C = '10';
handles.CC.Settings.SVM_C_List = {'1','5','10','50','100'};
handles.CC.Settings.SVM_tmax = '50';
handles.CC.Settings.SVM_tmax_List = {'10','20','30','50','Infinite'}; 
handles.CC.Settings.SVM_verbose = 'off';
handles.CC.Settings.SVM_verbose_List = {'on','off'};
handles.CC.Settings.Feature_selection = 'None';
handles.CC.Settings.Feature_selection_List = {'None','Linear discriminant analysis (LDA)','Principal component analysis (PCA)'};
handles.CC.Settings.Number_of_features = '10';
handles.CC.Settings.Number_of_features_List = {'1','2','3','4','5','6','7','8','9','10'};

% Just checking how many object each image has
Image_Fieldnames=fieldnames(handles.CC.Measurements.Image);
for i=1:length(Image_Fieldnames);
    Object_field=Image_Fieldnames{i};
    if strcmp(Object_field(1:5),'Count')
        break;
    end
end

handles.CC.Settings.Object_Name=Object_field(7:end);
handles.CC.Settings.Total_Images=length(handles.CC.Measurements.Image.(Object_field));

for image=1:length(handles.CC.Measurements.Image.(Object_field));
    Objects_in_image=handles.CC.Measurements.Image.(Object_field){image};
    handles.CC.Trained_Cells{image}=zeros(1,Objects_in_image); % user defined training
    handles.CC.Classified_Cells{image}=zeros(1,Objects_in_image); % computer classifications
end

handles.CC.Object_Handles.Image = []; % handle to the shown image
handles.CC.Object_Handles.Class_Numbers=[]; % handles to the class numbers shows on the image
handles.CC.Object_Handles.Middle_Points=[]; % handles to the object middle points
handles.CC.Object_Handles.Class=[];  % handles to the class menu items
set(handles.figure1, 'WindowScrollWheelFcn', {@MouseWheel_Callback});

handles.CC.Settings.Current_Level=1;
handles=Set_Level(handles);

% --------------------------------------------------------------------
function File_Load_Callback(hObject, eventdata, handles)

try
    [File_Name, Path_Name] = uigetfile('*.mat', 'Load');
    File=[Path_Name,File_Name];
    disp('Please wait, loading data...')
    load(File); %Loads the Save_File  
catch
    return
end

try
    CellProfiler_Output_File=load(Save_File.Settings.OutPut_File_Name);
catch
    disp('WARNING: The file you are trying to load is not a CellClassifier save file')
    return
end
handles.CC.Image_File_Names=CellProfiler_Output_File.handles.Pipeline;
handles.CC.Measurements=CellProfiler_Output_File.handles.Measurements;

handles=Setup_CellClassifier(handles);

handles.CC.Settings=Save_File.Settings;
handles.CC.Trained_Cells=Save_File.Trained_Cells;
handles.CC.Classified_Cells=Save_File.Classified_Cells;

% Setting up the GUI
set(handles.figure1, 'WindowScrollWheelFcn', {@MouseWheel_Callback});

if handles.CC.Settings.Show_Classified==0
    set(handles.Classifier_Show_Current, 'Enable', 'on', 'Checked', 'on');
    set(handles.Classifier_Show_Classified, 'Enable', 'on', 'Checked', 'off');
else
    set(handles.Classifier_Show_Current, 'Enable', 'on', 'Checked', 'off');
    set(handles.Classifier_Show_Classified, 'Enable', 'on', 'Checked', 'on');
end

for Current_Class=1:length(handles.CC.Settings.Class_Names)
    Class_Name = handles.CC.Settings.Class_Names{Current_Class};
    handles.CC.Object_Handles.Class(Current_Class) =  uimenu('Parent',handles.Classes_Classes,...
        'Label',[num2str(Current_Class),'. ',Class_Name],...
        'HandleVisibility','callback', ...
        'Tag', num2str(Current_Class), ...
        'Callback', @Class_Callback);
end

if strcmp(handles.CC.Settings.Current_Image,'Panel')
    handles.CC.Settings.Current_Image=1;
end
handles=Set_Level(handles);
guidata(gcf, handles);

Load_Image;
Draw_Image;

% --------------------------------------------------------------------
function File_Save_Callback(hObject, eventdata, handles)
Save_File.Settings=handles.CC.Settings;
Save_File.Trained_Cells=handles.CC.Trained_Cells;
Save_File.Classified_Cells=handles.CC.Classified_Cells;

[FileName,PathName] = uiputfile('*.mat','Save');
Full_Path = fullfile(PathName, FileName);
save(Full_Path, 'Save_File');

% --------------------------------------------------------------------
function File_Export_Data_Callback(hObject, eventdata, handles)
try

    [File_Name, Path_Name] = uiputfile('*.xls', 'Export classification to .xls');
    Export=handles.CC.Settings.Export_data;
    Images=length(handles.CC.Classified_Cells);
    Classes=length(handles.CC.Settings.Class_Names);
    Table=cell(Images+1,Classes+2);
    Table{1,1}=Export;
    Table{1,Classes+2}='Total';

    if strcmp(Export,'Image')
        for Image=1:Images
            for Class=1:Classes
                Table{1,Class+1}=handles.CC.Settings.Class_Names{Class};
                Table{Image+1,1}=num2str(Image);
                Table{Image+1,Class+1}=num2str(sum(handles.CC.Classified_Cells{Image}==Class));
            end
            Table{Image+1,Class+2}=num2str(length(handles.CC.Classified_Cells{Image}));
        end
    elseif strcmp(Export,'All')
        total2=0;
        for Class=1:Classes
            total=0;
            for Image=1:Images
                total=total+sum(handles.CC.Classified_Cells{Image}==Class);
            end
            total2=total2+total;
            Table{1,Class+1}=handles.CC.Settings.Class_Names{Class};
            Table{2,1}='All';
            Table{2,Class+1}=num2str(total);
        end
        Table{2,Class+2}=num2str(total2);
    else
        items=unique(handles.CC.Settings.Image_Information.(Export));

        for item=1:length(items)
            total2=0;
            for Class=1:Classes
                indices=find(ismember(handles.CC.Settings.Image_Information.(Export),items{item}));
                total=0;
                for index=1:length(indices)
                    total=total+sum(handles.CC.Classified_Cells{indices(index)}==Class);
                end
                total2=total2+total;
                Table{1,Class+1}=handles.CC.Settings.Class_Names{Class};
                Table{item+1,1}=items{item};
                Table{item+1,Class+1}=num2str(total);
            end
            Table{item+1,Class+2}=num2str(total2);
        end
    end
    xlswrite([Path_Name,File_Name],Table);
end

% --------------------------------------------------------------------
function File_Export_Image_Callback(hObject, eventdata, handles)
[File_Name, Path_Name] = uiputfile('*.png', 'Export current image to .png');

Final_Image=zeros(size(handles.CC.Picture{1},1), size(handles.CC.Picture{1},2), 3,'uint16');
for channel=1:length(handles.CC.Settings.Channel_Names);
    RGB=find(handles.CC.Settings.Channel_Colors(channel,:));
    for i=1:length(RGB)
        Final_Image(:,:,RGB(i))=Final_Image(:,:,RGB(i))+handles.CC.Settings.Rescale_Colors(channel,1)*handles.CC.Picture{channel}+handles.CC.Settings.Rescale_Colors(channel,2);
    end
end
if handles.CC.Settings.Image_Bit_Depth(1)==1;
    maxx=256;
elseif handles.CC.Settings.Image_Bit_Depth(2)==1;
    maxx=4096;
elseif handles.CC.Settings.Image_Bit_Depth(3)==1;
    maxx=65536;
end
Final_Image=single(Final_Image)/maxx;
Final_Image(Final_Image>1)=1;
Final_Image(Final_Image<0)=0;
try
    if handles.CC.Settings.Invert_Colors
        Final_Image=1-Final_Image;
    end
end

C=256;
Final_Image=uint8(round(C*double(Final_Image)));
imwrite(Final_Image,[Path_Name,File_Name],'PNG');

% --------------------------------------------------------------------
function File_Settings_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.File_Settings=figure;
set(handles.CC.Object_Handles.File_Settings,'Position',[200 200 300 250],'MenuBar','none','Name','Settings','NumberTitle','off');

C=0.8;
Column_height=20;
y_size=20;

uicontrol('Style', 'text', 'String', 'Combine export data to','BackgroundColor',[C C C],'Position', [10 10+10*Column_height 150 y_size]);
Export_Value=find(ismember(handles.CC.Settings.Unit_List,handles.CC.Settings.Export_data));
handles.CC.Object_Handles.Settings(6)=uicontrol('Style', 'popupmenu','Value',Export_Value,'String',handles.CC.Settings.Unit_List,'BackgroundColor',[C C C],'Position', [180 15+10*Column_height 90 y_size]);

uicontrol('Style', 'text', 'String', 'Show middle points','BackgroundColor',[C C C],'Position', [10 10+9*Column_height 150 y_size]);
handles.CC.Object_Handles.Settings(5)=uicontrol('Style', 'popupmenu','Value',handles.CC.Settings.Show_Middle_Points,'String',{'on','off'},'BackgroundColor',[C C C],'Position', [180 15+9*Column_height 90 y_size]);

uicontrol('Style', 'text', 'String', 'Show segmentation','BackgroundColor',[C C C],'Position', [10 10+8*Column_height 150 y_size]);
handles.CC.Object_Handles.Settings(4)=uicontrol('Style', 'popupmenu','Value',handles.CC.Settings.Show_Segmentation,'String',{'on','off'},'BackgroundColor',[C C C],'Position', [180 15+8*Column_height 90 y_size]);

uicontrol('Style', 'text', 'String', 'Panel resolution X','BackgroundColor',[C C C],'Position', [10 10+7*Column_height 150 y_size]);
handles.CC.Object_Handles.Settings(3)=uicontrol('Style', 'edit', 'String', num2str(handles.CC.Settings.Panel_Size(1)),'BackgroundColor',[C C C],'Position', [180 15+7*Column_height 90 y_size]);

uicontrol('Style', 'text', 'String', 'Panel resolution Y','BackgroundColor',[C C C],'Position', [10 10+6*Column_height 150 y_size]);
handles.CC.Object_Handles.Settings(2)=uicontrol('Style', 'edit', 'String', num2str(handles.CC.Settings.Panel_Size(2)),'BackgroundColor',[C C C],'Position', [180 15+6*Column_height 90 y_size]);

uicontrol('Style', 'text', 'String', 'Panel box size','BackgroundColor',[C C C],'Position', [10 10+5*Column_height 150 y_size]);
handles.CC.Object_Handles.Settings(1)=uicontrol('Style', 'edit', 'String', num2str(handles.CC.Settings.Panel_Box_Size),'BackgroundColor',[C C C],'Position', [180 15+5*Column_height 90 y_size]);

uicontrol('Callback', @Settings_Advanced_Settings_Button_Callback, 'Style', 'pushbutton', 'String', 'Advanced Settings','BackgroundColor',[C C C],'Position', [70 3*Column_height 150 y_size]);

uicontrol('Callback', @Settings_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [120 10 60 30]);

guidata(gcf, handles);


% --------------------------------------------------------------------
function Settings_Advanced_Settings_Button_Callback(hObject, eventdata, handles)

handles = guidata(gcf);

handles.CC.Object_Handles.Advanced_Settings=figure;
set(handles.CC.Object_Handles.Advanced_Settings,'Position',[200 200 450 260],'MenuBar','none','Name','Advanced Settings','NumberTitle','off');

C=0.8;
Column_height=23;
y_size=20;

pos=9;
uicontrol('Style', 'text', 'String', 'Classificator function','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Classificator_Value=find(ismember(handles.CC.Settings.Classificator_List,handles.CC.Settings.Classificator));
handles.CC.Object_Handles.Settings(17)=uicontrol('Style', 'popupmenu','Value',Classificator_Value ,'String', handles.CC.Settings.Classificator_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Style', 'text', 'String', 'SVM Kernel function','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Kernel_Value=find(ismember(handles.CC.Settings.SVM_kernel_List,handles.CC.Settings.SVM_kernel));
handles.CC.Object_Handles.Settings(16)=uicontrol('Style', 'popupmenu','Value',Kernel_Value, 'String', handles.CC.Settings.SVM_kernel_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Style', 'text', 'String', 'SVM Paramenter arg','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Arg_Value=find(ismember(handles.CC.Settings.SVM_arg_List,handles.CC.Settings.SVM_arg));
handles.CC.Object_Handles.Settings(15)=uicontrol('Style', 'popupmenu','Value',Arg_Value ,'String', handles.CC.Settings.SVM_arg_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Style', 'text', 'String', 'SVM Paramenter C','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
C_Value=find(ismember(handles.CC.Settings.SVM_C_List,handles.CC.Settings.SVM_C));
handles.CC.Object_Handles.Settings(14)=uicontrol('Style', 'popupmenu','Value',C_Value , 'String', handles.CC.Settings.SVM_C_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Style', 'text', 'String', 'SVM Paramenter tmax','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Tmax_Value=find(ismember(handles.CC.Settings.SVM_tmax_List,handles.CC.Settings.SVM_tmax));
handles.CC.Object_Handles.Settings(13)=uicontrol('Style', 'popupmenu','Value',Tmax_Value , 'String', handles.CC.Settings.SVM_tmax_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Style', 'text', 'String', 'SVM Verbose','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Verbose_Value=find(ismember(handles.CC.Settings.SVM_verbose_List,handles.CC.Settings.SVM_verbose));
handles.CC.Object_Handles.Settings(12)=uicontrol('Style', 'popupmenu','Value',Verbose_Value, 'String', handles.CC.Settings.SVM_verbose_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Style', 'text', 'String', 'Feature set minimization','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Feature_Value=find(ismember(handles.CC.Settings.Feature_selection_List,handles.CC.Settings.Feature_selection));
handles.CC.Object_Handles.Settings(11)=uicontrol('Style', 'popupmenu','Value',Feature_Value, 'String', handles.CC.Settings.Feature_selection_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1; 
uicontrol('Style', 'text', 'String', 'Number of features','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Features_Value=find(ismember(handles.CC.Settings.Number_of_features_List,handles.CC.Settings.Number_of_features));
handles.CC.Object_Handles.Settings(10)=uicontrol('Style', 'popupmenu','Value',Features_Value, 'String', handles.CC.Settings.Number_of_features_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);

uicontrol('Callback', @Advanced_Settings_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [200 10 60 30]);

guidata(gcf, handles);

% --------------------------------------------------------------------
function Settings_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

handles.CC.Settings.Export_data=handles.CC.Settings.Unit_List{get(handles.CC.Object_Handles.Settings(6),'Value')};
handles.CC.Settings.Show_Middle_Points=get(handles.CC.Object_Handles.Settings(5),'Value');
handles.CC.Settings.Show_Segmentation=get(handles.CC.Object_Handles.Settings(4),'Value');
handles.CC.Settings.Panel_Size(1)=str2double(get(handles.CC.Object_Handles.Settings(3),'String'));
handles.CC.Settings.Panel_Size(2)=str2double(get(handles.CC.Object_Handles.Settings(2),'String'));
handles.CC.Settings.Panel_Box_Size=str2double(get(handles.CC.Object_Handles.Settings(1),'String'));

handles=Set_Level(handles);
delete(handles.CC.Object_Handles.File_Settings);
guidata(gcf, handles);
Load_Image;
Draw_Image;

% --------------------------------------------------------------------
function Advanced_Settings_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

handles.CC.Settings.Classificator=handles.CC.Settings.Classificator_List{get(handles.CC.Object_Handles.Settings(17),'Value')};
handles.CC.Settings.SVM_kernel=handles.CC.Settings.SVM_kernel_List{get(handles.CC.Object_Handles.Settings(16),'Value')};
handles.CC.Settings.SVM_arg=handles.CC.Settings.SVM_arg_List{get(handles.CC.Object_Handles.Settings(15),'Value')};
handles.CC.Settings.SVM_C=handles.CC.Settings.SVM_C_List{get(handles.CC.Object_Handles.Settings(14),'Value')};
handles.CC.Settings.SVM_tmax=handles.CC.Settings.SVM_tmax_List{get(handles.CC.Object_Handles.Settings(13),'Value')};
handles.CC.Settings.SVM_verbose=handles.CC.Settings.SVM_verbose_List{get(handles.CC.Object_Handles.Settings(12),'Value')};
handles.CC.Settings.Feature_selection=handles.CC.Settings.Feature_selection_List{get(handles.CC.Object_Handles.Settings(11),'Value')};
handles.CC.Settings.Number_of_features=handles.CC.Settings.Number_of_features_List{get(handles.CC.Object_Handles.Settings(10),'Value')};

handles.CC.Settings.Current_Level=3;
handles=Set_Level(handles);
delete(handles.CC.Object_Handles.Advanced_Settings);
guidata(gcf, handles);

% --------------------------------------------------------------------
function File_Parse_Images_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.File_Parse_Images=figure;
set(handles.CC.Object_Handles.File_Parse_Images,'Position',[200 200 350 100],'MenuBar','none','Name','Parse information from image filenames','NumberTitle','off');

C=0.8;
Column_height=20;
y_size=20;

uicontrol('Style', 'text', 'String', 'Use automatic well detection  ','BackgroundColor',[C C C],'Position', [10 10+3*Column_height 150 y_size]);
handles.CC.Object_Handles.Parse_Images(1)=uicontrol('Style', 'checkbox','BackgroundColor',[C C C],'Position', [180 15+3*Column_height 90 y_size]);


uicontrol('Style', 'text', 'String', 'Well to gene name mapping file','BackgroundColor',[C C C],'Position', [10 10+2*Column_height 150 y_size]);
handles.CC.Object_Handles.Parse_Images(2)=uicontrol('Callback', @Parse_Images_Browse_Callback,'Style', 'pushbutton', 'String','Browse','BackgroundColor',[C C C],'Position', [180 15+2*Column_height 150 y_size]);

handles.CC.Object_Handles.Parse_Images(4)=uicontrol('Callback', @Parse_Images_Advanced_Callback,'Style', 'pushbutton', 'String','Advanced parsing','BackgroundColor',[C C C],'Position', [180 10+0*Column_height 150 y_size]);

handles.CC.Object_Handles.Parse_Images(5)=uicontrol('Callback', @Parse_Images_OK_Callback,'Style', 'pushbutton', 'String','OK','BackgroundColor',[C C C],'Position', [50 10+0*Column_height 70 y_size]);

guidata(gcf, handles);

% --------------------------------------------------------------------
function Parse_Images_Browse_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
[File_Name, Path_Name] = uigetfile('*.xls', 'Load well to gene name mapping file');
File=[Path_Name,File_Name];
set(handles.CC.Object_Handles.Parse_Images(2),'String',File_Name);
handles.CC.Settings.ParseImages_Mapping_File=File;
guidata(gcf, handles);

% --------------------------------------------------------------------
function Parse_Images_Advanced_Callback(hObject, eventdata, handles)

handles = guidata(gcf);
delete(handles.CC.Object_Handles.File_Parse_Images);

handles.CC.Object_Handles.File_Parse_Images_Advanced=figure;
set(handles.CC.Object_Handles.File_Parse_Images_Advanced,'Position',[200 200 660 100],'MenuBar','none','Name','Advanced File Name Parsing','NumberTitle','off');

C=0.8;
Column_height=20;
y_size=20;

uicontrol('Style', 'text', 'String', 'Type Name','BackgroundColor',[C C C],'Position', [10 10+3*Column_height 150 y_size]);
handles.CC.Object_Handles.Parse_Images_Advanced(1)=uicontrol('Style', 'edit','String','NewType','BackgroundColor',[C C C],'Position', [10 10+2*Column_height 150 y_size]);

uicontrol('Style', 'text', 'String', 'Channel','BackgroundColor',[C C C],'Position', [170 10+3*Column_height 150 y_size]);
handles.CC.Object_Handles.Parse_Images_Advanced(2)=uicontrol('Style', 'popupmenu','String',handles.CC.Settings.Channel_Names,'BackgroundColor',[C C C],'Position', [170 10+2*Column_height 150 y_size]);

uicontrol('Style', 'text', 'String', 'Str Regular Expression','BackgroundColor',[C C C],'Position', [330 10+3*Column_height 150 y_size]);
handles.CC.Object_Handles.Parse_Images_Advanced(3)=uicontrol('Style', 'edit','String','_([A-P]\d\d)_','BackgroundColor',[C C C],'Position', [330 10+2*Column_height 150 y_size]);

uicontrol('Style', 'text', 'String', 'Mapping File','BackgroundColor',[C C C],'Position', [490 10+3*Column_height 150 y_size]);
handles.CC.Object_Handles.Parse_Images_Advanced(4)=uicontrol('Callback', @Parse_Images_Advanced_LoadMapping_Callback,'Style', 'pushbutton','String','Browse','BackgroundColor',[C C C],'Position', [490 10+2*Column_height 150 y_size]);

handles.CC.Object_Handles.Parse_Images_Advanced(5)=uicontrol('Callback', @Parse_Images_Advanced_OK_Callback,'Style', 'pushbutton', 'String','OK','BackgroundColor',[C C C],'Position', [290 10+0*Column_height 70 y_size]);

guidata(gcf, handles);
% --------------------------------------------------------------------
function Parse_Images_Advanced_LoadMapping_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
[File_Name, Path_Name] = uigetfile('*.xls', 'Load a mapping file');
File=[Path_Name,File_Name];
set(handles.CC.Object_Handles.Parse_Images_Advanced(4),'String',File_Name);
handles.CC.Settings.ParseImages_Advanced_Mapping_File=File;
guidata(gcf, handles);

% --------------------------------------------------------------------
function Parse_Images_Advanced_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

Type_Name=get(handles.CC.Object_Handles.Parse_Images_Advanced(1),'String');
if not(isempty(find(ismember(handles.CC.Settings.Unit_List,Type_Name))))
   disp(['WARNING: The type "',Type_Name,'" is used already. Choose another name']);
   return
end

Channels=get(handles.CC.Object_Handles.Parse_Images_Advanced(2),'String');
Channel_value=get(handles.CC.Object_Handles.Parse_Images_Advanced(2),'Value');
Channel=Channels{Channel_value};
Expression=get(handles.CC.Object_Handles.Parse_Images_Advanced(3),'String');

handles.CC.Settings.Unit_List{end+1}=Type_Name;
handles.CC.Settings.Normalize_measurements_List{end+1}=Type_Name;

for image=1:handles.CC.Settings.Total_Images
    strImageName=handles.CC.Image_File_Names.(['FileList',Channel]){image};
    Name = regexp(strImageName,Expression,'Tokens');
    if isempty(Name)
        handles.CC.Settings.Image_Information.(Type_Name){image}='NoInformation';
    else
        foo=Name{1};
        if isempty(foo{1})
            handles.CC.Settings.Image_Information.(Type_Name){image}='NoInformation';
        else
            handles.CC.Settings.Image_Information.(Type_Name){image}=foo{1};
        end
    end
end

% Using the mapping xls
if isfield(handles.CC.Settings,'ParseImages_Advanced_Mapping_File') && not(strcmp(get(handles.CC.Object_Handles.Parse_Images_Advanced(4),'String'),'Browse')) 
    [num,txt]=xlsread(handles.CC.Settings.ParseImages_Advanced_Mapping_File);
    new_unit=txt{1,2};
    if isempty(find(ismember(handles.CC.Settings.Unit_List,new_unit)))
        handles.CC.Settings.Unit_List{end+1}=new_unit;
        handles.CC.Settings.Normalize_measurements_List{end+1}=new_unit;
        for i=2:size(txt,1)
            well=txt{i,1};
            target=txt{i,2};
            indices=find(ismember(handles.CC.Settings.Image_Information.(Type_Name),well));
            for j=1:length(indices)
                handles.CC.Settings.Image_Information.(new_unit){indices(j)}=target;
            end
        end
        emptywells=find(cellfun(@isempty,handles.CC.Settings.Image_Information.(new_unit)));
        for i=1:length(emptywells)
            handles.CC.Settings.Image_Information.(new_unit){emptywells(i)}='NoMapping';
        end
    else
        disp(['WARNING: The type "',new_unit,'" has been mapped already!'])
    end
end

delete(handles.CC.Object_Handles.File_Parse_Images_Advanced);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Parse_Images_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

if get(handles.CC.Object_Handles.Parse_Images(1),'Value')==1 %has the information if the tick is pressed or not
    if isempty(find(ismember(handles.CC.Settings.Unit_List,'Well_Name'))) %automatic parsing has not been done before
        handles.CC.Settings.Image_Information.Well_Name=cell(1,handles.CC.Settings.Total_Images);
        handles.CC.Settings.Image_Information.Well_Row=cell(1,handles.CC.Settings.Total_Images);
        handles.CC.Settings.Image_Information.Well_Column=cell(1,handles.CC.Settings.Total_Images);
        handles.CC.Settings.Unit_List{end+1}='Well_Name'; 
        handles.CC.Settings.Unit_List{end+1}='Well_Row';
        handles.CC.Settings.Unit_List{end+1}='Well_Column';

        handles.CC.Settings.Normalize_measurements_List{end+1}='Well_Name';
        handles.CC.Settings.Normalize_measurements_List{end+1}='Well_Row';
        handles.CC.Settings.Normalize_measurements_List{end+1}='Well_Column';

        for image=1:handles.CC.Settings.Total_Images
            [intRow, intColumn, strWellName] = filterimagenamedata(handles.CC.Image_File_Names.(['FileList',handles.CC.Settings.Channel_Names{1}]){image});
            handles.CC.Settings.Image_Information.Well_Name{image}=strWellName;
            handles.CC.Settings.Image_Information.Well_Row{image}=num2str(intRow);
            handles.CC.Settings.Image_Information.Well_Column{image}=num2str(intColumn);
        end
    else
        disp(['WARNING: Automatic well mapping has been done already!'])
    end
end

% Using the mapping xls
if isfield(handles.CC.Settings,'ParseImages_Mapping_File') && not(strcmp(get(handles.CC.Object_Handles.Parse_Images(2),'String'),'Browse'))
    [num,txt]=xlsread(handles.CC.Settings.ParseImages_Mapping_File);
    new_unit=txt{1,2};
    if isempty(find(ismember(handles.CC.Settings.Unit_List,new_unit)))
        handles.CC.Settings.Unit_List{end+1}=new_unit;
        handles.CC.Settings.Normalize_measurements_List{end+1}=new_unit;
        for i=2:size(txt,1)
            well=txt{i,1};
            target=txt{i,2};
            indices=find(ismember(handles.CC.Settings.Image_Information.Well_Name,well));
            for j=1:length(indices)
                handles.CC.Settings.Image_Information.(new_unit){indices(j)}=target;
            end
        end
        emptywells=find(cellfun(@isempty,handles.CC.Settings.Image_Information.(new_unit)));
        for i=1:length(emptywells)
            handles.CC.Settings.Image_Information.(new_unit){emptywells(i)}='NoMapping';
        end
    else
        disp(['WARNING: The type "',new_unit,'" has been mapped already!'])
    end
end

delete(handles.CC.Object_Handles.File_Parse_Images);
guidata(gcf, handles);
% --------------------------------------------------------------------
function File_Exit_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.File_Exit=figure;
set(handles.CC.Object_Handles.File_Exit,'Position',[200 200 300 40],'MenuBar','none','Name','Are you sure you want to exit?','NumberTitle','off');

C=0.8;
uicontrol('Callback', @Exit_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [120 5 60 30]);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Exit_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
delete(handles.CC.Object_Handles.File_Exit);
delete(handles.figure1);

% --------------------------------------------------------------------
% ADD CELL SEGMENTATION LOADING HERE
function Load_Image()

handles = guidata(gcf);
if not(strcmp(handles.CC.Settings.Current_Image,'Panel')) % if we are in the panel we do not load anything
    channels=length(handles.CC.Settings.Channel_Names);
    for channel=1:channels
        path_name=handles.CC.Image_File_Names.(['Pathname',handles.CC.Settings.Channel_Names{channel}]);
        file_name=handles.CC.Image_File_Names.(['FileList',handles.CC.Settings.Channel_Names{channel}]){handles.CC.Settings.Current_Image};
        path_name=strrep(path_name,'/',filesep);
        path_name=strrep(path_name,'\',filesep);
        file_name=strrep(file_name,'/',filesep);
        file_name=strrep(file_name,'\',filesep);
        handles.CC.Picture{channel}=uint16(imread([path_name,filesep,file_name]));
    end
    
    if handles.CC.Settings.Show_Segmentation==1
        fieldss=fieldnames(handles.CC.Measurements);
        for field=1:length(fieldss)
            try           
                path_segmentation=handles.CC.Measurements.Image.([fieldss{field},'_SegmentationPath']){handles.CC.Settings.Current_Image};
                im=imread(path_segmentation);
                edges=edge(double(im),'roberts',0);
                handles.CC.Picture{1}=handles.CC.Picture{1}+uint16(2^16*edges);
                handles.CC.Picture{2}=handles.CC.Picture{2}+uint16(2^16*edges);
                handles.CC.Picture{3}=handles.CC.Picture{3}+uint16(2^16*edges);
            end
        end

    end

    guidata(gcf, handles);
end
% --------------------------------------------------------------------
function Draw_Image()
handles = guidata(gcf);
% SETUP
try
    Axis_handles=get(handles.CC.Object_Handles.Image,'Parent');
    delete(Axis_handles);
end
try
    delete(handles.CC.Object_Handles.Image);
end
try
    delete(handles.CC.Object_Handles.Class_Numbers);
end
try
    delete(handles.CC.Object_Handles.Middle_Points);
end
handles.CC.Object_Handles.Image=[];
hold on;
axis off

% DRAWING THE IMAGE
Image=handles.CC.Settings.Current_Image;
Final_Image=zeros(size(handles.CC.Picture{1},1), size(handles.CC.Picture{1},2), 3,'uint16');
for channel=1:length(handles.CC.Settings.Channel_Names);
    RGB=find(handles.CC.Settings.Channel_Colors(channel,:));
    for i=1:length(RGB)
        Final_Image(:,:,RGB(i))=Final_Image(:,:,RGB(i))+handles.CC.Settings.Rescale_Colors(channel,1)*handles.CC.Picture{channel}+handles.CC.Settings.Rescale_Colors(channel,2);
    end
end
if handles.CC.Settings.Image_Bit_Depth(1)==1;
    maxx=256;
elseif handles.CC.Settings.Image_Bit_Depth(2)==1;
    maxx=4096;
elseif handles.CC.Settings.Image_Bit_Depth(3)==1;
    maxx=65536;
end
Final_Image=single(Final_Image)/maxx;
Final_Image(Final_Image>1)=1;
Final_Image(Final_Image<0)=0;
try
    if handles.CC.Settings.Invert_Colors
        Final_Image=1-Final_Image;
    end
end
handles.CC.Object_Handles.Image = image(Final_Image);
set(handles.CC.Object_Handles.Image,'ButtonDownFcn',@Image_ButtonDownFcn)
Axis_handle=get(handles.CC.Object_Handles.Image,'Parent');
set(Axis_handle,'Position',[0 0 1 1])
axis(Axis_handle,'tight');
axis(Axis_handle,'equal');

In_Panel=strcmp(handles.CC.Settings.Current_Image,'Panel');

% DRAWING OBJECT MIDDLE POINTS AND DATA NUMBERS
if In_Panel
    Object_Data=zeros(1,size(handles.CC.Panel_Data.Location,1));
    Number_Color=[1 1 1];
    %handles.CC.Settings.Show_Classified=1;
else
    if handles.CC.Settings.Show_Classified==0 % display the user classified value
        Object_Data=handles.CC.Trained_Cells{Image};
        Number_Font='Helvetica';
    elseif handles.CC.Settings.Show_Classified==1 % display the SVM values
        Object_Data=handles.CC.Classified_Cells{Image};
        Number_Font='Brush Script MT';
    end
end

Objects=length(Object_Data);
handles.CC.Object_Handles.Class_Numbers=zeros(1,Objects);
handles.CC.Object_Handles.Middle_Points=zeros(1,Objects);
for Object=1:Objects
    
    if In_Panel
        Position(1)=handles.CC.Panel_Data.Location(Object,1);
        Position(2)=handles.CC.Panel_Data.Location(Object,2);
    else
        Position(1)=handles.CC.Measurements.(handles.CC.Settings.Object_Name).Location_Center_X{Image}(Object);
        Position(2)=handles.CC.Measurements.(handles.CC.Settings.Object_Name).Location_Center_Y{Image}(Object);
    end

    if handles.CC.Settings.Show_Middle_Points == 1
        handles.CC.Object_Handles.Middle_Points(Object) = plot(Position(1),Position(2), 'w*');
        set(handles.CC.Object_Handles.Middle_Points(Object),'Color',[1 1 1],'MarkerSize',4,'HitTest','off');
    end
    if Object_Data(Object)~=0 %number zeros are not drawn
        handles.CC.Object_Handles.Class_Numbers(Object) = text(Position(1)+3, Position(2)+1, num2str(Object_Data(Object)));
        set(handles.CC.Object_Handles.Class_Numbers(Object),'Color',[1 1 1],'FontName',Number_Font,'HitTest','off');
    end
end

% drawing the header
set(handles.figure1,'Name', get_Title(handles));

%drawing the panel lines
if In_Panel
    Classes=length(handles.CC.Settings.Class_Names);
    X_Size=handles.CC.Settings.Panel_Size(1);
    Y_Size=handles.CC.Settings.Panel_Size(2);
    X_Column=handles.CC.Settings.X_Column_Size;
    
    for Class=1:Classes
       plot([X_Column*Class X_Column*Class],[0 Y_Size],'w')
       h=text(X_Column*(Class-1)+20,Y_Size-30,handles.CC.Settings.Class_Names{Class});
       set(h,'Color',[1 1 1]);
    end
    
end
    
% ENABLING REQUIRED BUTTONS 
set(handles.View_Rescale_Colors,'Enable','on')

guidata(gcf, handles);

% --------------------------------------------------------------------
function Name=get_Title(handles)
Units=handles.CC.Settings.Unit_List;
Name='CellClassifier';

if strcmp(handles.CC.Settings.Current_Image,'Panel')
    information='Panel';
else
    information=['Image: ',num2str(handles.CC.Settings.Current_Image)];
    for i=3:length(handles.CC.Settings.Unit_List)
        textt=[', ',handles.CC.Settings.Unit_List{i},': ',handles.CC.Settings.Image_Information.(handles.CC.Settings.Unit_List{i}){handles.CC.Settings.Current_Image}];
        information=[information,textt];
    end
end

if handles.CC.Settings.Current_Class==0
    Add='Current Class: Unclassify';
else
    Add=['Current Class: ',num2str(handles.CC.Settings.Current_Class),' (',handles.CC.Settings.Class_Names{handles.CC.Settings.Current_Class},')'];
end
Name=[Name,'  |  ', information,'  |  ',Add,];

% --------------------------------------------------------------------
function View_View_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function View_Rescale_Colors_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.Rescale_Figure_Handle=figure;

Channels=length(handles.CC.Settings.Channel_Names);
Figure_Position=get(handles.CC.Object_Handles.Rescale_Figure_Handle,'Position');
set(handles.CC.Object_Handles.Rescale_Figure_Handle,'Position',[200 200 90*(Channels+1)+500 420],'MenuBar','none','Name','Rescale Colors','NumberTitle','off');

if handles.CC.Settings.Image_Bit_Depth(1)==1;
    maxx=256;
elseif handles.CC.Settings.Image_Bit_Depth(2)==1;
    maxx=4096;
elseif handles.CC.Settings.Image_Bit_Depth(3)==1;
    maxx=65536;
end

Button_Labels={'R','G','B'};
C=0.8;
for channel=1:Channels;
    uicontrol('Style', 'text', 'String', handles.CC.Settings.Channel_Names{channel},'BackgroundColor',[C C C],'Position', [90*(channel-1)+30 380 70 20]);
    uicontrol('Style', 'text', 'String', 'x','BackgroundColor',[C C C],'Position', [90*(channel-1)+40 55 20 13]);
    uicontrol('Style', 'text', 'String', '+','BackgroundColor',[C C C],'Position', [90*(channel-1)+64 55 20 13]);
    
    handles.CC.Object_Handles.Rescale_Slider(channel,1) = uicontrol('Tag',num2str(channel),'Callback', @Rescale_Slider_Callback,'Value',handles.CC.Settings.Rescale_Colors(channel,1),'Min',0,'Max',6,'Style', 'slider', 'String', 'Clear','BackgroundColor',[C C C],'Position', [90*(channel-1)+40 80 20 300]); 
    handles.CC.Object_Handles.Rescale_Slider(channel,2) = uicontrol('Tag',num2str(-channel),'Callback', @Rescale_Slider_Callback,'Value',handles.CC.Settings.Rescale_Colors(channel,2),'Min',-maxx,'Max',maxx,'Style', 'slider', 'String', 'Clear','BackgroundColor',[C C C],'Position', [90*(channel-1)+64 80 20 300]);
    handles.CC.Object_Handles.Rescale_Text_Box(channel,1)= uicontrol('Style', 'text', 'String', num2str(handles.CC.Settings.Rescale_Colors(channel,1)),'BackgroundColor',[C C C],'Position', [90*(channel-1)+40 65 20 13]);
    handles.CC.Object_Handles.Rescale_Text_Box(channel,2) =uicontrol('Style', 'text', 'String', num2str(handles.CC.Settings.Rescale_Colors(channel,2)),'BackgroundColor',[C C C],'Position', [90*(channel-1)+60 65 30 13]);
    
    for button=1:3
        if handles.CC.Settings.Channel_Colors(channel,button)==1
            Value=1;
        else
            Value=0;
        end
        handles.CC.Object_Handles.Button_Handles(channel,button)=uicontrol('Value',Value,'Tag',num2str(10*channel+button),'Callback', @Rescale_Button_Callback,'Style','radiobutton', 'String', Button_Labels{button},'BackgroundColor',[C C C],'Position', [90*(channel-1)+85 300-20*button 40 15]); 
    end
end
uicontrol('Callback', @Rescale_OK_Callback,'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [90*Channels/2-20 20 80 30]);
uicontrol('Callback', @Rescale_Invert_Callback,'Style', 'checkbox','Value',handles.CC.Settings.Invert_Colors,'String', 'Invert Colors','BackgroundColor',[C C C],'Position', [90*Channels/2+80 30 80 30]);

handles.CC.Object_Handles.Bit_Handles(1)=uicontrol('Value',handles.CC.Settings.Image_Bit_Depth(1),'Tag',num2str(1),'Callback', @Bit_Button_Callback,'Style','radiobutton', 'String', '','BackgroundColor',[C C C],'Position', [90*Channels/2+80 20 14 15]); 
handles.CC.Object_Handles.Bit_Handles(2)=uicontrol('Value',handles.CC.Settings.Image_Bit_Depth(2),'Tag',num2str(2),'Callback', @Bit_Button_Callback,'Style','radiobutton', 'String', '','BackgroundColor',[C C C],'Position', [90*Channels/2+95 20 14 15]); 
handles.CC.Object_Handles.Bit_Handles(3)=uicontrol('Value',handles.CC.Settings.Image_Bit_Depth(3),'Tag',num2str(3),'Callback', @Bit_Button_Callback,'Style','radiobutton', 'String', '','BackgroundColor',[C C C],'Position', [90*Channels/2+110 20 14 15]); 
uicontrol('Style', 'text', 'String', 'Bits (8-12-16)','BackgroundColor',[C C C],'Position', [90*Channels/2+125 20 70 15]);

Draw_Rescale_Preview(handles);
guidata(gcf, handles);


% --------------------------------------------------------------------
function Rescale_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
delete(handles.CC.Object_Handles.Rescale_Figure_Handle);
guidata(handles.figure1, handles);
Draw_Image;

% --------------------------------------------------------------------
function Rescale_Button_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
Tag=str2double(get(hObject,'Tag'));
Channel=round(Tag/10);
Button=rem(Tag,10);
handles.CC.Settings.Channel_Colors(Channel,Button)=1-handles.CC.Settings.Channel_Colors(Channel,Button);
set(handles.CC.Object_Handles.Button_Handles(Channel,Button),'Value',handles.CC.Settings.Channel_Colors(Channel,Button));

Draw_Rescale_Preview(handles);
guidata(gcf, handles);
% --------------------------------------------------------------------
function Bit_Button_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
Tag=str2double(get(hObject,'Tag'));
handles.CC.Settings.Image_Bit_Depth=[0 0 0];
handles.CC.Settings.Image_Bit_Depth(Tag)=1;
set(handles.CC.Object_Handles.Bit_Handles(1),'Value',handles.CC.Settings.Image_Bit_Depth(1));
set(handles.CC.Object_Handles.Bit_Handles(2),'Value',handles.CC.Settings.Image_Bit_Depth(2));
set(handles.CC.Object_Handles.Bit_Handles(3),'Value',handles.CC.Settings.Image_Bit_Depth(3));

if handles.CC.Settings.Image_Bit_Depth(1)==1;
    maxx=256;
elseif handles.CC.Settings.Image_Bit_Depth(2)==1;
    maxx=4096;
elseif handles.CC.Settings.Image_Bit_Depth(3)==1;
    maxx=65536;
end
for channel=1:length(handles.CC.Settings.Channel_Names)
    set(handles.CC.Object_Handles.Rescale_Slider(channel,2),'Value',0,'Min',-maxx,'Max',maxx);
    handles.CC.Settings.Rescale_Colors(channel,2)=0;
end

Draw_Rescale_Preview(handles);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Rescale_Slider_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

Channel=str2double(get(hObject,'Tag'));
Value=get(hObject,'Value');
if Channel>0
    handles.CC.Settings.Rescale_Colors(Channel,1)=Value;
    set(handles.CC.Object_Handles.Rescale_Text_Box(Channel,1),'String',num2str(round(Value*10)/10));
else
    handles.CC.Settings.Rescale_Colors(-Channel,2)=Value;
    set(handles.CC.Object_Handles.Rescale_Text_Box(-Channel,2),'String',num2str(round(Value)));
end

Draw_Rescale_Preview(handles);
guidata(gcf, handles);
% --------------------------------------------------------------------
function Rescale_Invert_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
get(hObject,'Value');
handles.CC.Settings.Invert_Colors=get(hObject,'Value');

Draw_Rescale_Preview(handles);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Draw_Rescale_Preview(handles)
Image=handles.CC.Settings.Current_Image;
Final_Image=zeros(size(handles.CC.Picture{1},1), size(handles.CC.Picture{1},2), 3,'uint16');
for channel=1:length(handles.CC.Settings.Channel_Names);
    RGB=find(handles.CC.Settings.Channel_Colors(channel,:));
    for i=1:length(RGB)
        Final_Image(:,:,RGB(i))=Final_Image(:,:,RGB(i))+handles.CC.Settings.Rescale_Colors(channel,1)*handles.CC.Picture{channel}+handles.CC.Settings.Rescale_Colors(channel,2);
    end
end

if handles.CC.Settings.Image_Bit_Depth(1)==1;
    maxx=256;
elseif handles.CC.Settings.Image_Bit_Depth(2)==1;
    maxx=4096;
elseif handles.CC.Settings.Image_Bit_Depth(3)==1;
    maxx=65536;
end

Final_Image=single(Final_Image)/maxx;
Final_Image(Final_Image>1)=1;
Final_Image(Final_Image<0)=0;
try
    if handles.CC.Settings.Invert_Colors
        Final_Image=1-Final_Image;
    end
end

Preview_Image_Handle=image(Final_Image(1:3:end,1:3:end,:));
Axes_Handle=get(Preview_Image_Handle,'Parent');
Position=get(Axes_Handle,'Position');
set(Axes_Handle,'Position',[0.45 0.1 0.5 0.8],'Visible','off');

% --------------------------------------------------------------------
function View_Next_Image_Callback(hObject, eventdata, handles)
if strcmp(handles.CC.Settings.Current_Image,'Panel')
    handles.CC.Settings.Current_Image = 1;
else
    handles.CC.Settings.Current_Image = mod(handles.CC.Settings.Current_Image,handles.CC.Settings.Total_Images)+1;
end
guidata(gcf, handles);
if handles.CC.Settings.Show_Classified==1 && sum(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image})==0 
    Classifier_Show_Classified_Callback(hObject, eventdata, handles);%recalculating the numbers
end

Load_Image;
Draw_Image;

% --------------------------------------------------------------------
function View_Previous_Image_Callback(hObject, eventdata, handles)
% hObject    handle to View_Previous_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.CC.Settings.Current_Image,'Panel')
    handles.CC.Settings.Current_Image = 1;
else
    if handles.CC.Settings.Current_Image ==1
        handles.CC.Settings.Current_Image=handles.CC.Settings.Total_Images;
    else
        handles.CC.Settings.Current_Image=handles.CC.Settings.Current_Image-1;
    end
end
guidata(gcf, handles);
if handles.CC.Settings.Show_Classified==1 && sum(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image})==0
    Classifier_Show_Classified_Callback(hObject, eventdata, handles); %recalculating the numbers
end
Load_Image;
Draw_Image;

% --------------------------------------------------------------------
function View_Go_to_Image_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.GoTo_Image_Handle=figure;

set(handles.CC.Object_Handles.GoTo_Image_Handle,'Position',[200 200 500 280],'MenuBar','none','Name','Go To Image','NumberTitle','off');

C=0.8;
handles.CC.Object_Handles.GoToImage(1)=uicontrol('Style', 'text','String','Information on the selected image:','FontWeight','bold','BackgroundColor',[C C C],'Position', [30 210+40 450 20],'HorizontalAlignment','left');

information=['Image: ',num2str(handles.CC.Settings.Current_Image)];

try
    for i=3:length(handles.CC.Settings.Unit_List)
        textt=[', ',handles.CC.Settings.Unit_List{i},': ',handles.CC.Settings.Image_Information.(handles.CC.Settings.Unit_List{i}){handles.CC.Settings.Current_Image}];
        information=[information,textt];
    end
catch % panel view

end


try
    cells=length(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image});
catch  %panel view
    cells=0;
end

if strcmp(handles.CC.Settings.Current_Image,'Panel')
    information2='';
elseif handles.CC.Settings.Current_Level<7 
    information2=['Cell number: ',num2str(cells)];
else % if every image is classified
    information2=['Cell number: ',num2str(cells),', Classes: '];
    if not(isempty(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}));
        textt=[];
        for class=1:length(handles.CC.Settings.Class_Names);
            cells2=sum(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}==class);
            textt=[textt,handles.CC.Settings.Class_Names{class},': ',num2str(cells2),' (',num2str(round(100*cells2/cells)),'%), '];
        end
        information2=[information2,textt(1:end-2)];
    end
end

%keyboard

handles.CC.Object_Handles.GoToImage(2)=uicontrol('Style', 'text','String',information,'BackgroundColor',[C C C],'Position', [30 210+25 460 20],'HorizontalAlignment','left');
handles.CC.Object_Handles.GoToImage(3)=uicontrol('Style', 'text','String',information2,'BackgroundColor',[C C C],'Position', [30 210 460 30],'HorizontalAlignment','left');

handles.CC.Object_Handles.GoToImage(4)=uicontrol('Style', 'text','String','Image:','BackgroundColor',[C C C],'Position', [30 160+15 50 20],'HorizontalAlignment','left');
if strcmp(handles.CC.Settings.Current_Image,'Panel')
    handles.CC.Object_Handles.GoToImage(5)=uicontrol('Callback', @GoToImage_ImageSlider_Callback,'Style', 'slider','Value',1, 'Min',1,'Max',handles.CC.Settings.Total_Images,'BackgroundColor',[C C C],'Position', [30 160 370 20]);
    handles.CC.Object_Handles.GoToImage(6)=uicontrol('Callback', @GoToImage_ImageNumberEdit_Callback,'Style', 'edit','String','Panel','BackgroundColor',[C C C],'Position', [420 160 40 20]);
else   
    handles.CC.Object_Handles.GoToImage(5)=uicontrol('Callback', @GoToImage_ImageSlider_Callback,'Style', 'slider','Value',handles.CC.Settings.Current_Image, 'Min',1,'Max',handles.CC.Settings.Total_Images,'BackgroundColor',[C C C],'Position', [30 160 370 20]);
    handles.CC.Object_Handles.GoToImage(6)=uicontrol('Callback', @GoToImage_ImageNumberEdit_Callback,'Style', 'edit','String',num2str(handles.CC.Settings.Current_Image),'BackgroundColor',[C C C],'Position', [420 160 40 20]);
end

if length(handles.CC.Settings.Unit_List)>2 %there are actially some parsed types
    handles.CC.Object_Handles.GoToImage(7)=uicontrol('Style', 'text','String' , 'Type:','BackgroundColor',[C C C],'Position', [30 110+15 50 20],'HorizontalAlignment','left');
    handles.CC.Object_Handles.GoToImage(8)=uicontrol('Callback', @GoToImage_TypeUpdate_Callback,'Style', 'popupmenu', 'String', handles.CC.Settings.Unit_List(3:end),'BackgroundColor',[C C C],'Position', [30 110 200 20]);
    handles.CC.Object_Handles.GoToImage(9)=uicontrol('Style', 'text', 'String', 'Value:','BackgroundColor',[C C C],'Position', [260 110+15 50 20],'HorizontalAlignment','left');
    handles.CC.Object_Handles.GoToImage(10)=uicontrol('Callback', @GoToImage_ValueUpdate_Callback,'Style', 'popupmenu', 'String', sort(unique(handles.CC.Settings.Image_Information.(handles.CC.Settings.Unit_List{3}))),'BackgroundColor',[C C C],'Position', [260 110 200 20]);
end

if handles.CC.Settings.Current_Level==7
    handles.CC.Object_Handles.GoToImage(11)=uicontrol('Style', 'text', 'String', 'Classes:','BackgroundColor',[C C C],'Position', [30 60+15 50 20],'HorizontalAlignment','left');
    handles.CC.Object_Handles.GoToImage(12)=uicontrol('Style', 'popupmenu', 'String', handles.CC.Settings.Class_Names,'BackgroundColor',[C C C],'Position', [30 60 200 20]);
    handles.CC.Object_Handles.GoToImage(13)=uicontrol('Style', 'text', 'String', 'Top images:','BackgroundColor',[C C C],'Position', [260 60+15 150 20],'HorizontalAlignment','left');
    handles.CC.Object_Handles.GoToImage(14)=uicontrol('Callback', @GoToImage_TopImages_Callback,'Style', 'popupmenu', 'String', 1:handles.CC.Settings.Total_Images,'BackgroundColor',[C C C],'Position', [260 60 200 20]);
end
handles.CC.Object_Handles.GoToImage(15)=uicontrol('Callback', @GoToImage_OK_Callback,'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [210 10 70 30]);

guidata(gcf, handles);
% --------------------------------------------------------------------
function GoToImage_ImageSlider_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

handles.CC.Settings.Current_Image=round(get(handles.CC.Object_Handles.GoToImage(5),'Value'));

% Updating current image edit box
set(handles.CC.Object_Handles.GoToImage(6),'String',num2str(handles.CC.Settings.Current_Image));

% Updating image information box
information=['Image: ',num2str(handles.CC.Settings.Current_Image)];
for i=3:length(handles.CC.Settings.Unit_List)
    textt=[', ',handles.CC.Settings.Unit_List{i},': ',handles.CC.Settings.Image_Information.(handles.CC.Settings.Unit_List{i}){handles.CC.Settings.Current_Image}];
    information=[information,textt];
end

cells=length(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image});
if handles.CC.Settings.Current_Level<7
    information2=['Cell number: ',num2str(cells)];
else % if every image is classified
    information2=['Cell number: ',num2str(cells),', Classes: '];
    if not(isempty(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}));
        textt=[];
        for class=1:length(handles.CC.Settings.Class_Names);
            cells2=sum(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}==class);
            textt=[textt,handles.CC.Settings.Class_Names{class},': ',num2str(cells2),' (',num2str(round(100*cells2/cells)),'%), '];
        end
        information2=[information2,textt(1:end-2)];
    end
end
set(handles.CC.Object_Handles.GoToImage(2),'String',information);
set(handles.CC.Object_Handles.GoToImage(3),'String',information2);

% Updating the value box
if length(handles.CC.Settings.Unit_List)>2
    value_list=get(handles.CC.Object_Handles.GoToImage(10),'String');
    selected=get(handles.CC.Object_Handles.GoToImage(8),'Value');
    selected_types=get(handles.CC.Object_Handles.GoToImage(8),'String');
    selected_type=selected_types{selected};
    current_value=handles.CC.Settings.Image_Information.(selected_type){handles.CC.Settings.Current_Image};
    ii=ismember(value_list,current_value);
    set(handles.CC.Object_Handles.GoToImage(10),'Value',find(ii));
end

guidata(gcf, handles);

% --------------------------------------------------------------------
function GoToImage_TypeUpdate_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
selected=get(handles.CC.Object_Handles.GoToImage(8),'Value');
selected_types=get(handles.CC.Object_Handles.GoToImage(8),'String');
selected_type=selected_types{selected};
set(handles.CC.Object_Handles.GoToImage(10),'String',sort(unique(handles.CC.Settings.Image_Information.(selected_type))));
set(handles.CC.Object_Handles.GoToImage(10),'Value',1);

guidata(gcf, handles);
% --------------------------------------------------------------------
function GoToImage_ValueUpdate_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
selected=get(handles.CC.Object_Handles.GoToImage(8),'Value');
selected_types=get(handles.CC.Object_Handles.GoToImage(8),'String');
selected_type=selected_types{selected};

selected_value=get(handles.CC.Object_Handles.GoToImage(10),'Value');
values=get(handles.CC.Object_Handles.GoToImage(10),'String');
value=values(selected_value);

image_indices=find(ismember(handles.CC.Settings.Image_Information.(selected_type),value));
handles.CC.Settings.Current_Image=image_indices(1);

% Updating image information box
information=['Image: ',num2str(handles.CC.Settings.Current_Image)];
for i=3:length(handles.CC.Settings.Unit_List)
    textt=[', ',handles.CC.Settings.Unit_List{i},': ',handles.CC.Settings.Image_Information.(handles.CC.Settings.Unit_List{i}){handles.CC.Settings.Current_Image}];
    information=[information,textt];
end
cells=length(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image});
if handles.CC.Settings.Current_Level<7
    information2=['Cell number: ',num2str(cells)];
else % if every image is classified
    information2=['Cell number: ',num2str(cells),', Classes: '];
    if not(isempty(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}));
        textt=[];
        for class=1:length(handles.CC.Settings.Class_Names);
            cells2=sum(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}==class);
            textt=[textt,handles.CC.Settings.Class_Names{class},': ',num2str(cells2),' (',num2str(round(100*cells2/cells)),'%), '];
        end
        information2=[information2,textt(1:end-2)];
    end
end
set(handles.CC.Object_Handles.GoToImage(2),'String',information);
set(handles.CC.Object_Handles.GoToImage(3),'String',information2);

% updating the image number slider
set(handles.CC.Object_Handles.GoToImage(5),'Value',handles.CC.Settings.Current_Image);

% Updating current image edit box
set(handles.CC.Object_Handles.GoToImage(6),'String',num2str(handles.CC.Settings.Current_Image));

guidata(gcf, handles);
% --------------------------------------------------------------------
function GoToImage_ImageNumberEdit_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
image=str2double(get(handles.CC.Object_Handles.GoToImage(6),'String'));

if isnumeric(image) && image>0 && image<=handles.CC.Settings.Total_Images
    handles.CC.Settings.Current_Image=round(image);
    
    % Updating image information box
    information=['Image: ',num2str(handles.CC.Settings.Current_Image)];
    for i=3:length(handles.CC.Settings.Unit_List)
        textt=[', ',handles.CC.Settings.Unit_List{i},': ',handles.CC.Settings.Image_Information.(handles.CC.Settings.Unit_List{i}){handles.CC.Settings.Current_Image}];
        information=[information,textt];
    end
    cells=length(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image});
    if handles.CC.Settings.Current_Level<7
        information2=['Cell number: ',num2str(cells)];
    else % if every image is classified
        information2=['Cell number: ',num2str(cells),', Classes: '];
        if not(isempty(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}));
            textt=[];
            for class=1:length(handles.CC.Settings.Class_Names);
                cells2=sum(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}==class);
                textt=[textt,handles.CC.Settings.Class_Names{class},': ',num2str(cells2),' (',num2str(round(100*cells2/cells)),'%), '];
            end
            information2=[information2,textt(1:end-2)];
        end
    end
    set(handles.CC.Object_Handles.GoToImage(2),'String',information);
    set(handles.CC.Object_Handles.GoToImage(3),'String',information2);

    % updating the image number slider
    set(handles.CC.Object_Handles.GoToImage(5),'Value',handles.CC.Settings.Current_Image);

    % Updating the value box
    if length(handles.CC.Settings.Unit_List)>2
        value_list=get(handles.CC.Object_Handles.GoToImage(10),'String');
        selected=get(handles.CC.Object_Handles.GoToImage(8),'Value');
        selected_types=get(handles.CC.Object_Handles.GoToImage(8),'String');
        selected_type=selected_types{selected};
        current_value=handles.CC.Settings.Image_Information.(selected_type){handles.CC.Settings.Current_Image};
        ii=ismember(value_list,current_value);
        set(handles.CC.Object_Handles.GoToImage(10),'Value',find(ii));
    end

else
    set(handles.CC.Object_Handles.GoToImage(6),'String',num2str(handles.CC.Settings.Current_Image))
end

guidata(gcf, handles);
% --------------------------------------------------------------------
function GoToImage_TopImages_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
class=get(handles.CC.Object_Handles.GoToImage(12),'Value');
selected_top=get(handles.CC.Object_Handles.GoToImage(14),'Value');

for image=1:handles.CC.Settings.Total_Images
    phenotypes(image)=sum(handles.CC.Classified_Cells{image}==class);
end

[sorted,pos]=sort(phenotypes);
handles.CC.Settings.Current_Image=pos(end+1-selected_top);

% Updating image information box
information=['Image: ',num2str(handles.CC.Settings.Current_Image)];
for i=3:length(handles.CC.Settings.Unit_List)
    textt=[', ',handles.CC.Settings.Unit_List{i},': ',handles.CC.Settings.Image_Information.(handles.CC.Settings.Unit_List{i}){handles.CC.Settings.Current_Image}];
    information=[information,textt];
end
cells=length(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image});
if handles.CC.Settings.Current_Level<7
    information2=['Cell number: ',num2str(cells)];
else % if every image is classified
    information2=['Cell number: ',num2str(cells),', Classes: '];
    if not(isempty(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}));
        textt=[];
        for class=1:length(handles.CC.Settings.Class_Names);
            cells2=sum(handles.CC.Classified_Cells{handles.CC.Settings.Current_Image}==class);
            textt=[textt,handles.CC.Settings.Class_Names{class},': ',num2str(cells2),' (',num2str(round(100*cells2/cells)),'%), '];
        end
        information2=[information2,textt(1:end-2)];
    end
end
set(handles.CC.Object_Handles.GoToImage(2),'String',information);
set(handles.CC.Object_Handles.GoToImage(3),'String',information2);

% updating the image number slider
set(handles.CC.Object_Handles.GoToImage(5),'Value',handles.CC.Settings.Current_Image);

% Updating the value box
if length(handles.CC.Settings.Unit_List)>2
    value_list=get(handles.CC.Object_Handles.GoToImage(10),'String');
    selected=get(handles.CC.Object_Handles.GoToImage(8),'Value');
    selected_types=get(handles.CC.Object_Handles.GoToImage(8),'String');
    selected_type=selected_types{selected};
    current_value=handles.CC.Settings.Image_Information.(selected_type){handles.CC.Settings.Current_Image};
    ii=ismember(value_list,current_value);
    set(handles.CC.Object_Handles.GoToImage(10),'Value',find(ii));
end

% Updating current image edit box
set(handles.CC.Object_Handles.GoToImage(6),'String',num2str(handles.CC.Settings.Current_Image));


guidata(gcf, handles);
% --------------------------------------------------------------------
function GoToImage_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
delete(handles.CC.Object_Handles.GoTo_Image_Handle);
guidata(handles.figure1, handles);

Load_Image;
Draw_Image;
% --------------------------------------------------------------------
function View_Go_to_Panel_Callback(hObject, eventdata, handles)
Images=handles.CC.Settings.Total_Images;
Classes=length(handles.CC.Settings.Class_Names);
Channels=length(handles.CC.Settings.Channel_Names);

box_size=handles.CC.Settings.Panel_Box_Size;
rand_images=10;
xsize=handles.CC.Settings.Panel_Size(1);
ysize=handles.CC.Settings.Panel_Size(2);
xcolumn=floor((xsize)/(Classes)); %width of the column
yrow=ysize;   % heigth of a row
xboxes=floor(xcolumn/box_size); %number of boxes per row
yboxes=floor((yrow-60)/box_size); %number of boxes per column
Boxes=xboxes*yboxes; %total number of boxes
Table=reshape(1:Boxes,[yboxes,xboxes]); % a look up table for box positions

handles.CC.Settings.X_Column_Size=xcolumn;

disp('Please wait. Gathering cells for the panel view...')

% Setting up the panel image
for Channel=1:Channels
    handles.CC.Picture{Channel} = uint16(zeros(ysize,xsize));
end

Nucleus_Index=0;
for Index=1:rand_images
    Image=ceil(rand*Images);

    % loading the image
    for Channel=1:Channels
        path_name=handles.CC.Image_File_Names.(['Pathname',handles.CC.Settings.Channel_Names{Channel}]);
        file_name=handles.CC.Image_File_Names.(['FileList',handles.CC.Settings.Channel_Names{Channel}]){Image};
        Picture{Channel}=uint16(imread([path_name,filesep,file_name]));
    end

    if handles.CC.Settings.Show_Segmentation==1
        fieldss=fieldnames(handles.CC.Measurements);
        for field=1:length(fieldss)
            try
                path_segmentation=handles.CC.Measurements.Image.([fieldss{field},'_SegmentationPath']){Image};
                im=imread(path_segmentation);
                edges=edge(double(im),'roberts',0);
                Picture{1}=Picture{1}+uint16(2^16*edges);
                Picture{2}=Picture{2}+uint16(2^16*edges);
                Picture{3}=Picture{3}+uint16(2^16*edges);
            end
        end

    end
    
    for Class=1:Classes
        Nuclei_Indices=find(handles.CC.Classified_Cells{Image}==Class);
        Nuclei_Positions_X=handles.CC.Measurements.(handles.CC.Settings.Object_Name).Location_Center_X{Image}(Nuclei_Indices,:);
        Nuclei_Positions_Y=handles.CC.Measurements.(handles.CC.Settings.Object_Name).Location_Center_Y{Image}(Nuclei_Indices,:);
        for Cell=(((Index-1)*ceil(Boxes/rand_images))+1):((Index)*ceil(Boxes/rand_images))
            [y,x]=find(Table==Cell);
            if not(isempty(y)) %goes over for the last image (fills the panel completely)
                if length(Nuclei_Indices>0)
                    nucleus=ceil(rand*length(Nuclei_Indices));
                    z=ceil([Nuclei_Positions_X(nucleus,:) Nuclei_Positions_Y(nucleus,:)]); %'CenterX'    'CenterY'
                    xmin=(Class-1)*xcolumn+(x-1)*box_size+1; % these are wrong!
                    ymin=ysize-(y-1)*box_size-box_size-60;  % these are wrong!

                    for Channel=1:Channels
                        box{Channel}=zeros(box_size);
                        box{Channel}=imcrop(Picture{Channel},[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]); %[XMIN YMIN WIDTH HEIGHT]
                        handles.CC.Picture{Channel}((ymin+1):(ymin+size(box{Channel},1)),(xmin+1):(xmin+size(box{Channel},2)))=box{Channel};
                    end

                    % creating the pseudodata for the panel
                    Nucleus_Index=Nucleus_Index+1;
                    handles.CC.Panel_Data.Location(Nucleus_Index,:)=[xmin+box_size/2, ymin+box_size/2];
                    handles.CC.Panel_Data.Original_Nucleus_Index(Nucleus_Index)=Nuclei_Indices(nucleus);
                    handles.CC.Panel_Data.Original_Image_Index(Nucleus_Index)=Image;
                end
            end
        end
    end
end

handles.CC.Settings.Current_Image='Panel';

guidata(gcf, handles);
Draw_Image;

% --------------------------------------------------------------------
function Classifier_Classifier_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function Classifier_Show_Current_Callback(hObject, eventdata, handles)
set(handles.Classifier_Show_Current, 'Enable', 'on', 'Checked', 'on');
set(handles.Classifier_Show_Classified, 'Enable', 'on', 'Checked', 'off');
handles.CC.Settings.Show_Classified=0;

guidata(gcf, handles);
Draw_Image;

% --------------------------------------------------------------------
function Classifier_Show_Classified_Callback(hObject, eventdata, handles)
set(handles.Classifier_Show_Current, 'Enable', 'on', 'Checked', 'off');
set(handles.Classifier_Show_Classified, 'Enable', 'on', 'Checked', 'on');
handles.CC.Settings.Show_Classified=1;
guidata(gcf, handles);

Draw_Image;


% --------------------------------------------------------------------
function Classifier_Normalize_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

handles.CC.Object_Handles.Normalize=figure;
set(handles.CC.Object_Handles.Normalize,'Position',[200 200 450 120],'MenuBar','none','Name','Normalize Data','NumberTitle','off');

C=0.8;
Column_height=23;
y_size=20;

pos=3;

uicontrol('Style', 'text', 'String', 'Normalize measurements','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Normalize_Value=find(ismember(handles.CC.Settings.Normalize_measurements_List,handles.CC.Settings.Normalize_measurements));
handles.CC.Object_Handles.Normalize_Setup(1)=uicontrol('Style', 'popupmenu','Value',Normalize_Value, 'String', handles.CC.Settings.Normalize_measurements_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Style', 'text', 'String', 'Normalization method','BackgroundColor',[C C C],'Position', [10 10+pos*Column_height 150 y_size]);
Method_Value=find(ismember(handles.CC.Settings.Normalization_method_List,handles.CC.Settings.Normalization_method));
handles.CC.Object_Handles.Normalize_Setup(2)=uicontrol('Style', 'popupmenu','Value',Method_Value, 'String', handles.CC.Settings.Normalization_method_List,'BackgroundColor',[C C C],'Position', [200 15+pos*Column_height 200 y_size]);
pos=pos-1;
uicontrol('Callback', @Normalize_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [200 10 60 30]);

guidata(gcf, handles);

% --------------------------------------------------------------------
function Normalize_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

handles.CC.Settings.Normalize_measurements=handles.CC.Settings.Normalize_measurements_List{get(handles.CC.Object_Handles.Normalize_Setup(1),'Value')};
handles.CC.Settings.Normalization_method=handles.CC.Settings.Normalization_method_List{get(handles.CC.Object_Handles.Normalize_Setup(2),'Value')};

% GATHER DATA HERE!
Images=handles.CC.Settings.Total_Images;
Items=handles.CC.Settings.Items;
Items=handles.CC.Settings.Items;
if size(Items,1)==0
    disp('Please select some measurements from the Measurement Setup before normalization!');
    delete(handles.CC.Object_Handles.Normalize);
    return
end
disp(['Normalizing data, Please wait...'])

Cell_Index=0;
Training_Data_Normalization_Tag=cell(0);
for Image=1:Images

    Cells=length(handles.CC.Trained_Cells{Image});
    if Cells<50
        foo=1:Cells;
    else
        foo=1:50:Cells;
    end
    for Cell=foo
        Cell_Index=Cell_Index+1;
        for Item=1:size(Items,1)
            try
                if ischar(handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image})
                    old_data0(Item,Cell_Index)=0;
                else
                    old_data0(Item,Cell_Index)=handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image}(Cell);
                end
            catch
                old_data0(Item,Cell_Index)=handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image}(1); %image feature etc
            end
        end
        if strcmp(handles.CC.Settings.Normalize_measurements,'Image')
            Normalization_Tag{Cell_Index}=num2str(Image);
        elseif strcmp(handles.CC.Settings.Normalize_measurements,'All')
            Normalization_Tag{Cell_Index}='1';
        elseif strcmp(handles.CC.Settings.Normalize_measurements,'No normalization')
            Normalization_Tag{Cell_Index}='0';

        else
            Normalization_Tag{Cell_Index}=handles.CC.Settings.Image_Information.(handles.CC.Settings.Normalize_measurements){Image};
        end
    end

    if strcmp(handles.CC.Settings.Normalize_measurements,'Image')
        Normalization_Tag_Image{Image}=num2str(Image);
    elseif strcmp(handles.CC.Settings.Normalize_measurements,'All')
        Normalization_Tag_Image{Image}='1';
    elseif strcmp(handles.CC.Settings.Normalize_measurements,'No normalization')
        Normalization_Tag_Image{Image}='0';
    else
        Normalization_Tag_Image{Image}=handles.CC.Settings.Image_Information.(handles.CC.Settings.Normalize_measurements){Image};
    end
end

handles.CC.Settings.Normalization_Tag_Image=Normalization_Tag_Image;
handles.CC.Settings.Normalization_Tags=unique(Normalization_Tag_Image);

% Data normalization
handles.CC.Settings.Normalization_Parameters.mu=cell(0);
handles.CC.Settings.Normalization_Parameters.sigma=cell(0);
handles.CC.Settings.Normalization_Parameters.med=cell(0);
handles.CC.Settings.Normalization_Parameters.mad=cell(0);

if not(strcmp(handles.CC.Settings.Normalize_measurements,'No normalization'))
    items=unique(Normalization_Tag_Image); % A bit confusing to use word item here with normalization tags
    item_index=0;
    for item=items
        item_index=item_index+1;
        indices=find(ismember(Normalization_Tag,item));
        old_data=old_data0(:,indices);
        if strcmp(handles.CC.Settings.Normalization_method,'log Z-score')
            new_data=log2(old_data);
            [new_data,mu,sigma]=nanzscore(new_data'); 
            handles.CC.Settings.Normalization_Parameters.mu{item_index}=mu;
            handles.CC.Settings.Normalization_Parameters.sigma{item_index}=sigma;
        elseif strcmp(handles.CC.Settings.Normalization_method,'log MAD') 
            new_data=log2(old_data);
            med=median(new_data');
            new_data=new_data-repmat(med',[1,size(new_data,2)]);
            madd=mad(new_data');
            new_data=(new_data./repmat(madd',[1,size(new_data,2)]))';
            handles.CC.Settings.Normalization_Parameters.med{item_index}=med;
            handles.CC.Settings.Normalization_Parameters.mad{item_index}=madd;
        elseif strcmp(handles.CC.Settings.Normalization_method,'Z-Score')
            new_data=old_data;
            [new_data,mu,sigma]=nanzscore(new_data'); 
            handles.CC.Settings.Normalization_Parameters.mu{item_index}=mu;
            handles.CC.Settings.Normalization_Parameters.sigma{item_index}=sigma;
        elseif strcmp(handles.CC.Settings.Normalization_method,'MAD')
            new_data=old_data;
            med=median(new_data');
            new_data=new_data-repmat(med',[1,size(new_data,2)]);
            madd=mad(new_data');
            new_data=(new_data./repmat(madd',[1,size(new_data,2)]))';
            handles.CC.Settings.Normalization_Parameters.med{item_index}=med;
            handles.CC.Settings.Normalization_Parameters.mad{item_index}=madd;
        elseif strcmp(handles.CC.Settings.Normalization_method,'log')
            new_data=log2(old_data)';
        end
    end
end
disp(['Normalization done.'])

delete(handles.CC.Object_Handles.Normalize);
handles.CC.Settings.Current_Level=4;
handles=Set_Level(handles);
guidata(gcf, handles);


% --------------------------------------------------------------------
function Classifier_Train_Callback(hObject, eventdata, handles)
disp(' ')

Images=handles.CC.Settings.Total_Images;
Classes=length(handles.CC.Settings.Class_Names);
Items=handles.CC.Settings.Items;
if size(Items,1)==0
    disp('WARNING: Please select some measurements from the Measurement Setup.');
    return
end

% Setting up the SVM parameters

SVM_Options.bin_svm = 'smo';%handles.CC.Settings.SVM_optimizer;
if strcmp(handles.CC.Settings.SVM_kernel,'Radial basis function (Gaussian)')
    SVM_Options.ker = 'rbf';
elseif strcmp(handles.CC.Settings.SVM_kernel,'Linear')
    SVM_Options.ker = 'linear';
elseif strcmp(handles.CC.Settings.SVM_kernel,'Polynomial')
    SVM_Options.ker = 'polynomial';
elseif strcmp(handles.CC.Settings.SVM_kernel,'Sigmoid')
    SVM_Options.ker = 'sigmoid';
end
    
if strcmp(handles.CC.Settings.SVM_verbose,'off')
    SVM_Options.verb=0;
else
    SVM_Options.verb=1;
end

% NOTE: optimization is currently deactivated. Causes more problems than
% solves. Maybe can be put back in the future.
if strcmp(handles.CC.Settings.SVM_C,'Optimized')
    SVM_Options0.C=[1 5 10 30 100];
    disp('Optimizing SVM parameter C.')
else
    SVM_Options0.C=str2double(handles.CC.Settings.SVM_C);
end
if strcmp(handles.CC.Settings.SVM_arg,'Optimized')
    SVM_Options0.arg=[1 5 10 30 100];
    disp('Optimizing SVM parameter arg.')
else
    SVM_Options0.arg=str2double(handles.CC.Settings.SVM_arg);
end
if strcmp(handles.CC.Settings.SVM_tmax,'Infinite')
    SVM_Options.tmax = 10000;
else
    SVM_Options.tmax = str2double(handles.CC.Settings.SVM_tmax);
end

% Gathering the training data
Cell_Index=0;
Training_Data_Normalization_Tag=cell(0);
for Image=1:Images
    Trained_Cells=find(handles.CC.Trained_Cells{Image}>0);
    for Cell=Trained_Cells
        Cell_Index=Cell_Index+1;
        Training_Data.y(Cell_Index)=handles.CC.Trained_Cells{Image}(Cell);
        for Item=1:size(Items,1)
            try
                if ischar(handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image})
                    Training_Data.X(Item,Cell_Index)=0;
                else
                    Training_Data.X(Item,Cell_Index)=handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image}(Cell);
                end
            catch
                Training_Data.X(Item,Cell_Index)=handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image}(1); %image feature etc
            end
        end
        if strcmp(handles.CC.Settings.Normalize_measurements,'Image')
            Training_Data_Normalization_Tag{Cell_Index}=num2str(Image);
        elseif strcmp(handles.CC.Settings.Normalize_measurements,'All')
            Training_Data_Normalization_Tag{Cell_Index}='1';
        elseif strcmp(handles.CC.Settings.Normalize_measurements,'No normalization')
            Training_Data_Normalization_Tag{Cell_Index}='0';
        else
            Training_Data_Normalization_Tag{Cell_Index}=handles.CC.Settings.Image_Information.(handles.CC.Settings.Normalize_measurements){Image};
        end
    end
    handles.CC.Classified_Cells{Image}=zeros(size(handles.CC.Classified_Cells{Image})); %emptying the previous classification
end
if isempty(Training_Data_Normalization_Tag)
    disp('WARNING: Please click on some cells before training.');
    return
end
if length(unique(Training_Data.y))<length(handles.CC.Settings.Class_Names)
    disp('WARNING: Some classes do not have any cells trained by the user.');
    return
end

% Data normalization
if not(strcmp(handles.CC.Settings.Normalize_measurements,'No normalization'))
    items=unique(Training_Data_Normalization_Tag);
    item_index=0;
    for item=items
        item_index=item_index+1;
        indices=find(ismember(Training_Data_Normalization_Tag,item));
        old_data=Training_Data.X(:,indices);
        if strcmp(handles.CC.Settings.Normalization_method,'log Z-score')
            new_data=log2(old_data);
            new_data=new_data-repmat(handles.CC.Settings.Normalization_Parameters.mu{item_index}',[1,size(new_data,2)]);
            new_data=(new_data./repmat(handles.CC.Settings.Normalization_Parameters.sigma{item_index}',[1,size(new_data,2)]))';
        elseif strcmp(handles.CC.Settings.Normalization_method,'log MAD')
            new_data=log2(old_data);
            new_data=new_data-repmat(handles.CC.Settings.Normalization_Parameters.med{item_index}',[1,size(new_data,2)]);
            new_data=(new_data./repmat(handles.CC.Settings.Normalization_Parameters.mad{item_index}',[1,size(new_data,2)]))';
        elseif strcmp(handles.CC.Settings.Normalization_method,'Z-Score')
            new_data=old_data;
            new_data=new_data-repmat(handles.CC.Settings.Normalization_Parameters.mu{item_index}',[1,size(new_data,2)]);
            new_data=(new_data./repmat(handles.CC.Settings.Normalization_Parameters.sigma{item_index}',[1,size(new_data,2)]))';
        elseif strcmp(handles.CC.Settings.Normalization_method,'MAD')
            new_data=old_data;     
            new_data=new_data-repmat(handles.CC.Settings.Normalization_Parameters.med{item_index}',[1,size(new_data,2)]);
            new_data=(new_data./repmat(handles.CC.Settings.Normalization_Parameters.mad{item_index}',[1,size(new_data,2)]))';
        elseif strcmp(handles.CC.Settings.Normalization_method,'log')
            new_data=log2(old_data)';
        end
        Training_Data.X(:,indices)=new_data';
    end
end


if sum(sum(~~imag(Training_Data.X)))~=0
    disp('Warning: Training data has complex numbers. They are replaced with zeros.')
    Training_Data.X(~~imag(Training_Data.X))=0;
end
if sum(sum(isnan(Training_Data.X)))~=0
    disp('Warning: Training data has NaN values. They are replaced with zeros.')
    Training_Data.X(isnan(Training_Data.X))=0;
end
if sum(sum(isinf(Training_Data.X)))~=0
    disp('Warning: Training data has Inf values. They are replaced with zeros.')
    Training_Data.X(isinf(Training_Data.X))=0;
end

if strcmp(handles.CC.Settings.Number_of_features,'Automatic') %THIS IS OBSOLETE
    disp('Automatic feature number detection is not yet implemented.')
    Features=min(10,size(Items,1));
else
    Features=min(str2double(handles.CC.Settings.Number_of_features),size(Items,1));
end

if strcmp(handles.CC.Settings.Feature_selection,'Recursive feature elimination (RFE)') %THIS IS OBSOLETE
    disp('RFE is not yet implemented')
    Feature_Model=[];
elseif strcmp(handles.CC.Settings.Feature_selection,'Linear discriminant analysis (LDA)')
    disp('Performing LDA.')
    try
        Feature_Model=lda(Training_Data,Features);
        Training_Data.X=linproj(Training_Data.X,Feature_Model);
    catch
        disp('LDA could not be performed. The covariance matrix may be singular.')
        handles.CC.Settings.Feature_selection='None';
        Feature_Model=[];
    end

elseif strcmp(handles.CC.Settings.Feature_selection,'Principal component analysis (PCA)')
    disp('Performing PCA.')
    try
        Feature_Model=pca(Training_Data.X,Features);
        Training_Data.X=linproj(Training_Data.X,Feature_Model);
    catch
        disp('PCA could not be performed. The covariance matrix may be singular.')
        handles.CC.Settings.Feature_selection='None';
        Feature_Model=[];
    end
else
    Feature_Model=[];
end

if not(isfield(handles.CC.Settings,'Classificator'))
    handles.CC.Settings.Classificator='';
end

if strcmp(handles.CC.Settings.Classificator,'Mperceptron')
    disp(['Learning Mperceptron, Please wait...'])
    handles.CC.Settings.Mperceptron_Model=mperceptron(Training_Data);
    disp(['Learning done.'])
elseif strcmp(handles.CC.Settings.Classificator,'KNN')
    disp(['Learning KNN, Please wait...'])
    handles.CC.Settings.KNN_Model=knnrule(Training_Data,8);
    disp(['Learning done.'])
elseif strcmp(handles.CC.Settings.Classificator,'Custom')
    % ADD HERE YOU OWN CLASSIFICATOR FUNCTION
    % INPUT: Training_Data with fields X (feature vectors) and y (object labels)
    % OUTPUT: A single struct: model that includes all necessary data for the classifier
    disp(['Learning Custom, Please wait...'])
    handles.CC.Settings.Custom_Model=[];
    disp(['Learning done.'])
else
    disp(['Learning SVM, Please wait...'])
    Errors=zeros(length(SVM_Options0.C),length(SVM_Options0.arg));
    Cindex=0;
    for C=SVM_Options0.C
        Cindex=Cindex+1;
        argindex=0;
        for arg=SVM_Options0.arg
            argindex=argindex+1;
            SVM_Options.C=C;
            SVM_Options.arg=arg;
            Models{Cindex,argindex}=oaosvm(Training_Data,SVM_Options); % the actual learning
            Errors(Cindex,argindex)=Models{Cindex,argindex}.trnerr;
        end
    end
    disp(['Learning done.'])

    try
        [y,x]=find(Errors==min(Errors(:)));
        Model=Models{x(1),y(1)};
    catch
        x=find(Errors==min(Errors));
        Model=Models{x(1)};
    end
    if strcmp(handles.CC.Settings.SVM_C,'Optimized') || strcmp(handles.CC.Settings.SVM_arg,'Optimized')
        if length(SVM_Options0.C)==1
            disp(['The optimal SVM parameters are: C=',num2str(SVM_Options0.C(1)),', arg=',num2str(SVM_Options0.arg(x(1)))]);
        elseif length(SVM_Options0.arg)==1
            disp(['The optimal SVM parameters are: C=',num2str(SVM_Options0.C(x(1))),', arg=',num2str(SVM_Options0.arg(1))]);
        else
            disp(['The optimal SVM parameters are: C=',num2str(SVM_Options0.C(x(1))),', arg=',num2str(SVM_Options0.arg(x(1)))]);
        end
    end
    disp(['Training error: ',num2str(min(Errors(:)))]);
    
    handles.CC.Settings.SVM_Model=Model;
    handles.CC.Settings.SVM_Options=SVM_Options;
end

handles.CC.Settings.Show_Classified=0;
handles.CC.Settings.Training_Data=Training_Data;
handles.CC.Settings.Feature_Model=Feature_Model;

handles.CC.Settings.Current_Level=6;
handles=Set_Level(handles);
guidata(hObject,handles);
Draw_Image;

% --------------------------------------------------------------------
function Classifier_Classify_All_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.Classifier_Classify_All=figure;
set(handles.CC.Object_Handles.Classifier_Classify_All,'Position',[200 200 420 40],'MenuBar','none','Name','Classifying all cells may take several minutes (or hours)!','NumberTitle','off');

C=0.8;
uicontrol('Callback', @Classify_All_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [180 5 60 30]);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Classify_All_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
delete(handles.CC.Object_Handles.Classifier_Classify_All);
C=0.8;

Items=handles.CC.Settings.Items;
tic
for Image=1:handles.CC.Settings.Total_Images
    timestamp=(handles.CC.Settings.Total_Images-Image)*toc;
    h=round(timestamp/3600);
    m=round((timestamp-h*3600)/60);
    disp(['Classifying image: ',num2str(Image),' of ',num2str(handles.CC.Settings.Total_Images),'. Approx. time left: ',num2str(h),'h ',num2str(m),'min '])
    tic
    if sum(handles.CC.Classified_Cells{Image})==0 %not classifying, if done previously
        Data=zeros(size(Items,1),length(handles.CC.Trained_Cells{Image}));
        for Cell=1:length(handles.CC.Trained_Cells{Image})
            for Item=1:size(Items,1)
                try
                    if ischar(handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image})
                        Data(Item,Cell)=0;
                    else
                        Data(Item,Cell)=handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image}(Cell);
                    end
                catch
                    Data(Item,Cell)=handles.CC.Measurements.(Items{Item,1}).(Items{Item,2}){Image}(1); %image feature etc
                end
            end
        end

        item_index=find(ismember(handles.CC.Settings.Normalization_Tags,handles.CC.Settings.Normalization_Tag_Image{Image}));

        if strcmp(handles.CC.Settings.Normalization_method,'log Z-score')
            Data=log2(Data);
            Data=Data-repmat(handles.CC.Settings.Normalization_Parameters.mu{item_index}',[1 size(Data,2)]);
            Data=Data./repmat(handles.CC.Settings.Normalization_Parameters.sigma{item_index}',[1 size(Data,2)]);
        elseif strcmp(handles.CC.Settings.Normalization_method,'log MAD')
            Data=log2(Data);
            Data=Data-repmat(handles.CC.Settings.Normalization_Parameters.med{item_index}',[1 size(Data,2)]);
            Data=Data./repmat(handles.CC.Settings.Normalization_Parameters.mad{item_index}',[1 size(Data,2)]);
        elseif strcmp(handles.CC.Settings.Normalization_method,'Z-Score')
            Data=Data-repmat(handles.CC.Settings.Normalization_Parameters.mu{item_index}',[1 size(Data,2)]);
            Data=Data./repmat(handles.CC.Settings.Normalization_Parameters.sigma{item_index}',[1 size(Data,2)]);
        elseif strcmp(handles.CC.Settings.Normalization_method,'MAD')
            Data=Data-repmat(handles.CC.Settings.Normalization_Parameters.med{item_index}',[1 size(Data,2)]);
            Data=Data./repmat(handles.CC.Settings.Normalization_Parameters.mad{item_index}',[1 size(Data,2)]);
        elseif strcmp(handles.CC.Settings.Normalization_method,'log')
            Data=log2(Data);
        end

        Data(~~imag(Data))=0;
        Data(isnan(Data))=0;
        Data(isinf(Data))=0;

        if strcmp(handles.CC.Settings.Feature_selection,'Linear discriminant analysis (LDA)') || strcmp(handles.CC.Settings.Feature_selection,'Principal component analysis (PCA)')
            Data=linproj(Data,handles.CC.Settings.Feature_Model);
        end


        if isempty(Data) %if no cells in the image
            handles.CC.Classified_Cells{Image} = [];
        else
            if strcmp(handles.CC.Settings.Classificator,'Mperceptron')
                handles.CC.Classified_Cells{Image} = linclass(Data,handles.CC.Settings.Mperceptron_Model);
            elseif strcmp(handles.CC.Settings.Classificator,'KNN')
                handles.CC.Classified_Cells{Image} = knnclass(Data,handles.CC.Settings.KNN_Model);
            elseif strcmp(handles.CC.Settings.Classificator,'Custom')
                % ADD HERE YOUR OWN CLASSIFIER FUNCTION
                % INPUT: the model 
                % OUTPUT: Class labels of objets
                handles.CC.Classified_Cells{Image} = [];
            else
                handles.CC.Classified_Cells{Image} = mvsvmclass(Data,handles.CC.Settings.SVM_Model);
            end
        end
    end
end
disp('Classificating all is done.')

handles.CC.Settings.Current_Level=7;
handles=Set_Level(handles);

guidata(gcf, handles);
Draw_Image;

% --------------------------------------------------------------------
function Classifier_Show_SVM_Callback(hObject, eventdata, handles)
disp('Please wait, creating confusion matrices...')

colSize=(3+length(handles.CC.Settings.Class_Names))*100;
rowSize=(5+2*length(handles.CC.Settings.Class_Names))*22;

handles.CC.Object_Handles.Show_SVM=figure;

colnames = handles.CC.Settings.Class_Names; 
colnames{end+1}='Total';
colnames{end+1}='Correct %';
rownames = handles.CC.Settings.Class_Names;
rownames{end+1}='Total';

classes=length(handles.CC.Settings.Class_Names);

% results on the full data
data1=zeros(length(handles.CC.Settings.Class_Names)+1,length(handles.CC.Settings.Class_Names)+2);
results=mvsvmclass(handles.CC.Settings.Training_Data.X,handles.CC.Settings.SVM_Model);
for class=1:classes
    indices=handles.CC.Settings.Training_Data.y==class;
    for class2=1:classes
        data1(class,class2)=data1(class,class2)+sum(results(indices)==class2);
    end
end
data1(classes+1,1:classes)=sum(data1(1:classes,1:classes));
data1(1:classes+1,classes+1)=sum(data1(1:classes+1,1:classes)')';
for class=1:classes
   data1(class,classes+2)= round(100*data1(class,class)/data1(class,classes+1));
end
data1(classes+1,classes+2)=sum(data1(1:classes,classes+2))/classes;

for i=2:size(data1,1)+1
    dataa{i,1}=rownames{i-1};
    for j=2:size(data1,2)+1
        dataa{1,j}=colnames{j-1};
        dataa{i,j}=num2str(data1(i-1,j-1));
    end
end
dataa{1,1}='Full Data';

%results on the bootstrapped train/test set data
data3=zeros(length(handles.CC.Settings.Class_Names)+1,length(handles.CC.Settings.Class_Names)+2);
for boot=1:20
    data2=zeros(length(handles.CC.Settings.Class_Names)+1,length(handles.CC.Settings.Class_Names)+2);
    train_indices=[];
    test_indices=[];
    for class=1:classes
        indices=find(handles.CC.Settings.Training_Data.y==class);
        indices0=randperm(length(indices));
        cut=round(length(indices)*0.7);
        train_indices=[train_indices indices(indices0(1:cut))]; 
        test_indices=[test_indices indices(indices0(cut+1:end))];
    end

    train_data.X=handles.CC.Settings.Training_Data.X(:,train_indices);
    train_data.y=handles.CC.Settings.Training_Data.y(train_indices);

    if strcmp(handles.CC.Settings.Classificator,'Mperceptron')
        Mperceptron_Model=mperceptron(train_data);
    elseif strcmp(handles.CC.Settings.Classificator,'KNN')
        KNN_Model=knnrule(train_data,8);
    elseif strcmp(handles.CC.Settings.Classificator,'Custom')
        % ADD HERE YOU OWN CLASSIFICATOR FUNCTION
        % INPUT: Training_Data with fields X (feature vectors) and y (object labels)
        % OUTPUT: A single struct: model that includes all necessary data for the classifier
        Custom_Model=[];
    else
        SVM_model=oaosvm(train_data,handles.CC.Settings.SVM_Options);
    end

    test_data=handles.CC.Settings.Training_Data.X(:,test_indices);
    true_results=handles.CC.Settings.Training_Data.y(test_indices);
    
    if strcmp(handles.CC.Settings.Classificator,'Mperceptron')
        results=linclass(test_data,Mperceptron_Model);
    elseif strcmp(handles.CC.Settings.Classificator,'KNN')
        results=knnclass(test_data,KNN_Model);
    elseif strcmp(handles.CC.Settings.Classificator,'Custom')
        % ADD HERE YOUR OWN CLASSIFIER FUNCTION
        % INPUT: the model
        % OUTPUT: Class labels of objets
        results=[];
    else
        results=mvsvmclass(test_data,SVM_model);
    end

    for class=1:classes
        indices=true_results==class;
        for class2=1:classes
            data2(class,class2)=data2(class,class2)+sum(results(indices)==class2);
        end
    end
    data2(classes+1,1:classes)=sum(data2(1:classes,1:classes));
    data2(1:classes+1,classes+1)=sum(data2(1:classes+1,1:classes)')';
    for class=1:classes
        data2(class,classes+2)= round(100*data2(class,class)/data2(class,classes+1));
    end
    data2(classes+1,classes+2)=sum(data2(1:classes,classes+2))/classes;

    data3=data3+data2/20;
end

for i=2:size(data2,1)+1
    dataa{i+classes+3,1}=rownames{i-1};
    for j=2:size(data2,2)+1
        dataa{1+classes+3,j}=colnames{j-1};
        dataa{i+classes+3,j}=num2str(data3(i-1,j-1));
    end
end
dataa{1+classes+3,1}='Cross Validation';

C=0.8;
handles.CC.Object_Handles.Classifier_Show_SVM(1)= uitable('Data',dataa,'RowName',[],'ColumnName',[],'Parent',handles.CC.Object_Handles.Show_SVM,'Position',[0 0 colSize rowSize]);

ss=get(handles.CC.Object_Handles.Classifier_Show_SVM(1),'Extent');
pp=get(handles.CC.Object_Handles.Classifier_Show_SVM(1),'Position');
set(handles.CC.Object_Handles.Show_SVM,'Position',[200 200 ss(3) pp(4)],'MenuBar','none','Name','Confusion Matrix','NumberTitle','off');

% --------------------------------------------------------------------
function Classes_Classes_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function Classes_Add_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.Classes_Add=figure;
set(handles.CC.Object_Handles.Classes_Add,'Position',[200 200 390 40],'MenuBar','none','Name','Add Class','NumberTitle','off');

C=0.8;
handles.CC.Object_Handles.Classes_Add_Edit=uicontrol('Style', 'edit', 'String', 'new class','Position', [10 10 300 20]); %,'BackgroundColor',[C C C]
uicontrol('Callback', @Add_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [320 5 60 30]);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Add_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);

Current_Class=length(handles.CC.Object_Handles.Class)+1;

Class_Name = get(handles.CC.Object_Handles.Classes_Add_Edit,'String');
handles.CC.Object_Handles.Class(Current_Class) =  uimenu('Parent',handles.Classes_Classes,...
    'Label',[num2str(Current_Class),'. ',Class_Name],...
    'HandleVisibility','callback', ...
    'Tag', num2str(Current_Class), ...
    'Callback', @Class_Callback);
handles.CC.Settings.Class_Names{Current_Class} = Class_Name;
handles.CC.Settings.Current_Class=Current_Class;

for i = 1:length(handles.CC.Object_Handles.Class)
    set(handles.CC.Object_Handles.Class(i), 'Checked', 'off');
end
set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'off');
set(handles.CC.Object_Handles.Class(Current_Class), 'Checked', 'on');
if handles.CC.Settings.Current_Class>0
    set(handles.Classifier_Show_Current, 'Enable', 'on', 'Checked', 'on');
end

if length(handles.CC.Settings.Class_Names)==1
    handles.CC.Settings.Current_Level=2;
else
    handles.CC.Settings.Current_Level=3;
end
handles=Set_Level(handles);

delete(handles.CC.Object_Handles.Classes_Add);
% drawing the header
set(handles.figure1,'Name', get_Title(handles));
guidata(gcf, handles);

% --------------------------------------------------------------------
function  Class_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
Selected_Class = str2double(get(hObject, 'Tag'));
for i = 1:length(handles.CC.Object_Handles.Class)
    set(handles.CC.Object_Handles.Class(i), 'Checked', 'off');
end
set(handles.Classes_Unclassify, 'Checked', 'off');
set(handles.CC.Object_Handles.Class(Selected_Class), 'Checked', 'on');
handles.CC.Settings.Current_Class = Selected_Class;
guidata(hObject, handles);

% --------------------------------------------------------------------
function Classes_Remove_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.Classes_Remove=figure;
set(handles.CC.Object_Handles.Classes_Remove,'Position',[200 200 390 40],'MenuBar','none','Name','Remove Class','NumberTitle','off');

C=0.8;
handles.CC.Object_Handles.Classes_Remove_PopUpMenu=uicontrol('Style', 'popupmenu', 'String', handles.CC.Settings.Class_Names,'Position', [10 10 300 20]); %,'BackgroundColor',[C C C]
uicontrol('Callback', @Remove_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [320 5 60 30]);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Remove_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
Removed_Class=get(handles.CC.Object_Handles.Classes_Remove_PopUpMenu,'Value');

% creating the new class list
Old_Class_Names=handles.CC.Settings.Class_Names;
handles.CC.Settings.Class_Names={};
index=0;
for Class=1:length(Old_Class_Names)
   if Class~=Removed_Class
       index=index+1;
       handles.CC.Settings.Class_Names{index}=Old_Class_Names{Class};
   end   
   % removing the menu item
   delete(handles.CC.Object_Handles.Class(Class));
end
% Removing the data that is no longer valid
for Image=1:handles.CC.Settings.Total_Images
    handles.CC.Classified_Cells{Image}=zeros(size(handles.CC.Classified_Cells{Image}));
    index=0;
    for Class=1:length(Old_Class_Names)
        if Class==Removed_Class
            handles.CC.Trained_Cells{Image}(handles.CC.Trained_Cells{Image}==Class)=0;
        else
            index=index+1;
            handles.CC.Trained_Cells{Image}(handles.CC.Trained_Cells{Image}==Class)=index;
        end
    end
end

handles.CC.Settings.Current_Class=0;

handles.CC.Settings.SVM_Model=struct();
handles.CC.Settings.Show_Classified=0;
set(handles.Classifier_Show_Current,'Checked','on');
set(handles.Classifier_Show_Classified,'Enable','off','Checked','off');
set(handles.Classifier_Classify_All,'Enable','off');

% redrawing the menu items
handles.CC.Object_Handles.Class=[];
for Current_Class=1:length(handles.CC.Settings.Class_Names)
    Class_Name = handles.CC.Settings.Class_Names{Current_Class};
    handles.CC.Object_Handles.Class(Current_Class) =  uimenu('Parent',handles.Classes_Classes,...
        'Label',[num2str(Current_Class),'. ',Class_Name],...
        'HandleVisibility','callback', ...
        'Tag', num2str(Current_Class), ...
        'Callback', @Class_Callback);
end
if length(handles.CC.Object_Handles.Class)>1
    set(handles.Classifier_Train,'Enable','on')
else
    set(handles.Classifier_Train,'Enable','off')
end
for i = 1:length(handles.CC.Object_Handles.Class)
    set(handles.CC.Object_Handles.Class(i), 'Checked', 'off');
end
if handles.CC.Settings.Current_Class==0
    set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'on');
else
    set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'off');
    set(handles.CC.Object_Handles.Class(handles.CC.Settings.Current_Class), 'Checked', 'on');
end

if isempty(handles.CC.Settings.Class_Names)
    handles.CC.Settings.Current_Level=1;
elseif length(handles.CC.Settings.Class_Names)==1
    handles.CC.Settings.Current_Level=2;
else
    handles.CC.Settings.Current_Level=3;
end
handles=Set_Level(handles);

delete(handles.CC.Object_Handles.Classes_Remove);
% drawing the header
set(handles.figure1,'Name', get_Title(handles));
guidata(gcf, handles);
Draw_Image;

% --------------------------------------------------------------------
function Classes_Rename_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.Classes_Rename=figure;
set(handles.CC.Object_Handles.Classes_Rename,'Position',[200 200 390 80],'MenuBar','none','Name','Rename Class','NumberTitle','off');

C=0.8;
handles.CC.Object_Handles.Classes_Rename_PopUpMenu=uicontrol('Style', 'popupmenu', 'String', handles.CC.Settings.Class_Names,'Position', [10 50 300 20]); %,'BackgroundColor',[C C C]
handles.CC.Object_Handles.Classes_Remove_Edit=uicontrol('Style', 'edit', 'String','new name','Position', [10 10 300 20]); %,'BackgroundColor',[C C C]

uicontrol('Callback', @Rename_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [320 20 60 40]);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Rename_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
Class=get(handles.CC.Object_Handles.Classes_Rename_PopUpMenu,'Value');
New_Name=get(handles.CC.Object_Handles.Classes_Remove_Edit,'String');

handles.CC.Settings.Class_Names{Class}=New_Name;

% removing the menu item
for Class=1:length(handles.CC.Settings.Class_Names)
    delete(handles.CC.Object_Handles.Class(Class));
end

% redrawing the menu items
handles.CC.Object_Handles.Class=[];
for Current_Class=1:length(handles.CC.Settings.Class_Names)
    Class_Name = handles.CC.Settings.Class_Names{Current_Class};
    handles.CC.Object_Handles.Class(Current_Class) =  uimenu('Parent',handles.Classes_Classes,...
        'Label',[num2str(Current_Class),'. ',Class_Name],...
        'HandleVisibility','callback', ...
        'Tag', num2str(Current_Class), ...
        'Callback', @Class_Callback);
end
for i = 1:length(handles.CC.Object_Handles.Class)
    set(handles.CC.Object_Handles.Class(i), 'Checked', 'off');
end
if handles.CC.Settings.Current_Class==0
    set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'on');
else
    set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'off');
    set(handles.CC.Object_Handles.Class(handles.CC.Settings.Current_Class), 'Checked', 'on');
end

delete(handles.CC.Object_Handles.Classes_Rename);
% drawing the header
set(handles.figure1,'Name', get_Title(handles));
guidata(gcf, handles);


% --------------------------------------------------------------------
function Classes_Merge_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.Classes_Merge=figure;
set(handles.CC.Object_Handles.Classes_Merge,'Position',[200 200 390 120],'MenuBar','none','Name','Merge two classes','NumberTitle','off');

C=0.8;
handles.CC.Object_Handles.Classes_Merge_PopUpMenu1=uicontrol('Style', 'popupmenu', 'String', handles.CC.Settings.Class_Names,'Position', [10 90 300 20]); %,'BackgroundColor',[C C C]
handles.CC.Object_Handles.Classes_Merge_PopUpMenu2=uicontrol('Style', 'popupmenu', 'String', handles.CC.Settings.Class_Names,'Position', [10 50 300 20]); %,'BackgroundColor',[C C C]
handles.CC.Object_Handles.Classes_Merge_Edit=uicontrol('Style', 'edit', 'String','new name','Position', [10 10 300 20]); %,'BackgroundColor',[C C C]

uicontrol('Callback', @Merge_OK_Callback, 'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [320 40 60 40]);
guidata(gcf, handles);

% --------------------------------------------------------------------
function Merge_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
Class1=get(handles.CC.Object_Handles.Classes_Merge_PopUpMenu1,'Value');
Class2=get(handles.CC.Object_Handles.Classes_Merge_PopUpMenu2,'Value');
New_Name=get(handles.CC.Object_Handles.Classes_Merge_Edit,'String');

% creating the new class list
Old_Class_Names=handles.CC.Settings.Class_Names;
handles.CC.Settings.Class_Names={};
index=0;
for Class=1:length(Old_Class_Names)
   if Class~=Class1 & Class~=Class2 
       index=index+1;
       handles.CC.Settings.Class_Names{index}=Old_Class_Names{Class};
   end   
   % removing the menu item
   delete(handles.CC.Object_Handles.Class(Class));
end
index=index+1;
handles.CC.Settings.Class_Names{index}=New_Name;

% Removing the data that is no longer valid
for Image=1:handles.CC.Settings.Total_Images
    handles.CC.Classified_Cells{Image}=zeros(size(handles.CC.Classified_Cells{Image}));
    index=0;
    for Class=1:length(Old_Class_Names)
        if Class==Class1 | Class==Class2
            handles.CC.Trained_Cells{Image}(handles.CC.Trained_Cells{Image}==Class)=length(handles.CC.Settings.Class_Names);
        else
            index=index+1;
            handles.CC.Trained_Cells{Image}(handles.CC.Trained_Cells{Image}==Class)=index;
        end
    end
end

handles.CC.Settings.Current_Class=0;

handles.CC.Settings.SVM_Model=struct();
handles.CC.Settings.KNN_Model=struct();
handles.CC.Settings.Mperceptron_Model=struct();
handles.CC.Settings.Show_Classified=0;
set(handles.Classifier_Show_Current,'Checked','on');
set(handles.Classifier_Show_Classified,'Enable','off','Checked','off');
set(handles.Classifier_Classify_All,'Enable','off');

% redrawing the menu items
handles.CC.Object_Handles.Class=[];
for Current_Class=1:length(handles.CC.Settings.Class_Names)
    Class_Name = handles.CC.Settings.Class_Names{Current_Class};
    handles.CC.Object_Handles.Class(Current_Class) =  uimenu('Parent',handles.Classes_Classes,...
        'Label',[num2str(Current_Class),'. ',Class_Name],...
        'HandleVisibility','callback', ...
        'Tag', num2str(Current_Class), ...
        'Callback', @Class_Callback);
end
if length(handles.CC.Object_Handles.Class)>1
    set(handles.Classifier_Train,'Enable','on')
else
    set(handles.Classifier_Train,'Enable','off')
end
for i = 1:length(handles.CC.Object_Handles.Class)
    set(handles.CC.Object_Handles.Class(i), 'Checked', 'off');
end
if handles.CC.Settings.Current_Class==0
    set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'on');
else
    set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'off');
    set(handles.CC.Object_Handles.Class(handles.CC.Settings.Current_Class), 'Checked', 'on');
end

delete(handles.CC.Object_Handles.Classes_Merge);
if isempty(handles.CC.Settings.Class_Names)
    handles.CC.Settings.Current_Level=1;
elseif length(handles.CC.Settings.Class_Names)==1
    handles.CC.Settings.Current_Level=2;
else
    handles.CC.Settings.Current_Level=3;
end
handles=Set_Level(handles);
% drawing the header
set(handles.figure1,'Name', get_Title(handles));
guidata(gcf, handles);
Draw_Image;

% --------------------------------------------------------------------
function Classes_Unclassify_Callback(hObject, eventdata, handles)
Current_Class=0;
handles.CC.Settings.Current_Class=Current_Class;

for i = 1:length(handles.CC.Object_Handles.Class)
    set(handles.CC.Object_Handles.Class(i), 'Checked', 'off');
end
set(handles.Classes_Unclassify, 'Enable', 'on', 'Checked', 'on');

guidata(hObject,handles);

% --------------------------------------------------------------------
function Image_ButtonDownFcn(hObject, eventdata, handles)
handles = guidata(gcf);
Point=get(get(hObject, 'Parent'),'CurrentPoint');
Point2D=Point(1,1:2)';

In_Panel=strcmp(handles.CC.Settings.Current_Image,'Panel');

if In_Panel
    Objects_Positions=handles.CC.Panel_Data.Location';
else
    Objects_Positions(1,:)=handles.CC.Measurements.(handles.CC.Settings.Object_Name).Location_Center_X{handles.CC.Settings.Current_Image};
    Objects_Positions(2,:)=handles.CC.Measurements.(handles.CC.Settings.Object_Name).Location_Center_Y{handles.CC.Settings.Current_Image};
end

[Distance,Closest_Object]=min(sum((repmat(Point2D,[1 size(Objects_Positions,2)])-Objects_Positions).^2));

if In_Panel
    handles.CC.Trained_Cells{handles.CC.Panel_Data.Original_Image_Index(Closest_Object)}(handles.CC.Panel_Data.Original_Nucleus_Index(Closest_Object))=handles.CC.Settings.Current_Class;
else
    handles.CC.Trained_Cells{handles.CC.Settings.Current_Image}(Closest_Object)=handles.CC.Settings.Current_Class;
end
    
% REDRAWING THE NUMBER
try
    delete(handles.CC.Object_Handles.Class_Numbers(Closest_Object));
end
if handles.CC.Settings.Current_Class>0
    handles.CC.Object_Handles.Class_Numbers(Closest_Object) = text(Objects_Positions(1,Closest_Object)+3, Objects_Positions(2,Closest_Object)+1, num2str(handles.CC.Settings.Current_Class));
    set(handles.CC.Object_Handles.Class_Numbers(Closest_Object),'Color',[1 1 1],'HitTest','off');
end

guidata(gcf, handles);


% --------------------------------------------------------------------
function Classifier_Measurement_Setup_Callback(hObject, eventdata, handles)
Object_Names=fieldnames(handles.CC.Measurements);
Channel_Names=handles.CC.Settings.Channel_Names;
Known_Object_Names={'AreaShape','Texture','Intensity','RadialIntensityDist'};
Known_Object_Names=[Known_Object_Names,strcat('Mean',Known_Object_Names)];
Objects=length(Object_Names);
Channels=length(Channel_Names);
Known_Objects=length(Known_Object_Names);

% parsing the measurement names into groups
for Object=1:Objects
    Measurement_Names{Object}=fieldnames(handles.CC.Measurements.(Object_Names{Object}));
    Measurements=length(Measurement_Names{Object});

    Group_Information{Object}=zeros(Measurements,2);
    for Measurement=1:Measurements
        Measurement_Name=Measurement_Names{Object}{Measurement};
        for Known_Object=1:Known_Objects
            %             if not(isempty(strfind(Measurement_Name,Known_Object_Names{Known_Object})))
            if regexp(Measurement_Name,['^',Known_Object_Names{Known_Object},'.*'])
                Group_Information{Object}(Measurement,1)=Known_Object;
            end
        end
        for Channel=1:Channels
            if not(isempty(strfind(Measurement_Name,Channel_Names{Channel})))
                Group_Information{Object}(Measurement,2)=Channel;
            end
        end
    end

    Combinations=unique(Group_Information{Object},'rows');
    for Combination=1:size(Combinations,1)
        if Combinations(Combination,1)==0
            start='Other';
        else
            start=Known_Object_Names{Combinations(Combination,1)};
        end
        if Combinations(Combination,2)==0
            ending='';
        else
            ending=[' ',Channel_Names{Combinations(Combination,2)}];
        end
        Group_Names{Object}{Combination}=[start,ending];
          
        Singles_Indices=find(Group_Information{Object}(:,1)==Combinations(Combination,1) & Group_Information{Object}(:,2)==Combinations(Combination,2));  
        Single_Names{Object}{Combination}=Measurement_Names{Object}(Singles_Indices);
        Single_Indices{Object}{Combination}=Singles_Indices;
    end
    
   
    try
        handles.CC.Settings.Items0{Object};
    catch
        handles.CC.Settings.Items0{Object}=zeros(1,Measurements); %saves which measurements are finally used
    end
end

handles.CC.Settings.Group_Information=Group_Information;
handles.CC.Settings.Measurement_Names=Measurement_Names;
handles.CC.Settings.Group_Names=Group_Names;
handles.CC.Settings.Single_Names=Single_Names;
handles.CC.Settings.Single_Indices=Single_Indices;

handles.CC.Object_Handles.Measurement_Setup_Handle=figure;
set(handles.CC.Object_Handles.Measurement_Setup_Handle,'Position',[100 100 790 420],'MenuBar','none','Name','Measurement Setup','NumberTitle','off');

C=0.8;
Width=250;
Gap=10;

uicontrol('Style', 'text', 'String', 'Object','BackgroundColor',[C C C],'Position', [10 390 Width 20]);
handles.CC.Object_Handles.Measurement_Setup1=uicontrol('Tag','1','Style', 'listbox','Callback', @Measurement_Setup_Generic, 'String', Object_Names,'BackgroundColor',[C C C],'Position', [10 50 Width 340]);

uicontrol('Style', 'text', 'String', 'Measurement group','BackgroundColor',[C C C],'Position', [10+Gap+Width 390 Width 20]);
handles.CC.Object_Handles.Measurement_Setup2=uicontrol('Tag','2','Style', 'listbox','Callback', @Measurement_Setup_Generic, 'String', Group_Names{1},'BackgroundColor',[C C C],'Position', [10+Gap+Width 50 Width 340]);

uicontrol('Style', 'text', 'String', 'Single measurement','BackgroundColor',[C C C],'Position', [10+2*(Gap+Width) 390 Width 20]);
handles.CC.Object_Handles.Measurement_Setup3=uicontrol('Min',1,'Max',1000,'Tag','3','Style', 'listbox','Callback', @Measurement_Setup_Generic, 'String', Single_Names{1}{1},'BackgroundColor',[C C C],'Position', [10+2*(Gap+Width) 50 Width 340],'Value',find(handles.CC.Settings.Items0{1}(handles.CC.Settings.Single_Indices{1}{1})));

uicontrol('Callback', @Measurement_Setup_OK_Callback,'Style', 'pushbutton', 'String', 'OK','BackgroundColor',[C C C],'Position', [10+1.3*(Gap+Width) 10 80 30]);

handles.CC.Settings.Measurement_Setup_View{1}=1;
handles.CC.Settings.Measurement_Setup_View{2}=1;
handles.CC.Settings.Measurement_Setup_View{3}=1;

guidata(gcf, handles);

% --------------------------------------------------------------------
function Measurement_Setup_Generic(hObject, eventdata, handles)
handles = guidata(gcf);

List=str2double(get(hObject,'Tag'));
Item=get(hObject,'Value');

if List==1
    handles.CC.Settings.Measurement_Setup_View{1}=Item;
    handles.CC.Settings.Measurement_Setup_View{2}=1;
    handles.CC.Settings.Measurement_Setup_View{3}=1;

    Object=handles.CC.Settings.Measurement_Setup_View{1};
    Group=handles.CC.Settings.Measurement_Setup_View{2};
    Measurement=handles.CC.Settings.Measurement_Setup_View{3};

    set(handles.CC.Object_Handles.Measurement_Setup2,'String',handles.CC.Settings.Group_Names{Item},'Value',1);
    set(handles.CC.Object_Handles.Measurement_Setup3,'String',handles.CC.Settings.Single_Names{Item}{1},'Value',find(handles.CC.Settings.Items0{Object}(handles.CC.Settings.Single_Indices{Object}{Group})));
 
elseif List==2
    handles.CC.Settings.Measurement_Setup_View{2}=Item;
    handles.CC.Settings.Measurement_Setup_View{3}=1;

    Object=handles.CC.Settings.Measurement_Setup_View{1};
    Group=handles.CC.Settings.Measurement_Setup_View{2};
    Measurement=handles.CC.Settings.Measurement_Setup_View{3};

    set(handles.CC.Object_Handles.Measurement_Setup3,'String',handles.CC.Settings.Single_Names{handles.CC.Settings.Measurement_Setup_View{1}}{Item},'Value',find(handles.CC.Settings.Items0{Object}(handles.CC.Settings.Single_Indices{Object}{Group})));

elseif List==3
    handles.CC.Settings.Measurement_Setup_View{3}=Item;
    
    Object=handles.CC.Settings.Measurement_Setup_View{1};
    Group=handles.CC.Settings.Measurement_Setup_View{2};
    Measurement=handles.CC.Settings.Measurement_Setup_View{3};
    
    Single_Index=handles.CC.Settings.Single_Indices{Object}{Group}(Measurement);
    handles.CC.Settings.Items0{Object}(Single_Index)=1-handles.CC.Settings.Items0{Object}(Single_Index); %saving the selection

    set(handles.CC.Object_Handles.Measurement_Setup3,'Value',find(handles.CC.Settings.Items0{Object}(handles.CC.Settings.Single_Indices{Object}{Group})));
end

guidata(gcf, handles);
% --------------------------------------------------------------------
function Measurement_Setup_OK_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
Object_Names=fieldnames(handles.CC.Measurements);
handles.CC.Settings.Items={};
Item_index=0;
for Object=1:length(handles.CC.Settings.Items0)
    Item_Names=handles.CC.Settings.Measurement_Names{Object};
    for Item=1:length(handles.CC.Settings.Items0{Object})
        Value=handles.CC.Settings.Items0{Object}(Item);
        if Value==1
            Item_index=Item_index+1;
            handles.CC.Settings.Items{Item_index,1}=Object_Names{Object};
            handles.CC.Settings.Items{Item_index,2}=Item_Names{Item};
        end
    end
end

delete(handles.CC.Object_Handles.Measurement_Setup_Handle);

if handles.CC.Settings.Current_Level>3
    handles.CC.Settings.Current_Level=3;
    handles=Set_Level(handles);
end
guidata(gcf, handles);

% --------------------------------------------------------------------
function MouseWheel_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
Change=eventdata.VerticalScrollCount;

Current_Class=handles.CC.Settings.Current_Class;
New_Class=mod(Current_Class+Change,length(handles.CC.Settings.Class_Names)+1);

set(handles.Classes_Unclassify, 'Checked', 'off');
for i = 1:length(handles.CC.Object_Handles.Class)
    set(handles.CC.Object_Handles.Class(i), 'Checked', 'off');
end

if New_Class~=0
    set(handles.CC.Object_Handles.Class(New_Class), 'Checked', 'on');
else
    set(handles.Classes_Unclassify,'Checked', 'on');
end
handles.CC.Settings.Current_Class = New_Class;

% drawing the header
set(handles.figure1,'Name', get_Title(handles));
guidata(hObject, handles);


% --------------------------------------------------------------------
function File_About_Callback(hObject, eventdata, handles)
handles.CC.Object_Handles.File_About=figure;
set(handles.CC.Object_Handles.File_About,'Position',[200 200 200 200],'MenuBar','none','Name','About','NumberTitle','off');
C=0.8;
step=15;
pos=160;
pos=pos-step;
uicontrol('Style', 'text', 'String', 'CellClassifier','BackgroundColor',[C C C],'Position', [0 pos 200 2*step],'FontSize',15);
pos=pos-2*step;
%uicontrol('Style', 'text', 'String', 'Copyright:','BackgroundColor',[C C C],'Position', [0 pos 200 step]);
%pos=pos-step;
uicontrol('Style', 'text', 'String', 'Pauli Rämö','BackgroundColor',[C C C],'Position', [0 pos 200 step]);
pos=pos-step;
uicontrol('Style', 'text', 'String', 'Raphael Sacher','BackgroundColor',[C C C],'Position', [0 pos 200 step]);
pos=pos-step;
uicontrol('Style', 'text', 'String', 'Berend Snijder','BackgroundColor',[C C C],'Position', [0 pos 200 step]);
pos=pos-step;
uicontrol('Style', 'text', 'String', 'Boris Begemann','BackgroundColor',[C C C],'Position', [0 pos 200 step]);
pos=pos-step;
uicontrol('Style', 'text', 'String', 'Lucas Pelkmans','BackgroundColor',[C C C],'Position', [0 pos 200 step]);
pos=pos-2*step;
uicontrol('Style', 'text', 'String', 'www.cellclassifier.ethz.ch','BackgroundColor',[C C C],'Position', [0 pos 200 step]);

% --------------------------------------------------------------------
function handles=Set_Level(handles)

set(handles.Classes_Unclassify,'Enable','off');
set(handles.Classes_Merge,'Enable','off');
set(handles.Classes_Rename,'Enable','off');
set(handles.Classes_Remove,'Enable','off');
set(handles.Classes_Add,'Enable','off');
set(handles.Classifier_Measurement_Setup,'Enable','off');
set(handles.Classifier_Show_SVM,'Enable','off');
set(handles.Classifier_Classify_All,'Enable','off');
set(handles.Classifier_Train,'Enable','off');
set(handles.Classifier_Show_Classified,'Enable','off');
set(handles.Classifier_Show_Current,'Enable','off');
set(handles.View_Go_to_Panel,'Enable','off');
set(handles.View_Go_to_Image,'Enable','off');
set(handles.View_Previous_Image,'Enable','off');
set(handles.View_Next_Image,'Enable','off');
set(handles.View_Rescale_Colors,'Enable','off');
set(handles.File_Exit,'Enable','off');
set(handles.File_About,'Enable','off');
set(handles.File_Parse_Images,'Enable','off');
set(handles.File_Settings,'Enable','off');
set(handles.File_Export_Image,'Enable','off');
set(handles.File_Export_Data,'Enable','off');
set(handles.File_Save,'Enable','off');
set(handles.File_Load,'Enable','off');
set(handles.File_New,'Enable','off');


level=handles.CC.Settings.Current_Level;
if level>=0
    set(handles.File_Exit,'Enable','on');
    set(handles.File_About,'Enable','on');
    set(handles.File_Load,'Enable','on');
    set(handles.File_New,'Enable','on');
end
if level>=1
    set(handles.File_Parse_Images,'Enable','on');
    set(handles.File_Settings,'Enable','on');
    set(handles.File_Export_Image,'Enable','on');
    set(handles.File_Save,'Enable','on');
    set(handles.View_Go_to_Image,'Enable','on');
    set(handles.View_Previous_Image,'Enable','on');
    set(handles.View_Next_Image,'Enable','on');
    set(handles.View_Rescale_Colors,'Enable','on');
    set(handles.Classifier_Measurement_Setup,'Enable','on');
    set(handles.Classes_Add,'Enable','on');
end
if level>=2
    set(handles.Classes_Unclassify,'Enable','on');
    set(handles.Classifier_Show_Current,'Enable','on');
    set(handles.Classes_Rename,'Enable','on');
    set(handles.Classes_Remove,'Enable','on');
end
if level>=3
    set(handles.Classes_Merge,'Enable','on');
    set(handles.Classifier_Normalize,'Enable','on');
end
if level>=4
    set(handles.Classifier_Train,'Enable','on');
end
if level>=5
    
end
if level>=6  
    set(handles.Classifier_Classify_All,'Enable','on');
    set(handles.Classifier_Show_SVM,'Enable','on');
end
if level>=7
    set(handles.Classifier_Show_Classified,'Enable','on');
    set(handles.File_Export_Data,'Enable','on');
    set(handles.View_Go_to_Panel,'Enable','on');
end

if handles.CC.Settings.Show_Classified==1 && level>=7
else
    handles.CC.Settings.Show_Classified=0;
    set(handles.Classifier_Show_Classified,'Checked','off')
    set(handles.Classifier_Show_Current,'Checked','on')
end


            



% --------------------------------------------------------------------
function [z,mu,sigma] = nanzscore(x,flag,dim)
%  NANZSCORE, hacked by berend, is zscore made nan-resistant by default :D
%  see help zscore for more information

% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

if nargin < 2
    flag = 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
mu = nanmean(x,dim);
sigma = nanstd(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = bsxfun(@minus,x, mu);
z = bsxfun(@rdivide, z, sigma0);