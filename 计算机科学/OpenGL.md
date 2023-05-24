# OpenGL

## opengl简介

OpenGL是一套控制显卡的规范，没有具体的函数库。所以具体的函数实现主要是由gl、glu、glut这些库来实现

![image-20230523205435163](src/image-20230523205435163.png)

## 安装与测试

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