# orbslam+ace=AR

主要是通过ace网络和vinsmono，共同进行重定位

浙大他们是使用的loftr进行的匹配，然后进行的slam定位，他妈的我用ace+slam应该也可以达到一样的效果，他妈的小小浙大，看我取之

# ace libtorch部署

## libtorch安卓端交叉编译



## Python模型导出

使用torch.jit.trace完成，本来是想用torch script将模型编译成可运行的脚本，这样即使在运行的时候有tensor的切片操作也可以进行相应的处理。





## 模型推理

> 由于Python端是使用skimage+pil进行训练的，而libtorch端需要使用opencv端进行图像读取和处理，因此这里需要对读取的图像进行处理。

```python
# python 端代码
from skimage import color
from skimage import io
from skimage.transform import rotate, resize
import torchvision.transforms.functional as TF
from torchvision import transforms

image_transform = transforms.Compose([
                # transforms.ToPILImage(),
                # transforms.Resize(self.image_height),
                transforms.Grayscale(),
                transforms.ToTensor(),
                # transforms.Normalize(
                #     mean=[0.4],  # statistics calculated over 7scenes training set, should generalize fairly well
                #     std=[0.25]
                # ),
            ])

def resize_image(image, image_height):
    image = TF.to_pil_image(image)
    print("image pil:",image.size)
    image = TF.resize(image, image_height)
    print("image pil after resize:",image.size)

    return image
image = io.imread("/home/sophda/project/ace/datasets/Cambridge_KingsCollege/train/rgb/seq1_frame00001.png")
print(image.shape)

k = np.loadtxt("/home/sophda/project/ace/datasets/Cambridge_KingsCollege/train/calibration/seq1_frame00001.txt")

if len(image.shape)<3:
    image = color.gray2rgb(image)

if k.size == 1:
    focal_length = float(k)
    centre_point = None
elif k.shape == (3, 3):
    k = k.tolist()
    focal_length = [k[0][0], k[1][1]]
    centre_point = [k[0][2], k[1][2]]
else: 
    raise Exception("Calibration file must contain either a 3x3 camera \
        intrinsics matrix or a single float giving the focal length \
        of the camera.")

# The image will be scaled to image_height, adjust focal length as well.
image_height = 480
f_scale_factor = image_height / image.shape[0]
if centre_point:
    centre_point = [c * f_scale_factor for c in centre_point]
    focal_length = [f * f_scale_factor for f in focal_length]
else:
    focal_length *= f_scale_factor

# Rescale image.
image = resize_image(image, image_height)
image = image_transform(image)

intrinsics = torch.eye(3)

# Hardcode the principal point to the centre of the image unless otherwise specified.
if centre_point:
    intrinsics[0, 0] = focal_length[0]
    intrinsics[1, 1] = focal_length[1]
    intrinsics[0, 2] = centre_point[0]
    intrinsics[1, 2] = centre_point[1]
else:
    intrinsics[0, 0] = focal_length
    intrinsics[1, 1] = focal_length
    intrinsics[0, 2] = image.shape[2] / 2
    intrinsics[1, 2] = image.shape[1] / 2

image_B1HW = image.unsqueeze(0)
intrinsics_B33 = intrinsics.unsqueeze(0)

print(image_B1HW.shape)
print(intrinsics_B33.shape)
```

这里主要是使用skimage读取的，出来的尺寸是[H,W,C]

然后转为PIL图像后，变成了[W,H,C]

变成tensor.Tensor之后又变成了[B,C,H,W]，也就是说libtorch 端放入的图像tensor也应该是这种尺寸的。

那么在libtorch 中也要讲图像改成这个形式的。

```c++
void AceLocal::forward(cv::Mat& img, torch::Tensor& output){

    torch::Tensor img_tensor = torch::from_blob(
            img.data,
            {480,854,1},  // H W C
            torch::kFloat32
            );
    img_tensor = img_tensor.permute({2,0,1});
    img_tensor = img_tensor.unsqueeze(0);
    torch::Tensor model_output, dsacstar_output;
    dsacstar_output = torch::zeros({4,4});
    torch::NoGradGuard no_grad;
    model_output = model_({img_tensor}).toTensor();
    }

///////////////////////////////////////////////////////////////////////////////

cv::Mat img = cv::imread(i),
img_r,img_f,img_n;
cv::cvtColor(img,img_r,cv::COLOR_BGR2GRAY);
img_r.convertTo(img_f,CV_32FC3,1/255.0);

cv::Mat normalized;
cv::subtract(img_f, cv::Scalar(0.485, 0.456, 0.406), normalized);
cv::divide(normalized, cv::Scalar(0.229, 0.224, 0.225), normalized);

normalized = img_f;

ace.forward(normalized,pos);

```



# 相机标定

## 录制bag包（ros free）

环境配置：

> 在windows环境中部署一个Python环境，为啥要录制呢，因为要标定imu和相机

```
2025/04/01  00:26    <DIR>          .
2025/04/01  00:10    <DIR>          ..
2025/04/01  00:19            41,008 catkin-0.7.18-py2.py3-none-any.whl
2022/01/10  17:32             6,058 cv_bridge-1.13.0.post0-py2.py3-none-any.whl
2025/04/01  00:15            25,395 genmsg-0.5.12-py2.py3-none-any.whl
2025/04/01  00:16            37,487 genpy-0.6.12-py2.py3-none-any.whl
2025/04/01  00:26            57,999 geometry_msgs-1.12.7-py2.py3-none-any.whl
2025/04/01  00:14            49,313 rosbag-1.14.3-py2.py3-none-any.whl
2022/01/10  10:41            48,817 rosbag-1.15.11-py2.py3-none-any.whl
2025/04/01  00:23             7,609 roscpp-1.14.3-py2.py3-none-any.whl
2025/04/01  00:17            37,165 rosgraph-1.14.3-py2.py3-none-any.whl
2025/04/01  00:20             7,641 rosgraph_msgs-1.11.2-py2.py3-none-any.whl
2025/04/01  00:16            62,697 roslib-1.14.6-py2.py3-none-any.whl
2025/04/01  00:24            15,474 roslz4-1.14.3.post1-cp38-cp38-win_amd64.whl
2025/04/01  00:16           116,107 rospy-1.14.3-py2.py3-none-any.whl
2025/04/01  00:25            73,481 sensor_msgs-1.12.7-py2.py3-none-any.whl
2025/04/01  00:19            56,124 std_msgs-0.5.12-py2.py3-none-any.whl
```

一共是下载了这些包，一个个试出来的

---

Python录制bag包：

```python
# coding=utf-8
import rosbag
import sys
import os
import numpy as np
import cv2
from sensor_msgs.msg import Image, Imu
from cv_bridge import CvBridge
import rospy
from geometry_msgs.msg import Vector3


def findFiles(root_dir, filter_type, reverse=False):
    """
    在指定目录查找指定类型文件 -> paths, names, files
    :param root_dir: 查找目录
    :param filter_type: 文件类型
    :param reverse: 是否返回倒序文件列表，默认为False
    :return: 路径、名称、文件全路径
    """

    separator = os.path.sep
    paths = []
    names = []
    files = []
    for parent, dirname, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(filter_type):
                paths.append(parent + separator)
                names.append(filename)
    for i in range(paths.__len__()):
        files.append(paths[i] + names[i])
    print(names.__len__().__str__() + " files have been found.")
    
    paths = np.array(paths)
    names = np.array(names)
    files = np.array(files)

    index = np.argsort(files)

    paths = paths[index]
    names = names[index]
    files = files[index]

    paths = list(paths)
    names = list(names)
    files = list(files)
    
    if reverse:
        paths.reverse()
        names.reverse()
        files.reverse()
    return paths, names, files

def readIMU(imu_path):
    timestamps = []
    wxs = []
    wys = []
    wzs = []
    axs = []
    ays = []
    azs = []
    fin = open(imu_path, 'r')
    fin.readline()
    line = fin.readline().strip()
    while line:
        parts = line.split(",")
        ts = float(parts[0])/10e8
        wx = float(parts[1])
        wy = float(parts[2])
        wz = float(parts[3])
        ax = float(parts[4])
        ay = float(parts[5])
        az = float(parts[6])
        timestamps.append(ts)

        wxs.append(wx)
        wys.append(wy)
        wzs.append(wz)
        axs.append(ax)
        ays.append(ay)
        azs.append(az)
        line = fin.readline().strip()
    return timestamps, wxs, wys, wzs, axs, ays, azs


if __name__ == '__main__':
    # img_dir = sys.argv[1]   # 影像所在文件夹路径
    # img_type = sys.argv[2]  # 影像文件类型
    # img_topic_name = sys.argv[3]    # 影像Topic名称
    # imu_path = sys.argv[4]  # IMU文件路径
    # imu_topic_name = sys.argv[5]    # IMU Topic名称
    # bag_path = sys.argv[6]  # Bag文件输出路径

    img_dir = "./data/img"
    img_type = "png"
    img_topic_name = "topic_img"

    imu_path = './data/imu/imu.txt'
    imu_topic_name = "topic_imu"
    bag_path = "./bag/img_imu1.bag"

    bag_out = rosbag.Bag(bag_path,'w')

    # 先处理IMU数据
    imu_ts, wxs, wys, wzs, axs, ays, azs = readIMU(imu_path)
    imu_msg = Imu()
    angular_v = Vector3()
    linear_a = Vector3()
    print(imu_ts)
    for i in range(len(imu_ts)):
        imu_ts_ros = rospy.rostime.Time.from_sec(imu_ts[i])
        imu_msg.header.stamp = imu_ts_ros
        
        angular_v.x = wxs[i]
        angular_v.y = wys[i]
        angular_v.z = wzs[i]

        linear_a.x = axs[i]
        linear_a.y = ays[i]
        linear_a.z = azs[i]

        imu_msg.angular_velocity = angular_v
        imu_msg.linear_acceleration = linear_a

        bag_out.write(imu_topic_name, imu_msg, imu_ts_ros)
        print('imu:',i,'/',len(imu_ts))

    # 再处理影像数据
    paths, names, files = findFiles(img_dir,img_type)
    cb = CvBridge()
    
    for i in range(len(files)):
        print('image:',i,'/',len(files))

        frame_img = cv2.imread(files[i])
        timestamp = int(names[i].split(".")[0])/10e8
        print(timestamp)

        ros_ts = rospy.rostime.Time.from_sec(timestamp)
        ros_img = cb.cv2_to_imgmsg(frame_img,encoding='bgr8')
        ros_img.header.stamp = ros_ts
        bag_out.write(img_topic_name,ros_img,ros_ts)
    
    bag_out.close()
```

录制完后有一个bag文件

---

## matlab处理bag文件

```matlab
% function data = ...
%     ros(rosbagFileName, imuTopicName, ...
%     imageTopicName, cameraInfoTopicName)

rosbagFileName = "./img_imu1.bag"
imuTopicName = "topic_imu"
imageTopicName = "topic_img"
cameraInfoTopicName = ""
%helperROSReadData reads accelerometer, gyroscope readings along
%with their time stamps and returns as a timetable.
%
%   Possible syntax:
%
%   data = helperROSReadData(rosbagFileName, imuTopicName) reads
%      only IMU measurements from rosbag into timetable.
%
%   data =
%   helperROSReadData(rosbagFileName, imuTopicName, imageTopicName) reads
%      both IMU measurements and image data from rosbag.
%
%   data = helperROSReadData(rosbagFileName, imuTopicName, imageTopicName, 
%                     cameraInfoTopicName) additionally reads camera
%      intrinsic information rosbag.

% Copyright 2023-2024 The MathWorks, Inc.

% Create ROS bag reader.
fullBag = rosbagreader(rosbagFileName)
% Select IMU topic.
imuBag = select(fullBag,"Topic",imuTopicName);
% Read IMU messages.
imuMessages = readMessages(imuBag,"DataFormat","struct");
% Extract accelerometer, gyroscope readings and time stamp from IMU
% messages. Note that we are reading the time stamps from the message
% header. We can also consider the received time of ROS message
% (imuBag.MessageList.Time). Received time stamp is helpful when sensors
% don't have a common clock.
meas = cellfun(@(in) ...
    [in.LinearAcceleration.X,in.LinearAcceleration.Y,in.LinearAcceleration.Z, ...
    in.AngularVelocity.X,in.AngularVelocity.Y,in.AngularVelocity.Z, ...
    (double(in.Header.Stamp.Sec) + double(in.Header.Stamp.Nsec)*1e-9)],...
    imuMessages,'UniformOutput',false);

meas = vertcat(meas{:})
% Create IMU measurement timetable.
imuMeasurements = timetable(meas(:,1:3),meas(:,4:6), ...
    RowTimes=datetime(meas(:,7),"ConvertFrom","posixtime"),...
    VariableNames={'Accelerometer','Gyroscope'});
data = struct('imuMeasurements',imuMeasurements);


% Select image data topic.
imageBag = select(fullBag,"Topic",imageTopicName);
% Read ROS image messages.
imageMessages = readMessages(imageBag,"DataFormat","struct");
% Extract images.
images = cellfun(@rosReadImage,imageMessages,'UniformOutput',false);
images = cat(4,images{:});
% Extract image time stamps. Note that we are reading the time stamps
% from the message header. We can also consider the received time of
% ROS message (imageBag.MessageList.Time). Received time stamp is
% helpful when sensor don't have a common clock.
imageTimeStamps = datetime(cellfun(@(in)(double(...
    in.Header.Stamp.Sec) + double(...
    in.Header.Stamp.Nsec)*1e-9),imageMessages),...
    "ConvertFrom","posixtime");
data.images = images;
data.imageTime = imageTimeStamps;


% if nargin > 3
%     % Select camera information  topic.
%     camInfoBag = select(fullBag,"Topic",cameraInfoTopicName);
%     % Read messages.
%     camInfoMessages = readMessages(camInfoBag,"DataFormat","struct");
%     data.focalLength = [camInfoMessages{1}.K(1),camInfoMessages{1}.K(1)];
%     data.principalPoint = [camInfoMessages{1}.K(3),camInfoMessages{1}.K(6)];
%     data.radialDistortion = [camInfoMessages{1}.D(1),camInfoMessages{1}.D(2)];
%     data.tangentialDistortion = [camInfoMessages{1}.D(3),camInfoMessages{1}.D(4)];
% end

%%
% Camera intrinsic parameters relevant to this data.
dynamicData = data;
CameraFocalLength = dynamicData.focalLength;
CameraPrincipalPoint = dynamicData.principalPoint;
ImageSize = size(dynamicData.images,[1,2]);

% Checkerboard parameters
CheckerBoardSquareSize = 0.04;
CheckerBoardSize = [8,11];

% Detect checkerboard in dynamic data.
[PatternDetections,~,ImagesUsed] = detectCheckerboardPoints(...
     dynamicData.images,HighDistortion=false,ShowProgressBar=true, ...
     PartialDetections=false);
ImageTime = dynamicData.imageTime(ImagesUsed);

% Retrieve IMU data.
IMUMeasurements = dynamicData.imuMeasurements;
% StaticIMUMeasurements = staticData.imuMeasurements;

% save required data
save CameraIMUCalibrationData CameraFocalLength CameraPrincipalPoint ImageSize CheckerBoardSquareSize CheckerBoardSize StaticIMUMeasurements IMUMeasurements PatternDetections ImageTime
```



# orbslam3

这里倒是没有什么部署难点，主要是orbslam在对单目+imu定位时，yaml会需要一些旋转矩阵之类的，缺少会报错

# 相机与陀螺仪数据处理

## 时间戳同步

这里主要是通过两个时间戳相减，然后在补偿另外一个即可

值得注意的是时间戳的来源，unity 使用的是java类中的方法。

