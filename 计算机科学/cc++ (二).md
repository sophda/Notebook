# c/c++ (二)

> 来自b站视频

## 0.一些名词

内存：memory

指针：pointer

内存池：memory arena

智能指针：custom allocator

移动语义：move semantics

模板：template

## 1.link

程序生成需要“编译”和“链接”，编译是生成二进制机器码，而链接则是将编译后的obj文件链接起来称为可执行的。

```cpp
#include<iostream>
int multi()
{

}
int hello()
{

}
```

如果只对代码进行编译，则不会有任何问题。但是在build时会出现link的错误，因为没有程序入口，错误如`link1561`.

> 如果是cxxx的错误，则是编译错误，应检查语法

**链接与头文件：**

有三个文件

```cpp
// log.h
void log()
{
cout <<"" <<endl;
}
```

```cpp
// log.cpp
#include <log.h>
void initlog()
{
log();
}
```

```cpp
// main.cpp
#include<iostream>
#include<log.h>
int main()
{

}
```

在经过编译之后，生成的obj文件如下：

```c++
// log.obj
void log()
{
cout <<"" <<endl;
}
void initlog()
{
log();
}
```

```cpp
// main.obj
#include<iostream>
void log()
{
cout <<"" <<endl;
}
int main()
{

}
```

但是在main.obj和log.obj之后都有log函数，在link阶段会出现问题

**如何解决这个问题呢？**

1. 只需要修改log.h

```cpp
// log.h
static void log()
{
cout <<"" <<endl;
}
```

这样，log函数只在对应的obj文件内起作用。其他的obj文件是看不到的，最后链接的时候也就不会出问题。

2. 使用inline

> inline是把对应的函数替换为函数内的语句

```cpp
// log.h
inline void log()
{
cout <<"" <<endl;
}
```



## 2.head files

头文件保护符：

> 告诉编译器，这个头文件只被include一次

```
#pragma once
```

```
#ifdef
```

**<>和“”**

区别就是<>引用的是环境里的，而引号引用相对目录里的

```cpp
#include"iostream"
//这样引用的是cpp的标准库
//而c的标准库是带后缀.h的
//为了区别c和cpp 的标准库
```

## 3.指针

> 指针是一个整数，一个数字，存储着一个内存地址

> ```cpp
> int var = 10;
> void* ptr = &var;
> *ptr = 20;
> ```
>
> 这样是错的，因为ptr指向了一个内存地址，但是void形的，所以编译器不知道要向这个内存地址处写入多少字节的数据

## 4.reference

```
int main()
{
	int a = 5;
	int b = 8;
	int* ref = &a;
	ref = 
}
```



## 5.classes

> 类与结构体的区别：
>
> 1. 



1. 引用和类对象结合

   ```cpp
   class Player
   {
   public: 
   	int x,y;
   	int speed;
   };
   void move(Player& player,int x)
   {
   player.x = x;
   }
   ```

   这里move函数传入了类Player的对象的引用，相当于传入了一个实例化的player的别名（reference）