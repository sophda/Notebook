# OpenGL

## opengl简介

OpenGL是一套控制显卡的规范，没有具体的函数库。所以具体的函数实现主要是由gl、glu、glut这些库来实现

![image-20230523205435163](src/image-20230523205435163.png)

## 安装与测试

0. 可以使用apt-get

   ```
   sudo apt-get install libglew-dev
   sudo apt-get install libglm-dev
   sudo apt install libglfw3 libglfw3-dev
   ```

   

1. 在glfw官网下载zip格式的压缩包，然后解压编译

   ```
   cmake-gui
   (勾选构建动态库，即build_shared_lib)
   make
   sudo make install
   ```

2. 完成安装之后，会将动态库放到`usr/local/lib`中，因为在`etc/ld.so.conf`中已经添加了该路径，所以需要使用：

   ```
   sudo ldconfig
   ```

   使用这个命令更新以下，才能够找到这个动态库

3. 测试

   ```cpp
   #include <GLFW/glfw3.h>
   #include <stdio.h>
   
   int main(void)
   {
       GLFWwindow* window;
   
       /* Initialize the library */
       if (!glfwInit())
           return -1;
   
       /* Create a windowed mode window and its OpenGL context */
       window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
       if (!window)
       {
           glfwTerminate();
           return -1;
       }
   
       /* Make the window's context current */
       glfwMakeContextCurrent(window);
   
       /* Loop until the user closes the window */
       while (!glfwWindowShouldClose(window))
       {
           /* Render here */
           glClear(GL_COLOR_BUFFER_BIT);
   
           /* Swap front and back buffers */
           glfwSwapBuffers(window);
   
           /* Poll for and process events */
           glfwPollEvents();
       }
   
       glfwTerminate();
       return 0;
   }
   ```

   然后编译下：

   ```
   g++ -o main ./main.cpp -lglfw -lGL -lX11 -lm
   ```

   运行生成的main文件即可。

   ![image-20230523212003494](src/image-20230523212003494.png)

## 在arm板子上使用opengl

1. 安装

   ```
   sudo apt-get install libglew-dev
   sudo apt-get install libglm-dev
   sudo apt install libglfw3 libglfw3-dev
   ```

2. 使用cmakelist

   ```
   cmake_minimum_required(VERSION 3.10)
   project(opengl)
   set(CMAKE_CXX_STANDARD 14)
   find_package(glfw3 REQUIRED)
   #find_package(glm REQUIRED)
   add_executable(opengl main.cpp)
   target_link_libraries(${PROJECT_NAME}
           -lGLEW -lglfw -lGL -lX11 -lpthread -lXrandr -lXi -ldl)
   ```

   > 或者使用g++编译命令
   >
   > ```
   > g++ -o main ./main.cpp -lglfw -lGL -lX11 -lm
   > ```
   >
   > 可以看到库使用的是lglfw，并不是glfw3

# Learn OpenGL

## 三角形

[你好，三角形 - LearnOpenGL CN (learnopengl-cn.github.io)](https://learnopengl-cn.github.io/01 Getting started/04 Hello Triangle/)

> 在学习此节之前，建议将这三个单词先记下来：
>
> - 顶点数组对象：Vertex Array Object，VAO
> - 顶点缓冲对象：Vertex Buffer Object，VBO
> - 元素缓冲对象：Element Buffer Object，EBO 或 索引缓冲对象 Index Buffer Object，IBO

在OpenGL中，任何事物都在3D空间中，而屏幕和窗口却是2D像素数组，这导致OpenGL的大部分工作都是关于把3D坐标转变为适应你屏幕的2D像素。3D坐标转为2D坐标的处理过程是由OpenGL的图形渲染管线（Graphics Pipeline，大多译为管线，实际上指的是一堆原始图形数据途经一个输送管道，期间经过各种变化处理最终出现在屏幕的过程）管理的。图形渲染管线可以被划分为两个主要部分：第一部分把你的3D坐标转换为2D坐标，第二部分是把2D坐标转变为实际的有颜色的像素。

![img](src/pipeline.png)

1. 开始绘制图形之前，我们需要先给OpenGL输入一些顶点数据。OpenGL是一个3D图形库，所以在OpenGL中我们指定的所有坐标都是3D坐标（x、y和z）。定义这样的顶点数据以后，我们会把它作为输入发送给图形渲染管线的第一个处理阶段：顶点着色器。它会在GPU上创建内存用于储存我们的顶点数据，还要配置OpenGL如何解释这些内存，并且指定其如何发送给显卡。顶点着色器接着会处理我们在内存中指定数量的顶点。

**出现的bug：**

在编译后出现段错误，原因：是初始化失败了，如果你使用一个扩展加载器程序库（extension loader library）来访问现代[OpenGL](https://so.csdn.net/so/search?q=OpenGL&spm=1001.2101.3001.7020)，然后当需要初始化它时，加载器需要一个当前的上下文来加载。在调用glCreateShader先调用glewInit函数，代码如下：

```
GLenum glew_err = glewInit();
	if (glew_err != GLEW_OK)
	{
		throw std::runtime_error(std::string("Error initializing GLEW, error: ") + (const char*)glewGetErrorString(glew_err));
		return;
}
// Create and compile vertex shader
unsigned int vertex_shader = glCreateShader(GL_VERTEX_SHADER);

```

