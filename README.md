# MRI_label_tool
MRI病灶区域标记辅助工具GUI源码

该GUI生成的".exe"小软件以及涉及的调用包请从百度网盘下载：

准备工作：

SWI数据存储格式：
![image](https://github.com/lucs-C/MRI_label_tool/blob/master/Read_me/图片1.png)

安装说明：

（1）安装包文件夹；需要安装才能使用；（部分电脑安装失败。

（2）免安装，直接运行的“.exe”程序，点击后缀为“.exe”文件可直接运行；

（3）类似（2），直接运行的“.exe”程序，点击后缀为“.exe”文件可直接运行；

![image](https://github.com/lucs-C/MRI_label_tool/blob/master/Read_me/图片2.png)

操作流程：

一、CMB detection

①　选择存放SWI图像的一级文件夹路径；

②　输入图像类型“SWI”

③　点击“批量处理DICOM”按键

④　等待处理结果；

![image](https://github.com/lucs-C/MRI_label_tool/blob/master/Read_me/图片3.png)
二、label Correcting

校正操作目的：（1）添加漏检的微出血点坐标；（2）去除标记错误的微出血点坐标；

①　点击“批量校正标签”按键

②　弹出窗口1，窗口2；窗口1显示了对图像中微出血点位置的标注，窗口2是来校正窗口1中图片的标注标签，最后输出为位置坐标；

![image](https://github.com/lucs-C/MRI_label_tool/blob/master/Read_me/图片4.png) ![image](https://github.com/lucs-C/MRI_label_tool/blob/master/Read_me/图片5.png)
操作1：    

通过窗口1左上角加号“+”图标按键来定位到未标记的微出血点中心坐标，将其分别输入到 x, y, z,对应的输入框中，点击“添加新的CMB坐标”按键，保存成功会弹出一个提示框；


操作2：
将左图中显示的，标记错误的标签，把其坐标输入到操作2的x, y, z 对应的输入框中，点击“去除错误CMB坐标”，去除成功后会有一个提示框提示去除成功；

操作3：
上面操作完成之后，点击“存储标签”按键对标签就行存储；

特别注意：无论是否进行“操作1”，“操作2”，在关闭窗口2之前一定要点击“存储标签”按键，否则所有的标签坐标将被擦除。

标签存储：如果是以安装说明（1）的方式安装程序包，则在图像运行后会在安装路径生成一个命名为“ground_truth”的文件夹，里面存储着以该图片名称命名的标签；
如果是以安装说明（2），（3）直接运行程序，则会在“.exe”运行程序同文件夹中生成一个“ground_truth”子文件夹，保存标签文件；


