function IMVECTOR = im3vec (ROIdata)
% 功能：对候选区域进行特征提取
%      输入：ROIdata是三维候选区域的体素元；
%      输出：IMVECTOR是26维的列向量
%
%
%% -0 升采样
[Row,Col,Pils]=size(ROIdata);
row=round(2.5*Row);col=round(2.5*Col);pils=round(2.5*Pils);
subvolume= imresize3(ROIdata,[row,col,pils],'linear');
%% -1.基于区域生长算法获得Mask 
Mask = zeros(size(subvolume)); % 主函数的返回值，记录区域生长所得到的区域
Isizes = size(subvolume);
x=round(Isizes(1)/2);
y=round(Isizes(2)/2); 
z=round(Isizes(3)/2);%选取体素中心点坐标为初始种子
reg_mean = subvolume(round(Isizes(1)/2),round(Isizes(2)/2),round(Isizes(3)/2));%表示分割好的区域内的平均值，初始化为种子点的灰度值
reg_size = 1;%分割的到的区域，初始化只有种子点一个
neg_free = 2000; %动态分配内存的时候每次申请的连续空间大小
neg_list = zeros(neg_free,4);
%定义邻域列表，并且预先分配用于储存待分析的像素点的坐标值和灰度值的空间，加速
%如果图像比较大，需要结合neg_free来实现matlab内存的动态分配
neg_pos = 0;%用于记录neg_list中的待分析的像素点的个数
pixdist = 0;
%记录最新像素点增加到分割区域后的距离测度
%下一次待分析的六个空间邻域像素点和当前种子点的距离
%如果当前坐标为（x,y,z）那么通过neigb我们可以得到其六个邻域像素的位置
neigb = [-1  0  0; 
          1  0  0;
          0 -1  0;
          0  1  0;
          0  0  1; 
          0  0 -1];
 %开始进行区域生长，当所有待分析的邻域像素点和已经分割好的区域像素点的灰度值距离
 %大于reg_maxdis,区域生长结束
while (pixdist < 0.055 && reg_size < numel(subvolume))
     %增加新的邻域像素到neg_list中
     for j=1:6
         xn = x + neigb(j,1);
         yn = y + neigb(j,2);
         zn = z + neigb(j,3);
         %检查邻域像素是否超过了图像的边界
         ins = (xn>=1)&&(yn>=1)&&(zn>=1)&&(xn<=Isizes(1))&&(yn<=Isizes(2))&&(zn<=Isizes(3));
         %如果邻域像素在图像内部，并且尚未分割好；那么将它添加到邻域列表中
         if( ins && Mask(xn,yn,zn)==0)
             neg_pos = neg_pos+1;
             neg_list(neg_pos,:) =[ xn, yn, zn,subvolume(xn,yn,zn)];%存储对应点的灰度值
             Mask(xn,yn,zn) = 1;%标注该邻域像素点已经被访问过,并不意味着，他在分割区域内
         end
     end 
    %从所有待分析的像素点中选择一个像素点，该点的灰度值和已经分割好区域灰度均值的
    %差的绝对值时所待分析像素中最小的
    dist = abs(neg_list(1:neg_pos,4)-reg_mean);
    [pixdist,index] = min(dist);
    %计算区域的新的均值
    reg_mean = (reg_mean * reg_size +neg_list(index,4))/(reg_size + 1);
    reg_size = reg_size + 1;
    %将旧的种子点标记为已经分割好的区域像素点
    Mask(x,y,z)=2;%标志该像素点已经是分割好的像素点
    x = neg_list(index,1);
    y = neg_list(index,2);
    z = neg_list(index,3);
    %将新的种子点从待分析的邻域像素列表中移除
    neg_list(index,:) = neg_list(neg_pos,:);
    neg_pos = neg_pos -1;
end
Mask = (Mask==2);%我们之前将分割好的像素点标记为20
[m,n,p]=size(Mask);superficial=zeros(m,n,p);%外轮廓图像
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
Sphericity=6*sqrt(pi)*volume_value(1,1)/((superficial_area(1,1))^1.5);%计算目标区域的球形度值
[circularity_z,pixel_ratio_z] = circul(Mask);% 似圆率与背景像素比的计算
Mask_x = permute(Mask,[2,3,1]);[circularity_x,pixel_ratio_x] = circul(Mask_x);
Mask_y = permute(Mask,[1,3,2]);[circularity_y,pixel_ratio_y] = circul(Mask_y);
circularity = [circularity_z circularity_x circularity_y];
bp_ratio=[pixel_ratio_z,pixel_ratio_x,pixel_ratio_y];
IMVECTOR=[Var Sphericity circularity bp_ratio];
IMVECTOR=IMVECTOR';
%% 
%```````````````````````````以下是添加的子程序````````````````````````````````````%
function Var = varVector(in)
%输入-in,是三维上的二值化图像
Isize=size(in);
extremum=[];
CC=regionprops(in,'Centroid');
x0=round(CC.Centroid(1,1));y0=round(CC.Centroid(1,2));z0=round(CC.Centroid(1,3));
for i=1:Isize(3)
    [L,num]=bwlabel(in(:,:,i));
    if(num~=0)
        [row,col] = find(in(:,:,i)); 
        min_x1=min(row);max_x2=max(row);min_y3=min(col);max_y4=max(col);%计算ROI区域的四个坐标最值
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
       extremum(end,10) = fix(sum_y/area);%计算每一层质心的坐标
       %in( fix(sum_x/area),fix(sum_y/area),i)=0;
    end  
end 
Var=std(extremum,0,1);%求列向量方差
%%

function [circularity,pixel_ratio] = circul(in)
%计算三维结构中心层的似圆率与中心层的背景像素比    
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
pixel_ratio(1,1)=vb/(vb+vw(1,1));%存储 vertical black pixel ratio;
pixel_ratio(1,2)=hb/(hb+hw(1,1));%存储 horizontal black pixel ratio;
%%





