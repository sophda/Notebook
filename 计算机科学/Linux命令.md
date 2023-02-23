# Linux命令

## 1.解压缩相关

## 1.1解压

```
tar -xf cv.tar.xz  //解压
```

## 1.2压缩

```

```

## 2.编译

## **2.1动态库编译：**

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

## **2.2静态库编译：**

```
g++ main.cpp -static -o exam -L/home/cvlib -mfpu=neon -mfloat-abi=hard  -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

**交叉编译：（静态）**

```
arm-linux-gnueabi-g++ main.cpp -o exam -static -I/home/sophyda/opencv-3.2.0/arm-install/include -L/home/sophyda/opencv-3.2.0/arm-install/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```
