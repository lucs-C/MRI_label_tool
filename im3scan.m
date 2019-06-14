function [Mask,VOI_Centroid] = im3scan(MRdata,voxel_size)
%从SWI序列中筛选出候选微出血点区域的位置，得到候选区域的Map矩阵
%
[row,col,pils]=size(MRdata);
pixel_dim=voxel_size(1,1);
for p=1:pils
    I=MRdata(:,:,p);
    points=LoG_Blob(I,pixel_dim,30);
    Mask(:,:,p)=region_growing(I,points);
end
CC = bwconncomp(Mask,6);%标记阈值分割后的连通域
for i=1:CC.NumObjects
    psize=size(CC.PixelIdxList{1,i});
    if(psize(1,1)>4000||psize(1,1)<20)
        Mask(CC.PixelIdxList{1,i})=0;
    end
end
 [Label,VOInum] = bwlabeln(Mask,6);%对候选区域进行标记
CC  = regionprops3(Label,'centroid','BoundingBox');
VOI_Centroid=round(CC.Centroid);%num个区域统计质心位置
VOI_BoundingBox=round(CC.BoundingBox);%包含num个区域的最小立方体的坐标
 for k=1:VOInum
     if (VOI_BoundingBox(k,end) <=2)
          VOI_Centroid(k,:) = 0;
     end
 end
 VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %全零行若为空，即可去掉
 VOI_Centroid_Num1=size(VOI_Centroid,1);
 for k=1:VOI_Centroid_Num1
    if(  VOI_Centroid(k,1) <= 10 | VOI_Centroid(k,1) >= (row - 10)...
       | VOI_Centroid(k,2) <= 10 | VOI_Centroid(k,2) >= (col - 10)...
       | VOI_Centroid(k,3) <= 10 | VOI_Centroid(k,3) >= (pils - 10) )
        VOI_Centroid(k,:) = 0;
    end
end
 VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %全零行若为空，即可去掉

% for k=1:VOI_Centroid_Num1
%     if(VOI_Centroid <= 10 | VOI_Centroid >= (row - 10))
%         VOI_Centroid(k,:) = 0;
%     end
% end
%  VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %全零行若为空，即可去掉
%   VOI_Centroid_Num2=size(VOI_Centroid,1);
% for k=1:VOI_Centroid_Num2
%     if(VOI_Centroid <= 10 | VOI_Centroid >= (col - 10))
%         VOI_Centroid(k,:) = 0;
%     end
% end
% VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %全零行若为空，即可去掉
% VOI_Centroid_Num3=size(VOI_Centroid,1);
% for k=1:VOI_Centroid_Num3
%     if(VOI_Centroid <= 10 | VOI_Centroid >= (pils - 10))
%         VOI_Centroid(k,:) = 0;
%     end
% end
% VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %全零行若为空，即可去掉




%%``````````````````````以下为主函数调用的子程序`````````````````````````````````````````%%
%-子程序1
function [points]=LoG_Blob(img,pixel_dim,num_blobs)
%功能：提取LoG斑点
%img——输入图像
%num——需要检测斑点数目
%point——检测出的斑
%pixelsize--待检测图像像素的分辨率（像素的尺寸大小）
% img=double(img(:,:,1));
if nargin==1    %如果输入参数仅有一个（img）
    num=50;    %则将检测斑点数设置为120
else
    num=num_blobs;
end
%设定LoG参数
sigma_begin=round(2/pixel_dim);%这里需要知道像素的尺寸大小；
sigma_end=round(8/pixel_dim);
sigma_step=2;
sigma_array=sigma_begin:sigma_step:sigma_end;
sigma_array=1/sqrt(2)*sigma_array;
% sigma_begin=1;
% sigma_end=3;
% sigma_step=0.2;
% sigma_array=sigma_begin:sigma_step:sigma_end;
sigma_nb=numel(sigma_array);
    %n = numel(A) returns the number of elements, n, in array A
    %equivalent to prod(size(A)).
img_height=size(img,1);
img_width=size(img,2);
%计算尺度规范化高斯拉普拉斯算子
snlo=zeros(img_height,img_width,sigma_nb);
for i=1:sigma_nb
    sigma=sigma_array(i);
    snlo(:,:,i)=sigma*sigma*imfilter(img,fspecial('log',...
        floor(6*sigma+1),sigma),'replicate');
end
%搜索局部极值
snlo_dil=imdilate(snlo,ones(3,3,3));%查找26邻域确定空间最大值
blob_candidate_index=find(snlo==snlo_dil);%获得空间最大值坐标并将其作为候选斑点
blob_candidate_value=snlo(blob_candidate_index);
[temp,index]=sort(blob_candidate_value,'descend');%降序排列
blob_index=blob_candidate_index(index(1:min(num,numel(index))));
[lig,col,sca]=ind2sub([img_height,img_width,sigma_nb],blob_index);
points=[lig,col];points=unique(points,'row'); 
% points=[lig,col,3*reshape(sigma_array(sca),[size(lig,1),1])];%第三列的值是该斑点对应最大高斯拉普拉斯函数响应值的sigma*3


%-2 子程序2
function [Mask]=region_growing(img,points)
%功能：区域生长法对图像进行分割
Isize=size(img);psize=size(points);
Mask =false(Isize); 
for i=1:psize(1)
    mask = zeros(Isize);
    x=points(i,1);
    y=points(i,2); %初始种子坐标
    reg_mean = img(x,y);%表示分割好的区域内的平均值，初始化为种子点的灰度值
    reg_size = 1;%分割的到的区域，初始化只有种子点一个
    neg_free = 1000; %动态分配内存的时候每次申请的连续空间大小
    neg_list = zeros(neg_free,3);
    %定义邻域列表，并且预先分配用于储存待分析的像素点的坐标值和灰度值的空间，加速
    %如果图像比较大，需要结合neg_free来实现matlab内存的动态分配
    neg_pos = 0;%用于记录neg_list中的待分析的像素点的个数
    pixdist = 0;
    %记录最新像素点增加到分割区域后的距离测度
    %下一次待分析的八个空间邻域像素点和当前种子点的距离
    %如果当前坐标为(x,y)那么通过neigb我们可以得到其八个邻域像素的位置
   neigb = [ -1 0;
        1  0;
        0 -1;
        0  1];
    %开始进行区域生长，当所有待分析的邻域像素点和已经分割好的区域像素点的灰度值距离
    %大于reg_maxdis,区域生长结束
%     region_thresh=(max(max(img))-min(min(img)))/5;
    while ( pixdist < 0.05 )
        %增加新的邻域像素到neg_list中
        for j=1:4
            xn = x + neigb(j,1);
            yn = y + neigb(j,2);
            %检查邻域像素是否超过了图像的边界
            ins = (xn>=1)&&(yn>=1)&&(xn<=Isize(1))&&(yn<=Isize(2));
            %如果邻域像素在图像内部，并且尚未分割好；那么将它添加到邻域列表中
            if( ins && mask(xn,yn)==0)
                neg_pos = neg_pos+1;
                neg_list(neg_pos,:) =[ xn, yn,img(xn,yn)];%存储对应点的灰度值
                mask(xn,yn) = 1;%标注该邻域像素点已经被访问过,并不意味着，他在分割区域内
            end
        end
        %从所有待分析的像素点中选择一个像素点，该点的灰度值和已经分割好区域灰度均值的
        %差的绝对值时所待分析像素中最小的
        dist = abs(neg_list(1:neg_pos,3)-reg_mean);
        [pixdist,index] = min(dist);
        %计算区域的新的均值
        reg_mean = (reg_mean * reg_size +neg_list(index,3))/(reg_size + 1);
        reg_size = reg_size + 1;
        if( reg_size >100)
            mask=zeros(Isize);
            break;
        end
        %将旧的种子点标记为已经分割好的区域像素点
        mask(x,y)=2;%标志该像素点已经是分割好的像素点
        x = neg_list(index,1);
        y = neg_list(index,2);
        %将新的种子点从待分析的邻域像素列表中移除
        neg_list(index,:) = neg_list(neg_pos,:);
        neg_pos = neg_pos -1;
    end
    mask = (mask==2);%我们之前将分割好的像素点标记为2
    Mask=Mask|mask;  
end
 Mask = bwmorph(Mask,'dilate');%补充空洞