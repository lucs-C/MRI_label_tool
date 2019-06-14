function [out_V,voxel_size]=Scale_normalization(in_V,voxel_size)
%x_scale,y_scale,z_scale是原始图像三个轴的像素尺寸；
X_dim = voxel_size(1,1);%x-axis's pixel dimensional
Y_dim = voxel_size(1,2);
Z_dim = voxel_size(1,3);
%X_dim = x_scale;
%Y_dim = y_scale;
%Z_dim = z_scale;
[Row,Col,Pils]=size(in_V);
Width  = Row * X_dim;
Height = Col * Y_dim;
Depth  = Pils *Z_dim;
% if (X_dim < 0.5)
%     pixel_dim = X_dim;
% else
%     pixel_dim = 0.5;
% end
pixel_dim = 0.5;
voxel_size = [pixel_dim,pixel_dim,pixel_dim];
row  = round(Width/pixel_dim);
col  = round(Height/pixel_dim);
pils = round(Depth/pixel_dim);
out_V= imresize3(in_V,[row,col,pils],'linear');%利用线性插值得到预期大小的体素；



