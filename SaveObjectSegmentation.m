function handles = SaveObjectSegmentation(handles)


% Help for the Save Object Segmentation module:
% Category: Other
%
% SHORT DESCRIPTION:
% Allows you to specify which object segmentation will be stored in
% compressed PNG images, and at which location
% *************************************************************************
%
% Settings:
%
% Which object segmentation do you want to store?
% Select the object name of the object which segmentation you would like to
% store, for later use in the CellClassifier software. Note that the stored
% images are grayscale compressed PNG images, with the grayscale collor
% corrresponding to the object-index/identifier in CellProfiler.
%
% For more detailed information on CellClassifier and the
% SaveObjectSegmentation module, see: 
% 
%   http://www.cellclassifier.ethz.ch/
%
% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Please see the AUTHORS file for credits.
%
% Website: http://www.cellprofiler.org
%
% $Revision: 5701 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the primary objects you want to create
%secondary objects around?
%infotypeVAR01 = objectgroup
ObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%pathnametextVAR02 = Enter the path name to the folder where the images to be loaded are located. Type period (.) for default output directory.
%defaultVAR02 = .
Pathname = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%%%VariableRevisionNumber = 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Get the pathname and check that it exists
if strncmp(Pathname,'.',1)
    if length(Pathname) == 1
        Pathname = handles.Current.DefaultOutputDirectory;
    else
        % If the pathname start with '.', interpret it relative to
        % the default image dir.
        Pathname = fullfile(handles.Current.DefaultOutputDirectory,Pathname(2:end));
    end
end
if ~exist(Pathname,'dir')
    error(['Image processing was canceled in the ', ModuleName, ' module because the directory "',Pathname,'" does not exist. Be sure that no spaces or unusual characters exist in your typed entry and that the pathname of the directory begins with /.'])
end

% Determines which cycle is being analyzed.
SetBeingAnalyzed = handles.Current.SetBeingAnalyzed;

%%% Get the Segmentation fieldname of the chosen ObjectName
strSegmentationFieldname = ['Segmented',ObjectName];

% Create new image name, keeping in mind compatibility with both old and
% new CellProfilermeasurement storing schemas.  
if isfield(handles.Measurements.Image, 'FileNames')
    strOrigImageName = char(handles.Measurements.Image.FileNames{handles.Current.SetBeingAnalyzed}{SetBeingAnalyzed,1});
else
    cellstrImageFieldNames = fieldnames(handles.Measurements.Image);
    strImageFieldName = cellstrImageFieldNames{find(strncmp(cellstrImageFieldNames,'FileName_',9),1,'first')};
    strOrigImageName = char(handles.Measurements.Image.(strImageFieldName){handles.Current.SetBeingAnalyzed});
end

% new CP apparently removes file extensions from image names, therefore
% remove extension ourselves if CP did not do it already.
matDotIndices=strfind(strOrigImageName,'.');
if ~isempty(matDotIndices)
    strOrigImageName = strOrigImageName(1,1:matDotIndices(end)-1);
end


strTmpFileName = [strOrigImageName,'_',strSegmentationFieldname,'.png'];

% if analyzing subdirectories, do not take along the subdirectory
% structure... but replaces file separators with underscores to
% preserver the additional information of the path.
if ~isempty(strfind(strOrigImageName,filesep))
    strTmpFileName = strrep(strTmpFileName,filesep,'_');
end

% Get the final full pathname
strFullFileName = fullfile(Pathname, strTmpFileName);

% Get the object segmentation image, grayscale.
LabelMatrixImage = CPretrieveimage(handles,strSegmentationFieldname,ModuleName,'MustBeGray','DontCheckScale');

% Store the segmentation in a 16bit compressed PNG image.
imwrite(uint16(LabelMatrixImage),strFullFileName,'png');

% Store the segmentation image name and path in the CellProfiler
% measurements, such that CellClassifier can retreive the correct
% segmentation images.
strFeatureName = CPjoinstrings('SegmentationPath',ObjectName);
handles = CPaddmeasurements(handles, 'Image', strFeatureName, strFullFileName, SetBeingAnalyzed);
% handles = CPaddmeasurements(handles, ObjectName, FeatureName, Data, ImageSetNumber)

