# cmake一些参数

主要是在Linux系统下使用到的一些cmake参数

## 1.set

## 2.find_package

该命令主要是引入项目所需要的包，主要工作方式有两种：module和config

**Module**

在Module模式中，cmake需要找到一个叫做`Find<LibraryName>.cmake`的文件。这个文件负责找到库所在的路径，为我们的项目引入头文件路径和库文件路径。cmake搜索这个文件的路径有两个，一个是上文提到的cmake安装目录下的`share/cmake-<version>/Modules`目录，另一个使我们指定的`CMAKE_MODULE_PATH`的所在目录。[Cmake之深入理解find_package()的用法 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/97369704)

*这些find××.cmake一般由包项目提供，如opencv等，然后会复制到cmake的安装目录下面，在以后的项目构建中可能会用到*

![](src/cmake/aa70e0ea18a4c313eea26521a47b37c5010a3f34.png)

***

**Config模式**

如果Module模式搜索失败，没有找到对应的`Find<LibraryName>.cmake`文件，则转入Config模式进行搜索。它主要通过`<LibraryName>Config.cmake` or `<lower-case-package-name>-config.cmake`这两个文件来引入我们需要的库。以我们刚刚安装的pcl库为例，在我们安装之后，它在`/usr/local/share/pcl-version`目录下生成了`PCLConfig.cmake`文件，而`/usr/local/lib/cmake/<LibraryName>/`正是find_package函数的搜索路径之一。（find_package的搜索路径是一系列的集合，而且在linux，windows，mac上都会有所区别，需要的可以参考官方文档[find_package](https://cmake.org/cmake/help/latest/command/find_package.html)）

![](src/cmake/01d498c7add90d19731bf039fb1712424c134cd8.png)

搜索路径：

![](src/cmake/13bcebcede6fddf8a9e3426ef7c565395d6ad55c.png)

以pcl为例，prefix为`/usr/local`

![](src/cmake/9b56b99520edbfbdaad4ac98c47c7d7bf6dc65f1.png)

***

**综上所述，使用find_package找到包的路径，然后在自己的项目中使用。一般找到了Config.cmake文件，通过查看里面的宏定义，即可查看包名：**

![](src/cmake/3150f295ab898097be2b8531895d33a46d445590.png)

即`PCL_LIBRARIES`为包名字，然后再项目中使用时，即可引用这个宏：

![](src/cmake/732b9cee1d38a64f77a3f2cdbdb08481aedbdd9a.png)

opencv的Config.cmake则提供了更加详细的使用方式：（也就是在本项目中的cmakelist中包括了 `find_package` 之后，在cmakelist中的`OpenCv_LIBS` 才有了定义）

![](src/cmake/d48795f2df35df87e8ac8dc7f6d86f9b1996e41f.png)

这样，cmakelist就很简洁，不用指定动态库了~~

![](src/cmake/ddb78e20b275c812981e69f68cb06cbbf4e9c36c.png)

## 编译参数

在`cmake`脚本中，设置编译选项可以通过`add_compile_options`命令，也可以通过`set`命令修改`CMAKE_CXX_FLAGS`或`CMAKE_C_FLAGS`。 使用这两种方式在有的情况下效果是一样的，但请注意它们还是有区别的：

1. `add_compile_options`命令添加的编译选项是针对所有编译器的(包括c和c++编译器)，
2. 而set命令设置`CMAKE_C_FLAGS`或`CMAKE_CXX_FLAGS`变量则是**分别**只针对c和c++编译器的。

---

**-D**

1. -D 相当于就是定义, -D 可以理解为告诉cmake 后边我要定义一些参数了, 你每定义一个就在前边加上-D就是了
2. CMAKE_BUILD_TYPE 这种东西往往是在CMakeList.txt 中定义的, 这个是你要编译的类型, 一般的选择有debug,release, 但是不确定
3. CMAKE_INSTALL_PREFIX 这个是安装路径

  也就是-D定义了参数，然后告诉编译器一些定义，那么这些定义应该是包含在编译器中的

4. -D参数可以用于在CMake中定义变量并将其传递给CMakeLists.txt文件，这些变量可以用于控制构建过程中的行为。具体而言，-D参数可以用于：

## cmake-gui的add entry

这是给cmakecache文件增加参数，好让编译器在构建的时候可以根据参数来构建。

那么这些参数可以通过三种方式来增加：

1. 使用cmake-gui 的 add entry，增加参数。

   ![image-20230928222454827](src/cmake/image-20230928222454827.png)

2. cmakelist.txt

   ```
   set(ANDROID_ABI "armeabi-v7a" CACHE STRING "")
   
   set(ANDROID_PLATFORM "19" CACHE STRING "")
   
   
   // 64位
   set(ANDROID_ABI "arm64-v8a" CACHE STRING "")
   set(ANDROID_PLATFORM "19" CACHE STRING "")
   ```

   这种方法在进行构建后，会直接写到cmakecache中，所以如果修改了cmakelist文件，需要清除cache

3. cmake -D

   ```
   cmake -DANDROID_ABI=armeabi-7a ..
   ```

   

# 方法

## find_package

**批量引入库文件和头文件**，需要通过.cmake为后缀的文件引入，配合关键字：

1. REQUIRED:必须找到库，否则就报错
2. COMPONENTS:从库中找到字库

以opencv为例子，opencv提供的是OpenCVConfig.cmake，只需要引用一次，就可以将opencv库所有的库文件和头文件引入到当前工程。

```cmake
find_package(OpenCV REQUIRED)
 
# OpenCV_INCLUDE_DIRS 是预定义变量，代表OpenCV库的头文件路径
include_directories(${OpenCV_INCLUDE_DIRS}) 
 
# OpenCV_LIBS 是预定义变量，代表OpenCV库的lib库文件
target_link_libraries(MY_TARGET_NAME ${OpenCV_LIBS})
```



## include_directories

**引入头文件目录**，即引入头文件搜索路径，当工程用到某个头文件时，就会去该路径下搜索。

```cmake
# 绝对路径引入
include_directories("D:\\ProgramFiles\\Qt\\qt5_7_lib_shared_64\\include")
 
# 普通变量引入(可以理解为把D:\\ProgramFiles\\Qt\\qt5_7_lib_shared_64放入一个集合INCLUDE_PATH)
# ${变量名} 可以获取集合内容，允许拼接
set (INCLUDE_PATH D:\\ProgramFiles\\Qt\\qt5_7_lib_shared_64)
include_directories(${INCLUDE_PATH}/include)       
 
# 环境变量引入
# 假设环境变量是INCLUDE_PATH = D:\\ProgramFiles\\Qt\\qt5_7_lib_shared_64
# #ENV{环境变量名} 可以获取环境变量的内容，允许拼接
include_directories($ENV{INCLUDE_PATH}/include)
```

一个cmake总工程可以包含多个子工程，总工程引入的头文件，并不代表子工程就可以用，就好比幼儿园老师（总工程）买来一箱苹果，小朋友（子工程）根据需求拿苹果。

引入的头文件如果需要了其他的文件，还需要使用add_executable把对应的文件包含进去

## link_directories(要放在add_library前面)

**引入库目录，添加库文件的搜索路径**，若工程在编译的时候会需要用到某个第三方库的 lib 文件，此时就可以使用 link_libraries 来添加搜索路径。

```cmake
# 绝对引入
link_libraries("D:\ProgramFiles\Qt\qt5_7_lib_shared_64\lib")
 
# 预定义变量引入
# PROJECT_SOURCE_DIR 是cmake的预定义变量，表示顶层CmakeList文件所在路径
link_libraries(${PROJECT_SOURCE_DIR}/ExtLib/ffmpeg/win64/lib)
 
# 环境变量引入
# 环境变量 QT_LIB = D:\\ProgramFiles\\Qt\\qt5_7_lib_shared_64
link_libraries($ENV{QT_LIB}/lib)
```



## link_libraries

**引入库文件**，表示将**具体的库文件**引入到当前工程中，所填写的必须为全路径

```
# 全路径引入
LINK_LIBRARIES("/opt/MATLAB/R2012a/bin/glnxa64/libeng.so")
```



## target_link_libraries

**引入库文件到子工程**，表示添加第三方库到目标子工程，**link_directories表示引入库目录到当前工程**，link_libraries表示引入到当前工程。**link_libraries 是引入库文件到当前工程**，具体是哪个工程并没有指明，就好比，货车把满载的货物运到幼儿园里，但是没分配。

**target_link_libraries 起的作用就是分发工作，分发xx库给指定工程，注意xx库必须是当前工程中有的或者 搜索路径里有的。**

```cmake
target_link_libraries(子工程名 库文件1 库文件2 ...)     # 注意子工程名和库文件名之间以空格隔开
```



## target_include_directories

**引入头文件目录到子工程**，



## find_library和findpath

- find_library 用于查找动态/静态库

  ```
  find_library(libvar mylib.so ./libs)
  add_executable(test test.cpp)
  target_link_libraries(test ${libvar})
  ```

- find_path 用于查找头文件

## add_subdirectory

add_subdirectory是Cmake命令中用于添加一个子目录并构建该子目录的函数，可以指定source_dir、binary_dir和EXCLUDE_FROM_ALL三个参数。

## set_target_properties

**用法：**set_target_properties(hello PROPERTIES ***)

**常用属性：**

- 设置输出目录

- 指定引用库：imported_location

  ```
  add_library(mylib SHARED mylib.cpp)
  set_target_properties(mylib PROPERTIES 
  					IMPORTED_LOCATION "path/mylib.so")
  					
  ```

  使用`add_library`创建了一个名为mylib的共享库，然后使用set_target_properties指定其IMPORTED_LOCATION属性，将其设置为"path/mylib.so"的位置。

  这样在cmake构建的过程中，就可以把这个路径作为mylib库的位置，以便进行链接。

  后面调用时，直接：

  ```
  target_link_libraries(${PROJECT_NAME} mylib)
  ```




## `CMAKE_CXX_FLAGS` 和 `add_compile_definitions`对比

在 CMake 中，`CMAKE_CXX_FLAGS` 和 `add_compile_definitions` 虽然都影响编译过程，但它们的用途、作用范围和语法有本质区别。以下是详细对比：

---

### **核心区别**
| **特性**            | `CMAKE_CXX_FLAGS`                                 | `add_compile_definitions`                            |
| ------------------- | ------------------------------------------------- | ---------------------------------------------------- |
| **用途**            | 设置 C++ 编译器的全局选项（如优化、警告）         | 添加全局预处理器宏定义（如 `-DXXX`）                 |
| **语法示例**        | `-O2`, `-Wall`, `-std=c++17`                      | `MY_MACRO`, `VERSION=1.0`                            |
| **作用范围**        | 全局（影响所有 C++ 目标）                         | 全局或通过 `target_compile_definitions` 针对单个目标 |
| **是否跨平台友好**  | ❌ 需要手动处理不同编译器的选项差异                | ✅ 自动生成 `-D` 或 `/D`（如 MSVC）                   |
| **现代 CMake 推荐** | 尽量避免直接修改，优先用 `target_compile_options` | 推荐使用 `target_compile_definitions` 针对特定目标   |

---

### **详细解释**

#### 1. **`CMAKE_CXX_FLAGS`**
- **用途**：设置 C++ 编译器的全局选项，例如：
  - 优化选项（`-O2`）
  - 警告选项（`-Wall`）
  - 语言标准（`-std=c++17`）
  - 调试信息（`-g`）

- **语法**：直接修改 CMake 变量：
  ```cmake
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Wall")
  ```

- **问题**：
  - 全局生效，可能导致不同目标之间选项冲突。
  - 需要手动处理不同编译器的差异（例如 MSVC 使用 `/O2` 而不是 `-O2`）。
  - 不符合现代 CMake 的“目标级别”最佳实践。

---

#### 2. **`add_compile_definitions`**
- **用途**：添加预处理器宏定义（等价于 `-DMACRO` 或 `/D MACRO`），例如：
  - 定义开关宏（`DEBUG`）
  - 传递配置值（`VERSION=1.0`）

- **语法**：
  ```cmake
  add_compile_definitions(DEBUG VERSION=1.0)
  ```
  或针对特定目标：
  ```cmake
  target_compile_definitions(my_target PRIVATE DEBUG)
  ```

- **优点**：
  - 自动跨平台：CMake 会根据编译器自动生成 `-D` 或 `/D`。
  - 支持全局或目标级别的定义。
  - 更清晰地区分“编译选项”和“宏定义”。

---

### **使用场景对比**

#### 场景 1：定义预处理器宏
- **错误用法**（污染全局选项）：
  ```cmake
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDEBUG")  # 手动添加 -D
  ```
- **正确用法**：
  ```cmake
  add_compile_definitions(DEBUG)  # 自动处理为 -DDEBUG 或 /D DEBUG
  ```
  或针对特定目标：
  ```cmake
  target_compile_definitions(my_target PRIVATE DEBUG)
  ```

---

#### 场景 2：设置编译器选项
- **错误用法**（污染全局定义）：
  ```cmake
  add_compile_definitions(-O2)  # 错误！-O2 是编译选项，不是宏定义
  ```
- **正确用法**：
  ```cmake
  # 全局设置（不推荐）
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
  # 或目标级别设置（推荐）
  target_compile_options(my_target PRIVATE -O2)
  ```

---

### **跨平台差异处理**
- **`add_compile_definitions` 的自动转换**：
  - 在 GCC/Clang 中，`add_compile_definitions(DEBUG)` 生成 `-DDEBUG`。
  - 在 MSVC 中，生成 `/D DEBUG`。
  - 无需手动处理平台差异。

- **`CMAKE_CXX_FLAGS` 需手动处理平台差异**：
  ```cmake
  if (MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /O2")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
  endif()
  ```

---

### **现代 CMake 最佳实践**
1. **优先使用目标级别命令**：
   ```cmake
   add_executable(my_app main.cpp)
   # 目标级别的编译选项
   target_compile_options(my_app PRIVATE -Wall -Wextra)
   # 目标级别的宏定义
   target_compile_definitions(my_app PRIVATE DEBUG VERSION=1.0)
   ```

2. **避免全局修改 `CMAKE_CXX_FLAGS`**：  
   除非所有目标都需要相同的选项（例如强制 `-Wall`）。

3. **区分“选项”和“定义”**：
   - 选项（`target_compile_options`）：控制编译器行为（如优化、警告）。
   - 定义（`target_compile_definitions`）：控制代码逻辑（如 `#ifdef DEBUG`）。

---

### **总结**
| **场景**           | **工具选择**                                                 |
| ------------------ | ------------------------------------------------------------ |
| 添加预处理器宏定义 | `add_compile_definitions` 或 `target_compile_definitions`    |
| 设置编译器选项     | `target_compile_options`（优先目标级别）或谨慎使用 `CMAKE_CXX_FLAGS`（全局） |
| 跨平台兼容性       | `add_compile_definitions` 自动处理，`CMAKE_CXX_FLAGS` 需手动适配 |

始终优先使用目标级别命令（`target_*`），它们更灵活、更安全，也符合现代 CMake 的设计理念！



# Example

## 构建和链接静态库和动态库

1. 编写库文件和cmakelist，其中库文件要列出函数，cmake要将源文件编译为库

   ```cmake
   add_library(message STATIC
   			fun.cpp fun.h)
   ```

2. 编写主函数，调用这个库

   ```cmake
   #可执行文件的目标不需要修改
   add_executable(${PROJECT_NAME} main.cpp)
   ```

   然后需要将目标库（编译好的库）**链接**到可执行目标

   ```cmake
   target_link_libraries(${PROJECT_NAME} message)
   ```

## 构建自己的库，同时依赖于第三方库

1. 使用工具链构建第三方动态库

2. 在自己的库中，cmakelists

   ```cmake
   cmake_minimum_required(VERSION 3.0)
   project(slamAR)
   
   include_directories("/home/sophda/src/opencv-3.4.16/build/install/sdk/native/jni/include")
   
   link_directories("/home/sophda/src/opencv-3.4.16/build/install/sdk/native/libs/armeabi-v7a")
   
   add_library(${PROJECT_NAME} SHARED fun.cpp)
   target_link_libraries(${PROJECT_NAME} libopencv_core.so libopencv_imgproc.so libopencv_imgcodecs.so)
   ```

   - include_directories，**编译**的过程中可以找到对应的函数定义
   - link_directories，**添加库的搜索路径**，供链接时使用。只有添加了这个路径，才能够在**链接**阶段找到对应的库文件，要不然他妈去哪儿找？
   - add_library，选择库的**类型**，动态or静态，以及源文件
   - target_link_libraries，将用到的动态库**链接到目标target**，因为使用link_directories指定了库的路径，因此在这个目录下进行寻找。

## orbslam3 安卓端构建

### 设置abi以及platform

```
set(ANDROID_ABI "arm64-v8a" CACHE STRING "")
set(ANDROID_PLATFORM "19" CACHE STRING "")
```



### 头文件 include_directories

include_dirctories包含的文件夹，会在里面找头文件。

比如在orbslam3的`keyframe.h`里面有：

```
#include "Thirdparty/DBoW2/DBoW2/BowVector.h"
#include "Thirdparty/DBoW2/DBoW2/FeatureVector.h"
```

如果在cmake里面写：

```
include_directories(***/ThirdParty/DBoW2)
```

这样子是找不到的，因为这样会使得cmake去DBoW2中寻找`Thirdparty/DBoW2/DBoW2/FeatureVector.h`显然无法找到。

因此需要写成：

```
include_directories(***/ThirdParty)
```

**同理，如果头文件是**：

```
#include "BowVector.h"
#include "FeatureVector.h"
```

在cmake中写：

```
include_directories(***/ThirdParty)
```

这样子也是找不到的





### executorch

```
cmake -DCMAKE_TOOLCHAIN_FILE=/home/sophda/src/android-ndk-r25c/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a ..
```





# clang

```
set(CMAKE_C_COMPILER "clang")
set(CMAKE_CXX_COMPILER "clang++")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 14)

```

