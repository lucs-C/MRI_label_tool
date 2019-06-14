function [Mask,VOI_Centroid] = im3scan(MRdata,voxel_size)
%��SWI������ɸѡ����ѡ΢��Ѫ�������λ�ã��õ���ѡ�����Map����
%
[row,col,pils]=size(MRdata);
pixel_dim=voxel_size(1,1);
for p=1:pils
    I=MRdata(:,:,p);
    points=LoG_Blob(I,pixel_dim,30);
    Mask(:,:,p)=region_growing(I,points);
end
CC = bwconncomp(Mask,6);%�����ֵ�ָ�����ͨ��
for i=1:CC.NumObjects
    psize=size(CC.PixelIdxList{1,i});
    if(psize(1,1)>4000||psize(1,1)<20)
        Mask(CC.PixelIdxList{1,i})=0;
    end
end
 [Label,VOInum] = bwlabeln(Mask,6);%�Ժ�ѡ������б��
CC  = regionprops3(Label,'centroid','BoundingBox');
VOI_Centroid=round(CC.Centroid);%num������ͳ������λ��
VOI_BoundingBox=round(CC.BoundingBox);%����num���������С�����������
 for k=1:VOInum
     if (VOI_BoundingBox(k,end) <=2)
          VOI_Centroid(k,:) = 0;
     end
 end
 VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %ȫ������Ϊ�գ�����ȥ��
 VOI_Centroid_Num1=size(VOI_Centroid,1);
 for k=1:VOI_Centroid_Num1
    if(  VOI_Centroid(k,1) <= 10 | VOI_Centroid(k,1) >= (row - 10)...
       | VOI_Centroid(k,2) <= 10 | VOI_Centroid(k,2) >= (col - 10)...
       | VOI_Centroid(k,3) <= 10 | VOI_Centroid(k,3) >= (pils - 10) )
        VOI_Centroid(k,:) = 0;
    end
end
 VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %ȫ������Ϊ�գ�����ȥ��

% for k=1:VOI_Centroid_Num1
%     if(VOI_Centroid <= 10 | VOI_Centroid >= (row - 10))
%         VOI_Centroid(k,:) = 0;
%     end
% end
%  VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %ȫ������Ϊ�գ�����ȥ��
%   VOI_Centroid_Num2=size(VOI_Centroid,1);
% for k=1:VOI_Centroid_Num2
%     if(VOI_Centroid <= 10 | VOI_Centroid >= (col - 10))
%         VOI_Centroid(k,:) = 0;
%     end
% end
% VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %ȫ������Ϊ�գ�����ȥ��
% VOI_Centroid_Num3=size(VOI_Centroid,1);
% for k=1:VOI_Centroid_Num3
%     if(VOI_Centroid <= 10 | VOI_Centroid >= (pils - 10))
%         VOI_Centroid(k,:) = 0;
%     end
% end
% VOI_Centroid(all(VOI_Centroid == 0, 2),:) = []; %ȫ������Ϊ�գ�����ȥ��




%%``````````````````````����Ϊ���������õ��ӳ���`````````````````````````````````````````%%
%-�ӳ���1
function [points]=LoG_Blob(img,pixel_dim,num_blobs)
%���ܣ���ȡLoG�ߵ�
%img��������ͼ��
%num������Ҫ���ߵ���Ŀ
%point���������İ�
%pixelsize--�����ͼ�����صķֱ��ʣ����صĳߴ��С��
% img=double(img(:,:,1));
if nargin==1    %��������������һ����img��
    num=50;    %�򽫼��ߵ�������Ϊ120
else
    num=num_blobs;
end
%�趨LoG����
sigma_begin=round(2/pixel_dim);%������Ҫ֪�����صĳߴ��С��
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
%����߶ȹ淶����˹������˹����
snlo=zeros(img_height,img_width,sigma_nb);
for i=1:sigma_nb
    sigma=sigma_array(i);
    snlo(:,:,i)=sigma*sigma*imfilter(img,fspecial('log',...
        floor(6*sigma+1),sigma),'replicate');
end
%�����ֲ���ֵ
snlo_dil=imdilate(snlo,ones(3,3,3));%����26����ȷ���ռ����ֵ
blob_candidate_index=find(snlo==snlo_dil);%��ÿռ����ֵ���겢������Ϊ��ѡ�ߵ�
blob_candidate_value=snlo(blob_candidate_index);
[temp,index]=sort(blob_candidate_value,'descend');%��������
blob_index=blob_candidate_index(index(1:min(num,numel(index))));
[lig,col,sca]=ind2sub([img_height,img_width,sigma_nb],blob_index);
points=[lig,col];points=unique(points,'row'); 
% points=[lig,col,3*reshape(sigma_array(sca),[size(lig,1),1])];%�����е�ֵ�Ǹðߵ��Ӧ����˹������˹������Ӧֵ��sigma*3


%-2 �ӳ���2
function [Mask]=region_growing(img,points)
%���ܣ�������������ͼ����зָ�
Isize=size(img);psize=size(points);
Mask =false(Isize); 
for i=1:psize(1)
    mask = zeros(Isize);
    x=points(i,1);
    y=points(i,2); %��ʼ��������
    reg_mean = img(x,y);%��ʾ�ָ�õ������ڵ�ƽ��ֵ����ʼ��Ϊ���ӵ�ĻҶ�ֵ
    reg_size = 1;%�ָ�ĵ������򣬳�ʼ��ֻ�����ӵ�һ��
    neg_free = 1000; %��̬�����ڴ��ʱ��ÿ������������ռ��С
    neg_list = zeros(neg_free,3);
    %���������б�����Ԥ�ȷ������ڴ�������������ص������ֵ�ͻҶ�ֵ�Ŀռ䣬����
    %���ͼ��Ƚϴ���Ҫ���neg_free��ʵ��matlab�ڴ�Ķ�̬����
    neg_pos = 0;%���ڼ�¼neg_list�еĴ����������ص�ĸ���
    pixdist = 0;
    %��¼�������ص����ӵ��ָ������ľ�����
    %��һ�δ������İ˸��ռ��������ص�͵�ǰ���ӵ�ľ���
    %�����ǰ����Ϊ(x,y)��ôͨ��neigb���ǿ��Եõ���˸��������ص�λ��
   neigb = [ -1 0;
        1  0;
        0 -1;
        0  1];
    %��ʼ�������������������д��������������ص���Ѿ��ָ�õ��������ص�ĻҶ�ֵ����
    %����reg_maxdis,������������
%     region_thresh=(max(max(img))-min(min(img)))/5;
    while ( pixdist < 0.05 )
        %�����µ��������ص�neg_list��
        for j=1:4
            xn = x + neigb(j,1);
            yn = y + neigb(j,2);
            %������������Ƿ񳬹���ͼ��ı߽�
            ins = (xn>=1)&&(yn>=1)&&(xn<=Isize(1))&&(yn<=Isize(2));
            %�������������ͼ���ڲ���������δ�ָ�ã���ô������ӵ������б���
            if( ins && mask(xn,yn)==0)
                neg_pos = neg_pos+1;
                neg_list(neg_pos,:) =[ xn, yn,img(xn,yn)];%�洢��Ӧ��ĻҶ�ֵ
                mask(xn,yn) = 1;%��ע���������ص��Ѿ������ʹ�,������ζ�ţ����ڷָ�������
            end
        end
        %�����д����������ص���ѡ��һ�����ص㣬�õ�ĻҶ�ֵ���Ѿ��ָ������ҶȾ�ֵ��
        %��ľ���ֵʱ����������������С��
        dist = abs(neg_list(1:neg_pos,3)-reg_mean);
        [pixdist,index] = min(dist);
        %����������µľ�ֵ
        reg_mean = (reg_mean * reg_size +neg_list(index,3))/(reg_size + 1);
        reg_size = reg_size + 1;
        if( reg_size >100)
            mask=zeros(Isize);
            break;
        end
        %���ɵ����ӵ���Ϊ�Ѿ��ָ�õ��������ص�
        mask(x,y)=2;%��־�����ص��Ѿ��Ƿָ�õ����ص�
        x = neg_list(index,1);
        y = neg_list(index,2);
        %���µ����ӵ�Ӵ����������������б����Ƴ�
        neg_list(index,:) = neg_list(neg_pos,:);
        neg_pos = neg_pos -1;
    end
    mask = (mask==2);%����֮ǰ���ָ�õ����ص���Ϊ2
    Mask=Mask|mask;  
end
 Mask = bwmorph(Mask,'dilate');%����ն�