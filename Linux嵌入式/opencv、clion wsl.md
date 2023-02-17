# opencv---clion&wsl

1.安装依赖

```
sudo apt update
sudo apt install libopencv-dev python3-opencv
```

```
sudo apt install build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libdc1394-22-dev libopenexr-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
```

2.编译选项(用cmkegui)

```
cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON ..
```

3.运行

查看opencv用到的库

```
pkg-config --cflags --libs opencv
```

clion中cmake：

```
cmake_minimum_required(VERSION 3.21)
project(OpenCV_Test)

set(CMAKE_CXX_STANDARD 11)

add_executable(OpenCV_Test main.cpp)

find_package(OpenCV REQUIRED)
target_link_libraries(OpenCV_Test 复制上面的库文件)
```

4.添加环境变量

在~/.bashrc中添加：

```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
```

使得环境变量生效：

```
source ~/.bashrc
```

关闭当前终端，在下一个终端中试一试

# PCL--Clion&WSL

## 1.安装

## 2.删除

```
sudo rm -r build
sudo rm -r /usr/include/pcl-1.7 /usr/share/pcl /usr/bin/pcl* /usr/lib/libpcl*
```

执行上述命令， 上述四个目录中，可能会找不到某些目录。可以自己去 `usr` 目录下搜索 关键字 `pcl` 或者 `libpcl`。本人在目录 `/usr/libx86_64-linux-gnu` 下找到 相关libpcl*文件，删除即可，删除命令同上。
