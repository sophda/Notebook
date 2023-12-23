# Linux

## 解压缩相关

### 解压

```
tar -xf cv.tar.xz  //解压
```

### 压缩

```
tar -cvf [文件名].tar [文件目录] //打包成.tar文件
tar -jcvf [文件名].tar.bz2 [文件目录] //打包成.bz2文件
tar -zcvf [文件名].tar.gz [文件目录] //打包成.gz文件
```

## 编译

### **动态库编译：**

```
g++ main.cpp -lmath -L/usr/local/lib -o main
//-l指定库  -o指定输出  -L指定路径
```

**编译opencv：**

```
g++ main.cpp -o exam -I/home/sophda/include -L/home/sophda/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

```
 g++ main.cpp -o exam -I/lib/include -Wl,-rpath,/lib/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

### **静态库编译：**

```
g++ main.cpp -static -o exam -L/home/cvlib -mfpu=neon -mfloat-abi=hard  -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

**交叉编译：（静态）**

```
arm-linux-gnueabi-g++ main.cpp -o exam -static -I/home/sophyda/opencv-3.2.0/arm-install/include -L/home/sophyda/opencv-3.2.0/arm-install/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```



# 方法

## 设置环境变量

```
1.设置可执行文件路径
vi ~/.bashrc
//在最后面加上
export PATH=$PATH:value
//其中value表示你的bin可执行文件的地址
```

```
2.设置变量值
vi ~/.bashrc
export NDK=/home/sophda/src/android-ndk-r25c/
//这样就可以直接
echo ${NDK}
```

![image-20230714044728254](src/image-20230714044728254.png)



## 查看动态库

1. readelf

   ```
   readelf -a libhello.so
   ```

   **查看库的平台，x86/arm：**

   ```
   readelf -h libopencv_photo.so
   ```

   ![image-20230716045800044](src/image-20230716045800044.png)

   **查看库的依赖：**

   ```
   readelf -a libxxx.so | grep "Shared"
   ```

   

2. nm

   ```
   nm libhello.so
   ```

3. 查看动态库函数

   ```
   nm -D lib***.so
   ```


4. 查看动态库是32为还是64位

   动态库：

   ```
   file xxx.so
   ```

   静态库

   ```
   objdump -a xxx.a
   ```
   



## 杀死进程

```
pgrep -f your_process_name //获取进程号，即pid
kill -15 pid  //根据pid杀死进程，15表示优雅的退出
```

比如，我的clion界面没有了（cnm在wsl中b事这么多），但是后台还在运行，所以需要kill掉

```
pgrep -f clion
kill -15 pid
```



# sh脚本



