function [SeriesData, SeriesInfo, ErrorCode] = DicomSeriesRead(PatientPath, ScanType)
% ���ܣ�
%     ����ScanName��ȡ�������е�����
% 
% ���룺
%     PatientPath           ����·��
%     ScanType              ɨ������·��
% �����
%     SeriesData            ��ȡ��������
%     SeriesInfo            ������Ϣ
%     ErrorCode             ������
% ע��
%     Ҫ���ļ��б����ϸ���࣬��dicom��������������
% ***********************************************************************************
    ScanPath = fullfile(PatientPath, ScanType);
    ScanDir = dir(ScanPath);
    ErrorCode = [];
    if ~exist(ScanPath)
        SeriesData = [];SeriesInfo = [];ErrorCode = -100;
        return;
    end
    InstanceNumberArray = [];AcquisitionNumberArray = [];SliceLocationArray = [];AcquisitionTimeArray = [];
    
    for iScanDir = 1:length(ScanDir)
        ScanDirIsdir(iScanDir) = ScanDir(iScanDir).isdir;
    end
    % ���ͼ�������������ļ����е�
    if all(ScanDirIsdir == 1)
        for iScanDir = 1:length(ScanDir)
            if isequal( ScanDir(iScanDir).name, '.' )||isequal( ScanDir(iScanDir).name, '..') continue; end
            ImagePath = fullfile(ScanPath, ScanDir(iScanDir).name);
            ImageDir = dir(fullfile(ImagePath));
            for iImage = 1:length(ImageDir)
                if isequal( ImageDir(iImage).name, '.' )||isequal( ImageDir(iImage).name, '..') continue; end
                DicomPath = fullfile(ImagePath, ImageDir(iImage).name);
                TempInfo = dicominfo(DicomPath);
                TempImage = dicomread(DicomPath);
                TempDicom(iScanDir - 2, iImage - 2).Image = TempImage;
                if isfield(TempInfo, 'InstanceNumber')
                    TempDicom(iScanDir - 2, iImage - 2).InstanceNumber = TempInfo.InstanceNumber;
                    InstanceNumberArray = [InstanceNumberArray; TempInfo.InstanceNumber];
                end
                if isfield(TempInfo, 'AcquisitionNumber')
                    TempDicom(iScanDir - 2, iImage - 2).AcquisitionNumber = TempInfo.AcquisitionNumber;
                    AcquisitionNumberArray = [AcquisitionNumberArray; TempInfo.AcquisitionNumber];
                end
                if isfield(TempInfo, 'SliceLocation')
                    TempDicom(iScanDir - 2, iImage - 2).SliceLocation = TempInfo.SliceLocation;
                    SliceLocationArray = [SliceLocationArray; TempInfo.SliceLocation];
                end
                if isfield(TempInfo, 'AcquisitionTime')
                    AcquisitionTimeArray = [AcquisitionTimeArray; str2num(TempInfo.AcquisitionTime)];
                end
            end
        end
    else
    % ���ͼ�����о��ڱ��ļ�����
        ImageDir = dir(fullfile(ScanPath));
        for iImage = 1:length(ImageDir)
            if isequal( ImageDir(iImage).name, '.' )||isequal( ImageDir(iImage).name, '..') continue; end
            DicomPath = fullfile(ScanPath, ImageDir(iImage).name);
            TempInfo = dicominfo(DicomPath);
            TempImage = dicomread(DicomPath);
            TempDicom(iImage - 2).Image = TempImage;
            if isfield(TempInfo, 'InstanceNumber')
                TempDicom(iImage - 2).InstanceNumber = TempInfo.InstanceNumber;
                InstanceNumberArray = [InstanceNumberArray; TempInfo.InstanceNumber];
            end
            if isfield(TempInfo, 'AcquisitionNumber')
                TempDicom(iImage - 2).AcquisitionNumber = TempInfo.AcquisitionNumber;
                AcquisitionNumberArray = [AcquisitionNumberArray; TempInfo.AcquisitionNumber];
            end
            if isfield(TempInfo, 'SliceLocation')
                TempDicom(iImage - 2).SliceLocation = TempInfo.SliceLocation;
                SliceLocationArray = [SliceLocationArray; TempInfo.SliceLocation];
            end
            if isfield(TempInfo, 'AcquisitionTime')
                AcquisitionTimeArray = [AcquisitionTimeArray; str2num(TempInfo.AcquisitionTime)];
            end
        end
    end
	InstanceNumberArray = unique(InstanceNumberArray);
    UniqueSliceLocationArray = unique(SliceLocationArray);
    AcquisitionNumberArray = unique(AcquisitionNumberArray);
    AcquisitionTimeArray = unique(AcquisitionTimeArray);
    if size(TempDicom, 1) == 1
        if size(InstanceNumberArray, 1) ~= size(UniqueSliceLocationArray, 1)    
        % InstanceNumber��location number���ȣ����������ֻ��Ҫ��InstaceNumber��������
            for iImage = 1: size(TempDicom, 2)
                TempImage = TempDicom(iImage).Image;
                TempInstanceNumber = TempDicom(iImage).InstanceNumber;
                TempAcquisitionNumber = TempDicom(iImage).AcquisitionNumber;
                SeriesData(:, :, TempInstanceNumber - InstanceNumberArray(1) + 1) = TempImage;
                SeriesLocation(:, TempInstanceNumber - InstanceNumberArray(1) + 1) = TempDicom(iImage).SliceLocation;
            end
        else
        % InstanceNumber��location number��ȣ����������ͬʱ��Ҫ��AcqusitionNumber��InstaceNumber��������
            for iImage = 1: size(TempDicom, 2)
                TempImage = TempDicom(iImage).Image;
                TempInstanceNumber = TempDicom(iImage).InstanceNumber;
                TempAcquisitionNumber = TempDicom(iImage).AcquisitionNumber;
                SeriesData(:, :, (TempAcquisitionNumber - AcquisitionNumberArray(1)) * size(UniqueSliceLocationArray, 1) + TempInstanceNumber - InstanceNumberArray(1) + 1) = TempImage;
                SeriesLocation(:, (TempAcquisitionNumber - AcquisitionNumberArray(1)) * size(UniqueSliceLocationArray, 1) + TempInstanceNumber - InstanceNumberArray(1) + 1) = TempDicom(iImage).SliceLocation;
            end
        end 
    else
        if size(InstanceNumberArray,1) ~= size(UniqueSliceLocationArray, 1)
            for iScanDir = 1:size(TempDicom, 1)
                for iImage = 1:size(TempDicom, 2)
                    TempImage = TempDicom(iScanDir, iImage).Image;
                    TempInstanceNumber = TempDicom(iScanDir, iImage).InstanceNumber;
                    TempAcquisitionNumber = TempDicom(iScanDir, iImage).AcquisitionNumber;
                    SeriesData(:, :, TempInstanceNumber - InstanceNumberArray(1) + 1) = TempImage;
                    SeriesLocation(:, TempInstanceNumber - InstanceNumberArray(1) + 1) = TempDicom(iImage).SliceLocation;
                end
            end
        else
            for iScanDir = 1:size(TempDicom, 2)
                for iImage = 1:size(TempDicom, 2)
                    TempImage = TempDicom(iScanDir, iImage).Image;
                    TempInstanceNumber = TempDicom(iScanDir, iImage).InstanceNumber;
                    TempAcquisitionNumber = TempDicom(iScanDir, iImage).AcquisitionNumber;
                    SeriesData(:, :, (TempAcquisitionNumber - AcquisitionNumberArray(1)) * size(UniqueSliceLocationArray, 1) + TempInstanceNumber - InstanceNumberArray(1) + 1) = TempImage;
                    SeriesLocation(:, (TempAcquisitionNumber - AcquisitionNumberArray(1)) * size(UniqueSliceLocationArray, 1) + TempInstanceNumber - InstanceNumberArray(1) + 1) = TempDicom(iImage).SliceLocation;
                end
            end
        end
    end
    SeriesInfo.SliceNum = size(UniqueSliceLocationArray, 1);
    SeriesInfo.FrameNum = size(TempDicom, 1) * size(TempDicom, 2)/SeriesInfo.SliceNum;
    SeriesInfo.FrameNum = double(SeriesInfo.FrameNum); SeriesInfo.SliceNum = double(SeriesInfo.SliceNum);

%     TimeBetweenScan = CalcTimeDifference(min(AcquisitionTimeArray), max(AcquisitionTimeArray));
%     SeriesInfo.TimeLag = TimeBetweenScan / SeriesInfo.FrameNum;
%     if SeriesInfo.TimeLag == 0
%         SeriesInfo.TimeLag = 2;
%     end
    SeriesInfo.ImageSize = min(TempInfo.Width, TempInfo.Height);
    SeriesInfo.Width = TempInfo.Width;
    SeriesInfo.Height = TempInfo.Height;
    SeriesInfo.PixelSpacing = TempInfo.PixelSpacing;
    SeriesInfo.SpacingBetweenSlices = TempInfo.SliceThickness;
%     SeriesInfo.SpacingBetweenSlices = TempInfo.SpacingBetweenSlices;
    if isfield(TempInfo, 'SliceThickness')
        SeriesInfo.SliceThickness = TempInfo.SliceThickness;
    end
    if isfield(TempInfo, 'SpacingBetweenSlices')
        SeriesInfo.SpacingBetweenSlices = TempInfo.SpacingBetweenSlices;
    end
    if isfield(TempInfo, 'RescaleSlope') && isfield(TempInfo, 'RescaleIntercept')
        SeriesData = double(SeriesData * TempInfo.RescaleSlope) + double(TempInfo.RescaleIntercept);
    else
        SeriesData = double(SeriesData);
    end
%%%%%%
SeriesData = datatrans (SeriesData);%����ӵĴ��룻Ϊ�˱���ά�ȸ��Ҷȷ�Χ��ʽһ����
% SeriesData = permute(SeriesData,[2,1,3]);
%%%%%
    % ��ÿһ��Frame����Slice Location��С�����������Ҳ���������ϵĴ�ͷ���·����Ϸ�����
%     SortVolume = [];
%     for iFrame = 1: SeriesInfo.FrameNum
%         TempVolume = SeriesData(:, :, (iFrame - 1) * SeriesInfo.SliceNum +1 : iFrame * SeriesInfo.SliceNum);
%         TempLocationArray = SliceLocationArray((iFrame - 1) * SeriesInfo.SliceNum +1 : iFrame * SeriesInfo.SliceNum);
%         [Value, Location] = sort(TempLocationArray);
%         TempSortVolume = TempVolume(:, :, Location);
%         SortVolume = cat(3, SortVolume, TempSortVolume);
%     end
%     SeriesData = SortVolume;
    SortVolume = [];
    for iFrame = 1: SeriesInfo.FrameNum
        TempVolume = SeriesData(:, :, (iFrame - 1) * SeriesInfo.SliceNum +1 : iFrame * SeriesInfo.SliceNum);
        TempLocation = SeriesLocation(:, (iFrame - 1) * SeriesInfo.SliceNum +1 : iFrame * SeriesInfo.SliceNum);
        [Value, Location] = sort(TempLocation);
        TempSortVolume = TempVolume(:, :, Location);
        SortVolume = cat(3, SortVolume, TempSortVolume);
    end                                                                                                                                                                                                                     
    SeriesData = SortVolume;
end
%`````````````````````````ͼ������ת��`````````````````````````````````````%
%-���ܣ�Ϊ�˱���NII���ݸ�ʽ��ͳһ�ԣ�
%ת���Ҷȷ�Χ����ԭʼ�Ҷȸ�ʽ��һ����[0,1]��Χ�ڣ�
%ת��ά�ȣ��Ծ������ת�ã������ѵ������һ����ά�ȸ�ʽ������ȫ��Ϊ����Լ�֮ǰ�ڵĿӣ�
function imgout = datatrans (imgin)
Isize=size(imgin);
imgout=zeros(Isize);
desiredMin = 0;
desiredMax = 1;
for i=1:Isize(3)
    originalMinValue = double(min(min(imgin(:,:,i))));
    originalMaxValue = double(max(max(imgin(:,:,i))));
    originalRange = originalMaxValue - originalMinValue;
    desiredRange = desiredMax - desiredMin;
    imgout(:,:,i) = desiredRange * (double(imgin(:,:,i)) - originalMinValue) / originalRange + desiredMin;
end
end