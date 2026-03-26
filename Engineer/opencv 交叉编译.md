# opencv 交叉编译

**板子上的gcc版本和交叉编译工具链的版本最好是一致的哦~ 当服务器大于板子上时，会出现编译错误的问题。当服务器上小于板子上时，编译没问题，而运行时会找不到动态库**

## 0.交叉工具链配置

4.9版本的工具链：[Linaro Releases](https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf/)

先看arm架构、Linux服务器、硬浮点

![](src/opencv%20交叉编译_img/2023-02-03-08-51-23-image.png)

从上面的连接下载下来的工具链为：gcc版本为4.9

![](src/opencv%20交叉编译_img/2023-02-03-08-37-49-image.png)

而Ubuntu-18的裸文件系统中内置的gcc版本为7.5！卧槽我也布吉岛为啥版本差了这么多竟然没问题。反正用18年的8.x版本就报  **libopencv_core.so: undefined reference to `fcntl@GLIBC_2.28**  这种错了

![](src/opencv%20交叉编译_img/2023-02-03-08-39-53-image.png)

海思sdk里面的工具链，也是4.x的，但是没有hf硬浮点这种选项，编译出来有问题的哦

****

环境变量

![](src/opencv%20交叉编译_img/2023-02-05-16-00-30-image.png)

## 1.下载源代码

创建build、arm_instll

打开cmake-gui

```
mkdir build
mkdir arm_install
cmake-gui
```

## 2.配置cmake

![](src/opencv%20交叉编译_img/2023-01-31-10-11-31-image.png)

配置安装路径：

![](src/opencv%20交叉编译_img/e2b32d4ac757fb6ae1b25292e7b119ae41eaaeff.png)

***

线程相关：

![](src/opencv%20交叉编译_img/2023-01-22-06-30-53-image.png)

**CMAKE_CXX_FLAGS、CMAKE_C_FLAGS、CMAKE_EXE_LINKER_FLAGS**

```
-O3 -Wall -W -fPIC -fpermissive
```

```
-O3 -Wall -W -fPIC
```

```
-ldl -lpthread -lrt
```

***

with_png、jpeg、zlib等也要加上

![](src/opencv%20交叉编译_img/4d16fbdffbe427b7eb1624b064480c73116e94fe.png)

![](src/opencv%20交叉编译_img/40505bf2691ca3c3183df26a4ab856190f9cc1e1.png)

## 3.开始编译、安装

```
make -j8
make install
```

## 4.测试

```
#include <opencv2/opencv.hpp>
#include <iostream> 
using namespace cv; 

int main( int argc, char** argv )  
{  
    Mat image;  

    //image = imread( "7.bmp", 1 );  
    if( !image.data )  
    {  
        printf( "No image data \n" );  
        return -1;  
    }   

    cv::Point lu = cv::Point(180, 60); 
    cv::Point rd = cv::Point(400, 260);   

    cv::rectangle(image, lu, rd, cv::Scalar( 255, 20, 0 ), 1, CV_AA );                     

    imwrite("8.bmp", image);        

    return 0;  
}
```

```
g++ main.cpp -o exam -I/home/sophda/src/opencv-3.4.16/arm_install/include -L/home/sophda/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

```
g++ main.cpp -o exam -I/home/sophda/opencvlib/include -L/home/sophda/opencvlib/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

```
g++ main.cpp -o exam -I/home/sophda/include -L/home/sophda/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```
