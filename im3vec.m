function IMVECTOR = im3vec (ROIdata)
% ���ܣ��Ժ�ѡ�������������ȡ
%      ���룺ROIdata����ά��ѡ���������Ԫ��
%      �����IMVECTOR��26ά��������
%
%
%% -0 ������
[Row,Col,Pils]=size(ROIdata);
row=round(2.5*Row);col=round(2.5*Col);pils=round(2.5*Pils);
subvolume= imresize3(ROIdata,[row,col,pils],'linear');
%% -1.�������������㷨���Mask 
Mask = zeros(size(subvolume)); % �������ķ���ֵ����¼�����������õ�������
Isizes = size(subvolume);
x=round(Isizes(1)/2);
y=round(Isizes(2)/2); 
z=round(Isizes(3)/2);%ѡȡ�������ĵ�����Ϊ��ʼ����
reg_mean = subvolume(round(Isizes(1)/2),round(Isizes(2)/2),round(Isizes(3)/2));%��ʾ�ָ�õ������ڵ�ƽ��ֵ����ʼ��Ϊ���ӵ�ĻҶ�ֵ
reg_size = 1;%�ָ�ĵ������򣬳�ʼ��ֻ�����ӵ�һ��
neg_free = 2000; %��̬�����ڴ��ʱ��ÿ������������ռ��С
neg_list = zeros(neg_free,4);
%���������б�����Ԥ�ȷ������ڴ�������������ص������ֵ�ͻҶ�ֵ�Ŀռ䣬����
%���ͼ��Ƚϴ���Ҫ���neg_free��ʵ��matlab�ڴ�Ķ�̬����
neg_pos = 0;%���ڼ�¼neg_list�еĴ����������ص�ĸ���
pixdist = 0;
%��¼�������ص����ӵ��ָ������ľ�����
%��һ�δ������������ռ��������ص�͵�ǰ���ӵ�ľ���
%�����ǰ����Ϊ��x,y,z����ôͨ��neigb���ǿ��Եõ��������������ص�λ��
neigb = [-1  0  0; 
          1  0  0;
          0 -1  0;
          0  1  0;
          0  0  1; 
          0  0 -1];
 %��ʼ�������������������д��������������ص���Ѿ��ָ�õ��������ص�ĻҶ�ֵ����
 %����reg_maxdis,������������
while (pixdist < 0.055 && reg_size < numel(subvolume))
     %�����µ��������ص�neg_list��
     for j=1:6
         xn = x + neigb(j,1);
         yn = y + neigb(j,2);
         zn = z + neigb(j,3);
         %������������Ƿ񳬹���ͼ��ı߽�
         ins = (xn>=1)&&(yn>=1)&&(zn>=1)&&(xn<=Isizes(1))&&(yn<=Isizes(2))&&(zn<=Isizes(3));
         %�������������ͼ���ڲ���������δ�ָ�ã���ô������ӵ������б���
         if( ins && Mask(xn,yn,zn)==0)
             neg_pos = neg_pos+1;
             neg_list(neg_pos,:) =[ xn, yn, zn,subvolume(xn,yn,zn)];%�洢��Ӧ��ĻҶ�ֵ
             Mask(xn,yn,zn) = 1;%��ע���������ص��Ѿ������ʹ�,������ζ�ţ����ڷָ�������
         end
     end 
    %�����д����������ص���ѡ��һ�����ص㣬�õ�ĻҶ�ֵ���Ѿ��ָ������ҶȾ�ֵ��
    %��ľ���ֵʱ����������������С��
    dist = abs(neg_list(1:neg_pos,4)-reg_mean);
    [pixdist,index] = min(dist);
    %����������µľ�ֵ
    reg_mean = (reg_mean * reg_size +neg_list(index,4))/(reg_size + 1);
    reg_size = reg_size + 1;
    %���ɵ����ӵ���Ϊ�Ѿ��ָ�õ��������ص�
    Mask(x,y,z)=2;%��־�����ص��Ѿ��Ƿָ�õ����ص�
    x = neg_list(index,1);
    y = neg_list(index,2);
    z = neg_list(index,3);
    %���µ����ӵ�Ӵ����������������б����Ƴ�
    neg_list(index,:) = neg_list(neg_pos,:);
    neg_pos = neg_pos -1;
end
Mask = (Mask==2);%����֮ǰ���ָ�õ����ص���Ϊ20
[m,n,p]=size(Mask);superficial=zeros(m,n,p);%������ͼ��
for i=1:p
    se = strel('disk',5);            Mask(:,:,i) = imdilate( Mask(:,:,i),se);
    Mask(:,:,i)=bwperim(Mask(:,:,i));Mask(:,:,i)=imfill(Mask(:,:,i),'holes');
    Mask(:,:,i)=imerode(Mask(:,:,i),se);superficial(:,:,i)=bwperim(Mask(:,:,i));
end
%% -2.spatial feature
Var_z = varVector(Mask);
Mask_x = permute(Mask,[2,3,1]);Var_x = varVector(Mask_x);
Mask_y = permute(Mask,[1,3,2]);Var_y = varVector(Mask_y);
Var = [Var_z Var_x Var_y];%VAR=sum(Var);varvector=Var ./VAR;
%% -3.Sphericity value
superficial_area=size(find(superficial==1));volume_value=size(find(Mask==1));
Sphericity=6*sqrt(pi)*volume_value(1,1)/((superficial_area(1,1))^1.5);%����Ŀ����������ζ�ֵ
[circularity_z,pixel_ratio_z] = circul(Mask);% ��Բ���뱳�����رȵļ���
Mask_x = permute(Mask,[2,3,1]);[circularity_x,pixel_ratio_x] = circul(Mask_x);
Mask_y = permute(Mask,[1,3,2]);[circularity_y,pixel_ratio_y] = circul(Mask_y);
circularity = [circularity_z circularity_x circularity_y];
bp_ratio=[pixel_ratio_z,pixel_ratio_x,pixel_ratio_y];
IMVECTOR=[Var Sphericity circularity bp_ratio];
IMVECTOR=IMVECTOR';
%% 
%```````````````````````````��������ӵ��ӳ���````````````````````````````````````%
function Var = varVector(in)
%����-in,����ά�ϵĶ�ֵ��ͼ��
Isize=size(in);
extremum=[];
CC=regionprops(in,'Centroid');
x0=round(CC.Centroid(1,1));y0=round(CC.Centroid(1,2));z0=round(CC.Centroid(1,3));
for i=1:Isize(3)
    [L,num]=bwlabel(in(:,:,i));
    if(num~=0)
        [row,col] = find(in(:,:,i)); 
        min_x1=min(row);max_x2=max(row);min_y3=min(col);max_y4=max(col);%����ROI������ĸ�������ֵ
        extremum(end+1,1)=min_x1;extremum(end,2)=max_x2;extremum(end,4)=min_y3;extremum(end,4)=max_y4;
        min_y1=max(col(row==min_x1));max_y2=max(col(row==max_x2));min_x3=max(row(col==min_y3));max_x4=max(row(col==max_y4));
        R1=sqrt((min_x1 - x0)^2 + (min_y1 - y0)^2 + (i - z0)^2);
        R2=sqrt((max_x2 - x0)^2 + (max_y2 - y0)^2 + (i - z0)^2);
        R3=sqrt((min_x3 - x0)^2 + (min_y3 - y0)^2 + (i - z0)^2);
        R4=sqrt((max_x4 - x0)^2 + (min_y3 - y0)^2 + (i - z0)^2);
        extremum(end,5)=R1;extremum(end,6)=R2;extremum(end,7)=R3;extremum(end,8)=R4;
        sum_x=0;sum_y=0;area=0;
        for r=1:Isize(1)
            for c=1:Isize(2)
                if L(r,c)==1
                    sum_x=sum_x+r;sum_y=sum_y+c;
                    area=area+1;
                end
            end
        end
       extremum(end,9) = fix(sum_x/area); %#ok<*AGROW>
       extremum(end,10) = fix(sum_y/area);%����ÿһ�����ĵ�����
       %in( fix(sum_x/area),fix(sum_y/area),i)=0;
    end  
end 
Var=std(extremum,0,1);%������������
%%

function [circularity,pixel_ratio] = circul(in)
%������ά�ṹ���Ĳ����Բ�������Ĳ�ı������ر�    
[m,n,p]=size(in);circularity=[];pixel_ratio=[];
C1=size(find(bwperim(in(:,:,round(p/2)  ))==1));S1=size(find(in(:,:,round(p/2)  )==1));
C2=size(find(bwperim(in(:,:,round(p/2)-1))==1));S2=size(find(in(:,:,round(p/2)-1)==1));
C3=size(find(bwperim(in(:,:,round(p/2)+1))==1));S3=size(find(in(:,:,round(p/2)+1)==1));
circularity(1,1)=(C1(1,1))^2/(4*pi*S1(1,1));
circularity(1,2)=(C2(1,1))^2/(4*pi*S2(1,1));
circularity(1,3)=(C3(1,1))^2/(4*pi*S3(1,1));
[x_dim,y_dim]=find(in(:,:,round(p/2)  )==1);x_dim=sort(x_dim);y_dim=sort(y_dim);
x_c=x_dim(1,1)+round((x_dim(end,1)-x_dim(1,1))/2);y_c=y_dim(1,1)+round((y_dim(end,1)-y_dim(1,1))/2);
hw=size(find(in(x_c,:)==1));hb=n-hw(1,1);
vw=size(find(in(:,y_c)==1));vb=m-vw(1,1);
pixel_ratio(1,1)=vb/(vb+vw(1,1));%�洢 vertical black pixel ratio;
pixel_ratio(1,2)=hb/(hb+hw(1,1));%�洢 horizontal black pixel ratio;
%%





