

> 来自b站视频，以及书，博客。尽量偏系统

# 类型及关键词

内存：memory

指针：pointer

内存池：memory arena

智能指针：custom allocator

移动语义：move semantics

模板：template

## int

## void *

## static

使用static来指定变量，那么这个变量在link的时候只对这个编译单元（obj）里的东西可见

## namespace

同名函数/类，要区分

```cpp
#include <iostream>
using namespace std;

// 第一个命名空间
namespace first_space{
   void func(){
      cout << "Inside first_space" << endl;
   }
}
// 第二个命名空间
namespace second_space{
   void func(){
      cout << "Inside second_space" << endl;
   }
}
int main ()
{

   // 调用第一个命名空间中的函数
   first_space::func();

   // 调用第二个命名空间中的函数
   second_space::func(); 

   return 0;
}
```

## malloc

返回的是void类型，需要进行类型转换



# 文件

## 文件写入

```c++
#include <fstream>
int main() {

    ofstream out;
    out.open("./text.txt");
    out << "123" <<  " "<< "hello" <<endl;
    out.close();
}
```















# 1.编译、链接

## 链接

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

## 库的头文件

在c++工程中，

- 含有main函数的可以生成一个可执行程序的

- 不含有main函数的，编译后被其他程序调用，可以将其打包为库

然后我们会发现，如果编译了opencv的库，不仅会生成系列的动态库，还有头文件，这些头文件的作用只是告诉你有哪些函数可以用，我们可以用`nm libxx.so`查看动态库中的函数，在编译时可以直接链接相应的库，~~没有头文件什么事情，因此头文件只是起到了提示的作用~~或者，换个**场景**：交叉编译的opencv库只需要把so库复制到开发板上就可以了，链接时只需要指定对应的动态库即可，**并不会出现没有头文件导致找不到动态库函数的情况**

在项目中，使用到了一个库的某个对象/函数，需要把这个库的头文件引入进来，这样才能在编译环节展开对应头文件然后找到对应使用的函数，最后才是链接到对应动态库上的函数。

# 2.head files

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

# 3.指针

## 定义

指针是一个整数，一个数字，存储着一个内存地址

> ```cpp
> int var = 10;
> void* ptr = &var;
> *ptr = 20;
> ```
>
> 这样是错的，因为ptr指向了一个内存地址，但是void形的，所以编译器不知道要向这个内存地址处写入多少字节的数据

## 指针声明

```
double dval; 
double *pd=&dval;
double*pd2=pd;
```

这段c++代码中，pd指什么？

> 这段代码中，pd是一个指向double类型的指针，它指向了dval的地址。也就是说，pd存储了dval的内存位置，你可以通过*pd来访问或修改dval的值。pd2也是一个指向double类型的指针，它被赋值为pd，所以它也指向了dval的地址。你可以通过*pd2来访问或修改dval的值。

**指针声明：**

```cpp
int ival = 1024;
int *p = &ival;
int **p = &p;
// int *p说明p是指针
```

## 数组与指针

```cpp
int ia[] = {0,1,2,3,4,5};
int *ip = ia;
// ip自动指向ia[0]


int *p2 = ip+4;
// p2指向4
```





## 智能指针

> 智能指针实际上是对传统指针的包装，当创建智能指针时，会调用new并分配内存。在不适用时会自动删除。
>
> 也就是避免了new和delete的过程

**1.unique_ptr:**

作用域指针，超出作用域时，会被销毁，然后调用delete

【**warning**】unique_ptr不能够复制，一旦复制，当一个指针被释放，另一个指针会指向被释放的内存。所以叫做unique指针~独一无二的哈~

> unique_ptr是一个显示转换，所以不能用`unique_ptr<Entity> entity=new Enitty()`这种隐式转换
>
> ![image-20230319225242197](src/image-20230319225242197.png)

```cpp
class Entity
{
public:
	Entity()
	{}
	~Entity()
	{}
}

int main()
{
	std::unique_ptr<Entity> entity(new Entity());
    // <>内的是模板参数
}
```

```cpp
int main()
{
	std::unique_ptr<Entity> entity = std::make_unique<Entity>();
	// c++14引入，这种构造方式更加安全，不会得到没引用的悬空指针，从而不会造成内存泄露
}
```

**2.shared_ptr**

通过引用计数，可以跟踪指针有多少引用，一旦引用计数为0，那么就被删除了

> 1. 在unique_ptr中，不直接调用new保证异常安全
> 2. 在shared_ptr中，需要分配另一块内存，叫做控制块，用来存储引用计数，可以用new

```cpp
int main()
{
	std::shared_ptr<Entity> sharedEntity = std::make_shared<Entity>();
	// OR:
	std::shared_ptr<Entity> sharedEntity1(new Entity())
        
    //此时shared_ptr也可以进行复制操作
    std::shared_ptr<Entity> e0 = sharedEntity;
}
```

```cpp
int main()
{
	{
	std::shared_ptr<Entity> e0;//执行完这句，创建了Entity类的空指针，没有执行构造函数
	{
	std::shared_ptr<Entity> sharedEntity = std::make_shared<Entity>();//执行这句，在堆上新建了Entity对象（执行构造函数），然后返回类的指针给sharedEntity
	e0 = sharedEntity; //将共享指针复制
	} //{}作用域内执行完毕，在{}的变量销毁，sharedEntity会被销毁，还保留e0，shared_ptr的引用数为1
	} //执行完后，e0被销毁，shared_ptr应用数为0，指针对象执行析构函数
}
```

[创建和使用shared_ptr的方法有以下几种](https://learn.microsoft.com/en-us/cpp/cpp/how-to-create-and-use-shared-ptr-instances?view=msvc-170)[1](https://learn.microsoft.com/en-us/cpp/cpp/how-to-create-and-use-shared-ptr-instances?view=msvc-170)[2](https://www.nextptr.com/tutorial/ta1358374985/shared_ptr-basics-and-internals-with-examples)[3](https://en.cppreference.com/w/cpp/memory/shared_ptr)：

- 使用make_shared函数创建shared_ptr。这种方法是异常安全的，它使用同一个调用来分配控制块和资源的内存，从而减少了构造开销。例如：`auto sp = make_shared<int>(42);`
- 使用new运算符创建shared_ptr。这种方法需要显式地指定要管理的对象类型，并且可能抛出异常。例如：`auto sp = shared_ptr<int>(new int(42));`
- 使用现有的shared_ptr或weak_ptr来初始化或赋值shared_ptr。这种方法会增加共享所有权的计数，并且可以实现别名构造，即让一个shared_ptr拥有另一个对象的所有权信息，但持有不相关的指针。例如：`auto sp1 = make_shared<int>(42); auto sp2 = sp1; auto sp3 = shared_ptr<int>(sp1, &x);`
- 使用unique_ptr或其他智能指针来初始化或赋值shared_ptr。这种方法会转移所有权，并且可以指定自定义删除器。例如：`auto up = unique_ptr<int>(new int(42)); auto sp = shared_ptr<int>(move(up));`

使用shared_ptr时，可以通过解引用运算符（*）或箭头运算符（->）来访问其所管理的对象，也可以通过get()函数来获取原始指针，或者通过use_count()函数来获取共享所有权的数量。



# 4.引用

```
int main()
{
	int a = 5;
	int b = 8;
	int* ref = &a;
	ref = 
}
```

c++中增加了一种**给函数传递地址的途径**，就是按引用传递，也存在于其他语言中

引用的本质是取别名

int &b = a; //给a取别名为b   &在左边为**取别名**，在右边为**地址**

**引用初始化之后不能改变**

**1.给数组取别名**

```c
int a[5] = [1,2,3,4,5];
int (&array) = a;  //给a取别名为array
//也可以：
int a[5] = [1,2,3,4,5];
typedef int ARR[5];
ARR & arr = a;
```

**2.函数引用**(通过传递引用，可以访问到参数的地址，进而改变调用函数的值)

```c
函数引用
void swap(int &x , int &y) //引用的方式 ，即int &x = a , int &y = b
{
    int tem = x;
    x = y;
    y = tmp;
}
void main()
{
    int a=10;
    int b=20;
    swap(x,y); //实现x，y的交换

}
// 通过引用改变了xy的
```

```c
函数引用返回：
int & test()
{
    static int b = 100;
    int a = 10;
    return a ; //是错误的  不能返回局部变量的应用
    return b； //可以返回静态的变量引用
}
```

**3.传递指向指针的引用**

```cpp
void ptrswap(int *&v1,int *&v2)
{
    int *tmp = v2;
    v2 = v1;
    v1 = tmp;
}
// 作用是使用“指向指针的引用”来交换两个指针
```

## 



# 6.函数

## 函数重载

函数的名字是可以重名的，也就是可以有多个相同函数名的函数存在，名字相同，意义不同

条件：

**1.参数个数不同  // 调用相应的函数**

**2.参数类型不同**

**3.参数顺序不同**

**// 函数返回值不能作为函数重载的条件**



## 函数传递vector

c++中常用的[vector](https://so.csdn.net/so/search?q=vector&spm=1001.2101.3001.7020)容器作为参数时，有三种传参方式，分别如下（为说明问题，用二维vector）：

- function1(std::vector<std::vector > vec)，传值
- **function2(std::vector<std::vector >& vec)，传引用**
- function3(std::vector<std::vector >* vec)，传指针

三种方式对应的调用形式分别为：

- function1(vec)，传入值
- **function2(vec)，传入引用**
- function3(&vec), 传入地址

> 1. 传入值是传入的形参，对实参本身不会造成影响
> 2. 传入引用是传入的变量的别名，可以改变原参数的值。与传值相比，可以节省开支
> 3. 传入指针：在函数内部的栈内可以直接修改原来的参数
>
> 传入参数要进行操作，所以一定要初始化

```cpp
#include <iostream>
#include <vector>

using namespace std;

void function1(std::vector<std::vector<int> > vec)
{
    cout<<"-----------------------------------------"<<endl;
    //打印vec的地址
    cout<<"function1.&vec:"<<&vec<<endl;
    //打印vec[i]的地址（即第一层vector的地址）
    cout<<"function1.&vec[i]:"<<endl;
    for(int i=0;i<2;i++)
        cout<<&vec[i]<<endl;
    //打印vec的各元素地址
    cout<<"function1.&vec[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<&vec[i][j]<<" ";
        cout<<endl;
    }
    cout<<"---------------------------"<<endl;
    //打印vec的各元素值
    cout<<"function1.vec[i][j]:"<<endl;
    vec[0][0] = 10000;//进行修改的
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<vec[i][j]<<" ";
        cout<<endl;
    }

}
void function2(std::vector<std::vector<int> >& vec)
{
    cout<<"-----------------------------------------"<<endl;
    //打印vec的地址
    cout<<"function2.&vec:"<<&vec<<endl;
    //打印vec[i]的地址（即第一层vector的地址）
    cout<<"function2.&vec[i]:"<<endl;
    for(int i=0;i<2;i++)
        cout<<&vec[i]<<endl;
    //打印vec的各元素地址
    cout<<"function2.&vec[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<&vec[i][j]<<" ";
        cout<<endl;
    }
    cout<<"---------------------------"<<endl;
    //打印vec的各元素值
    cout<<"function2.vec[i][j]:"<<endl;
    vec[0][0] = 10000;//进行修改的
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<vec[i][j]<<" ";
        cout<<endl;
    }

}
void function3(std::vector<std::vector<int> > *vec)
{
    cout<<"-----------------------------------------"<<endl;
    //打印vec的地址
    cout<<"function3.&vec:"<<vec<<endl;
    //打印vec[i]的地址（即第一层vector的地址）
    cout<<"function3.&vec[i]:"<<endl;
    for(int i=0;i<2;i++)
        cout<<&(*vec)[i]<<endl;
    //打印vec的各元素地址
    cout<<"function3.&vec[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<&(*vec)[i][j]<<" ";
        cout<<endl;
    }
    cout<<"---------------------------"<<endl;
    //打印vec的各元素值
    cout<<"function3.vec[i][j]:"<<endl;
    (*vec)[0][0] = 10000;//进行修改的
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<(*vec)[i][j]<<" ";
        cout<<endl;
    }
}

int main()
{
    //创建2*3的vector容器v,初始值均初始化为0 1 2 1 2 3
    std::vector<std::vector<int> > v(2,std::vector<int>(3,0));
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            v[i][j]=i+j;
    }

    //打印v的地址
    cout<<"&v:"<<&v<<endl;
    //打印v[i]的地址（即第一层vector的地址）
    cout<<"&v[i]:"<<endl;
    for(int i=0;i<2;i++)
        cout<<&v[i]<<endl;
    //打印v的各元素地址
    cout<<"&v[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<&v[i][j]<<" ";
        cout<<endl;
    }

    cout<<"---------------------------"<<endl;
    //打印v的各元素值
    cout<<"v[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<v[i][j]<<" ";
        cout<<endl;
    }

    function1(v);

    cout<<"---------------------------"<<endl;
    //打印v的各元素值
    cout<<"v[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<v[i][j]<<" ";
        cout<<endl;
    }


    function2(v);

    cout<<"---------------------------"<<endl;
    //打印v的各元素值
    cout<<"v[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<v[i][j]<<" ";
        cout<<endl;
    }

    function3(&v);
    cout<<"---------------------------"<<endl;
    //打印v的各元素值
    cout<<"v[i][j]:"<<endl;
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<3;j++)
            cout<<v[i][j]<<" ";
        cout<<endl;
    }

    return 0;
}


```

## 内联函数

```c
inline int add(int a,int b)
{
    return a+b;
}
//定义内联函数
void main()
{
    int a=5,b=5;
    c = add(a,b)*5; //替换发生在编译阶段
}
内联函数省去了函数调用时的压栈，跳转，返回的开销
可以理解为用空间换时间
```

## 

# 7.类

## 定义

> 类与结构体的区别：
>
> 类可以指定成员是否可以被访问
>
> 使用public、private等关键词

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

   **这里move函数传入了类Player的对象的引用**，相当于传入了一个实例化的player的别名（reference）

```cpp
class Entity
{
public:
	void move();
}
class player : public Entity
{
public: 
	int x;
	
}
int main()
{
	Player player;
	player.move();
	player.x = 5;
}

// player对象继承了父类entity的所有内容
```



## NEW

new其实就是告诉计算机开辟一段新的空间，但是和一般的声明不同的是，**new开辟的空间在堆上，而一般声明的变量存放在栈上**。通常来说，当在局部函数中new出一段新的空间，该段空间在局部函数调用结束后仍然能够使用，可以用来向主函数传递参数。另外需要注意的是，**new的使用格式，new出来的是一段空间的首地址**。

```cpp
因为new出来的时首地址，所以一般搭配着指针使用：
Person* pp1( new Person{30,40} );
///////////////////////////
pcl::PointCloud<pcl::PointXYZRGB>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZRGB>);
```

使用`new`关键字来初始化对象：

1.类对象指针

```cpp
Person* pp1( new Person{30,40} );
// 此时pp1是指向类对象的一个指针
pp1->age;
(*pp1).age;
//可用这两种方法来查看类成员变量；
```

2.常规初始化

```cpp
Person pp1 = new Person{30,40};
// Person pp1( new Person{30,40} )；这样是错误的写法
```

> new 关键词返回指针！！！

```cpp
class Entity
{
public:
	Entity()
	{}
}

int main()
{
	Entity* entity = new Entity();
	// 这句话会执行类的初始化
    Entity* b = (Entity*)malloc(sizeof(Entity))
    // 仅仅申请Entity大小的空间，b指向这段空间。没有初始化过程
}
            
```



## ：：

双冒号 :: 操作符被称为域操作符(scope operator)，含义和用法如下：

- 在类外部声明成员函数。void
  Point::Area(){};

- 调用全局函数；表示引用成员函数变量及作用域，作用域成员运算符
  例：System::Math::Sqrt() 相当于System.Math.Sqrt()。

- 调用类的静态方法：
  如：CDisplay::display()。
  把域看作是一个可视窗口全局域的对象在它被定义的整个文件里，一直到文件末尾都是可见的。在一个函数内被定义的对象是局域的（local scope），
  它只在定义其的函数体内可见。每个类维持一个域，在这个域之外 ，它的成员是不可见的。类域操作符告诉编译器后面的标识符可在该类的范围内被找到。

**2 类的初始化，非静态成员的初始化**

与类同名的函数是构造函数，用于初始化类

```cpp
class     Person 
{
public:
    void showw();
    int num;
    int num2;
    Person(int num1, int num2)
        :num{ 1 }, num2{3}
    {
        //类的初始化
    }
};
```

```cpp
#include<iostream>
using namespace std;
class Person
{
    public :
        void showw()
            {}
        int num;
        int num2;
        Person (int x,int y)
            :num{x},num2{y}
            {
                //类的初始化，在初始化时进行
                cout <<"初始化成功"<<endl;
                cout << num <<" "<< num2 <<endl;
            }
}


int main()
{
    Person p1{1,2}
}
```

![](src/2023-02-14-02-23-06-image.png)

**3  委托函数**

使用函数重载，参数不同进行委托，不同的参数使用不同函数进行初始化

```cpp
#include<iostream>
using namespace std;
class    Person 
{
public:
        void showw()
        {
        }
        int num;
        int num2;
        Person(int x)
                :Person {20, 10}  //委托函数
        {
                //函数重载，一个参数
        }
        Person(int x, int y)
                :num{ x}, num2{y}
        {
                //类的初始化,初始化时执行
                cout << "初始化成功" << endl;
                cout << num <<"    "<< num2 << endl;
        }
};
int main()
{
        Person  p1{50,60}; //初始化类
        Person p2{2};  //调用委托函数
}
```

**4 析构函数**

**析构函数**是另一个特殊的类的成员函数的时那个类的一个对象被销毁时执行。构造函数旨在初始化类，而析构函数旨在帮助清除

> 当对象正常超出范围，或使用delete关键字显式删除动态分配的对象时，将自动调用类析构函数（如果存在）以进行必要的清理，然后将其从内存中删除。对于简单的类（那些仅初始化普通成员变量的值的类），不需要析构函数，因为C ++会自动为您清除内存。

**析构函数命名**

像构造函数一样，析构函数具有特定的命名规则：

1）析构函数必须与类具有相同的名称，后跟波浪号（〜）。

2）析构函数不能接受参数。

3）析构函数没有返回类型。

请注意，规则2暗示每个类只能存在一个析构函数，因为无法重载析构函数，因为无法根据参数将它们彼此区分开。

```cpp
#include<iostream>
using namespace std;
class    Person 
{
public:
        void showw()
        {
                cout << num << "  -showw-   " << num2 << endl;
        }
        int num;
        int num2;
        Person(int x)
                :Person {20, 10}  //委托函数
        {
                //函数重载，一个参数
        }
        Person(int x, int y)
                :num{ x}, num2{y}
        {
                //类的初始化,初始化时执行
                cout << "初始化成功" << endl;
                cout << num <<"    "<< num2 << endl;
        }
        ~Person()
        {
                cout << "删除对象" << endl;
        }
};
int main()
{
        Person* pp1{ new Person{30,40} }; //新建了一个指针
        pp1->showw(); //指针通过该方式调用类方法
        delete pp1; //删除时调用析构函数

}
```

![](src/2023-02-14-02-27-00-image.png)

##  this

新的面向对象的程序员经常问的关于类的问题之一是：“当调用成员函数时，C ++如何跟踪它在哪个对象上被调用？”。答案是C ++使用了一个名为“ this”的隐藏指针！让我们更详细地看一下“ this”。

放在一起：

1）当我们调用时simple.setID(2)，**编译器实际上会调用setID（＆simple，2）。**

2）在setID（）中，“ this”指针将对象的地址保持为简单。

3）setID（）中的任何成员变量都以“ this->”为前缀。因此，当我们说时m_id = id，编译器实际上正在执行this->m_id = id，在这种情况下，它将simple.m_id更新为id。

4)类方法setID（）定义时：

```cpp
void setID(Simple* const this, int id) { this->m_id = id; }
```

好消息是，所有这些操作都是自动发生的，而您是否记得它是如何工作的，这并不重要。您需要记住的是，所有普通成员函数都有一个“ this”指针，该指针指向调用该函数的对象。

显示使用this：

首先，如果您的构造函数（或成员函数）具有与成员变量同名的参数，则可以使用“this”消除它们的歧义:

```cpp
class Something
{
private:
    int data;

public:
    Something(int data)
    {
        this->data = data; // this->data is the member, data is the local parameter
    }
};
```

![](src/2023-02-14-02-30-06-image.png)

**6 链接成员函数**

```cpp
class Calc
{
private:
    int m_value{};

public:
    Calc& add(int value) { m_value += value; return *this; }
    Calc& sub(int value) { m_value -= value; return *this; }
    Calc& mult(int value) { m_value *= value; return *this; }

    int getValue() { return m_value; }
};
```

每个函数都返回 *this，即该对象的指针





## 友元类

对于一个没有定义public访问权限的**类**，能够让其他的类操作他的私有变量。

```
class Node
{
	private :
		int data;
		int key;
	friend class BinaryTree;
}

class BinaryTree
{
	private :
	    Node *node;
}

int main()
{
    BinaryTree tree;
    tree.node->key ....;
}


```



## 一个类包含另一个类的初始化

```cpp
#include<iostream>
using namespace std;
class A
{
public:
	A()
	{
		cout << "A is constructed!" << endl;
	}
};
class B
{
private:
	A a;
public:
	B()
	{
		a = A();
		cout << "B is constructed!" << endl;
	}
};
int main()
{
	B b = B{};
 
	system("pause");
}
```

这时候，A一共初始化了两次，1、b在确立时a进行了初始化，2、b在执行初始化时A有进行了初始化

**为了避免重复初始化消耗内存，如何才能让a只初始化一次呢？**

可以用指针来解决：

```cpp
#include<iostream>
using namespace std;
class A
{
public:
	A()
	{
		cout << "A is constructed!" << endl;
	}
};
class B
{
private:
	A *a;
public:
	B()
	{
		a = new A();
		cout << "B is constructed!" << endl;
	}
	~B()
	{
		delete a;
	}
};
int main()
{
	B b = B{};
	system("pause");
}
```

b在构造时，只是创造了个A类型的空指针，在执行构造函数，即b初始化时，会把A类型的空指针指向new出来的A（）对象，也就是A初始化了一次。

【**总结**】**：一个类包含另外一个类，在声明类成员变量时，声明一个指针，然后在构造函数中，或其他类成员函数中将指针指向具体的对象。**欧耶~







# 8.虚函数与内存模型

## 虚函数

1. 例子

```cpp
#include<iostream>
#include<string>
using namespace std;
class Entity
{
public:
	std::string GetName(){ reuturn "Entity"; }
};
class Player : public Entity
{
private :
	std::string m_Name;
public:
	Player(const std::string& name)
	:m_Name(name){}
	std::string GetName(){ return  m_Name;}
}

int main()
{
	Entity* e = new Entity();
    // 这里是一个对象指针
	std::cout<<e->GetName() <<std::endl;
	
	Player* p = new Player("hello");
	std::cout << p->GetName() << std::endl;
	
}
// 此时会正常输出
```

```cpp
// 但是当把main函数改为
int main()
{
	Entity* e = new Entity();
	//std::cout<<e->GetName() <<std::endl;
	
	Player* p = new Player("hello");
	//std::cout << p->GetName() << std::endl;
	
	Entity* entity = p;
	cout<<entity->GetName()<<endl;
	
}
// 此时会输出entity
```

```cpp
void printName(Entity* entity)
{
	cout<< entity->GetName() <<endl;
}

// 但是当把main函数改为
int main()
{
	Entity* e = new Entity();
	printName(e);
	
	Player* p = new Player("hello");
	printName(p);
//按道理来说，printName(e);会打印entity
// printname(p)会打印hello
//  但是printName()这个函数入口的是 entity类的，所以会访问
//entity的方法，不会访问player的
}

```

但是！！ 改写了root类之后：

```cpp
#include<iostream>
#include<string>
using namespace std;
class Entity
{
public:
	virtual std::string GetName(){ reuturn "Entity"; }
};
class Player : public Entity
{
private :
	std::string m_Name;
public:
	Player(const std::string& name)
	:m_Name(name){}
	std::string GetName(){ return  m_Name;}
}
```

此时：

```cpp
void printName(Entity* entity)
{
	cout<< entity->GetName() <<endl;
}

// 但是当把main函数改为
int main()
{
	Entity* e = new Entity();
	printName(e);
	
	Player* p = new Player("hello");
	printName(p);
// 因为root类实用virtual,所以子类会对GetName()方法进行改  // 写。printName(e)会打印entity
// printname(p)会打印hello

}
```

**纯虚函数：**

```cpp
class Entity
{
public:
	virtual std::string GetName()=0;
}
// 令这个函数为零，则必须在子类里定义，否则子类将无法被实例化
//
Entity *e = new Entity();
// 也是错误的，因为GetName么有定义

```

2. **纯虚函数是为了多态而生，可以实现子类在继承的时候为虚函数创建虚函数表，进而实现即使强制转换，调用虚函数也会不同情况。**

   > 回调：把函数作为变量，进行调用

   那上面的例子来说，在基类entity中定义了函数getname，如果不定义为虚函数，那么子类player继承后，需要进行重写（or覆盖）才能够调用这个函数，并且在`Entity* entity = player`强制转换类型后，子类定义的函数也将无法使用。

3. 纯虚函数的实现

   ```c++
   // 1段
   class IRunner {
   private:
   	size_t a;
   public:
   	IRunner()
   		: a(0){
   	}
   	virtual void run() = 0;
   };
   
   class ISpeaker{
   protected:
   	size_t b;
   public:
   	ISpeaker( size_t _v )
   		: b(_v) 
   	{}
   	virtual void speak() = 0;
   };
   
   class Dog : public ISpeaker {
   public:
   	Dog()
   		: ISpeaker(1)
   	{}
   	//
   	virtual void speak() override {
   		printf("woof! %llu\n", b);
   	}
   };
   
   class RunnerDog : public IRunner, public Dog {
   public:
   	RunnerDog()
   	{}
   
   	virtual void run() override {
   		printf("run with 4 legs\n");
   	}
   };
   
   int main( int argc, char** _argv ) {
   	RunnerDog* pDog = new RunnerDog();
   	Dog* simpleDog = new Dog();
   	pDog->speak();
   	{ // 等价于
   		ISpeaker* speaker1 = static_cast<ISpeaker*>(pDog);
   		speaker1->speak();
   	}
   
   	ISpeaker* speaker = static_cast<ISpeaker*>( simpleDog );	
   	RunnerDog* runnerDog = dynamic_cast<RunnerDog*>(speaker);
   	// RTTI 信息
   	if(runnerDog){
   		runnerDog->run();
   	}
   	//
   	// 子类 -> 基类 （ static_cast<>() ）
   	// 基类 -> 子类 （ dynamic_cast<>() ）
   	// 有可能变化
   	// RunnerDog* runnerDog = (RunnerDog*)(speaker);
    	return 0;
   }
   ```

   ```c++
   // 2段
   extern "C" {
   
   	#define RTTI_INFORMATION
   
   	struct RunnerTable {
   		RTTI_INFORMATION
   		void(* run)(void* _ptr);
   	};
   
   	struct SpeakerTable {
   		RTTI_INFORMATION
   		void(* speak )( void* _ptr );
   	};
   
   	void __dog_run( void* _ptr ) {
   		printf("run with 4 legs");
   	}
   
   	void __dog_speak( void* _ptr ) {
   		uint8_t* p = (uint8_t*)_ptr;
   		p+=sizeof(SpeakerTable*);
   		size_t b = *((size_t*)p);
   		printf("woof! %llu\n", b);
   	}
   
   	const static RunnerTable __dogRunnerTable = {
   		RTTI_INFORMATION
   		__dog_run
   	};
   
   	const static SpeakerTable __dogSpeakTable = {
   		RTTI_INFORMATION
   		__dog_speak
   	};
   
   	struct __dog {
   		const SpeakerTable* vt;
   		size_t b;
   	};
   
   	struct __runner_dog {
   		const RunnerTable* vt1;
   		size_t a;
   		const SpeakerTable* vt2;
   		size_t b;
   	};
   
   	__dog * createDog() {
   		__dog* ptr = (__dog*)malloc(sizeof(__dog));
   		ptr->vt = &__dogSpeakTable;
   		ptr->b = 0;
   		return ptr;
   	}
   
   	__runner_dog* createRunnerDog() {
   		__runner_dog* ptr = (__runner_dog*)malloc(sizeof(__runner_dog));
   		ptr->vt1 = &__dogRunnerTable;
   		ptr->a = 0;
   		ptr->vt2 = &__dogSpeakTable;
   		ptr->b = 1;
   		return ptr;
   	}
   
   };
   
   int main( int _argc, char** _argv ) {
       __dog* dog = createDog();
   	__runner_dog* runnerDog = createRunnerDog();
   
   	SpeakerTable** speaker = nullptr;{
   		uint8_t* ptr = (uint8_t*)runnerDog;
   		union {
   			const SpeakerTable* __runner_dog::* memOffset;
   			size_t offset;
   		} u;
   		u.memOffset = &__runner_dog::vt2;
   		ptr += u.offset;
   		speaker = (SpeakerTable**)ptr;
   	}
   	(*speaker)->speak(speaker);
   	// 等价于
   	runnerDog->vt2->speak(speaker);
   	// 但不等价于
   	runnerDog->vt2->speak(runnerDog); // 这是错误的
   	//
   	return 0;
   }
   ```

   1段展示了纯虚函数的应用，2段则表示了纯虚函数的实现。

   - 如果一个基类中，有纯虚函数的定义，那么该基类的内存模型中，首先是虚函数表，然后是其他变量
   - 有个子类对基类进行了继承，则需要对虚函数进行定义，这时会给子类也分配一个**虚函数表**，该虚函数表指针指向该子类的函数定义，本质上是回调。
   - 对子类强转为基类指针，虚函数表并不会被修改，此时会出现：调用基类的函数，会出现不同情况

## 内存模型

> ref:[C++语言中的类在内存中的分布是怎样的？也是内存对齐的吗？对象的虚表指针存放在哪里？C++中类的内存模型，在内存中是如何存储的？虚函数是如何存储的 - 刘冲的博客 (popkx.com)](https://blog.popkx.com/what-is-the-memory-model-of-class-in-c-where-is-the-virtual-pointer/)

众所周知，但是我忘了。。

- char类型占用1个字节，即1b，1b=8bit
- int类型占用4个字节
- double占用8个字节
- 指针的大小为：$2^{电脑位数}$

1. 空类

   ```c++
   class A {
   };
   cout << sizeof(A) << endl; // 输出 1
   ```

2. 类型的成员变量

   ```c++
   class A {
   public:
       int pub_i1;
       int pub_i2;
   };
   A a;
   ```

   此时a的大小为8字节，即两个int相加

   ![image-20230801084432660](src/image-20230801084432660.png)

3. 类的成员函数

   ```c++
   class A {
   public:
       int pub_i1;
       int pub_i2;
   
       void pub_foo1() {}
       void pub_foo2() {}
   };
   
   A a;
   cout << "sizeof A: " << sizeof(A) << endl;
   cout << "a addr: " << &a << endl;
   cout << "A::pub_i1 addr: " << &a.pub_i1 << endl;
   cout << "A::pub_i2 addr: " << &a.pub_i2 << endl;
   
   printf("A::pub_foo1() addr: %p\n", (void *)&A::pub_foo1);
   printf("A::pub_foo2() addr: %p\n", (void *)&A::pub_foo2);
   ```

   此时输出为：

   ```
   sizeof A: 8
   a addr: 0x7ffe2dbc3120
   A::pub_i1 addr: 0x7ffe2dbc3128
   A::pub_i2 addr: 0x7ffe2dbc312c
   A::pub_foo1() addr: 0x400b28
   A::pub_foo2() addr: 0x400bc2
   ```

   根据a的大小可以看到，成员函数并没有加入到A类中，而是被分配到了很远的地方。

   ![image-20230801084735972](src/image-20230801084735972.png)

4. 类的私有成员

   ```c++
   class A {
   ...
   private:
       int prv_i1;
       int prv_i2;
   
       void pub_foo1() {
           cout << "A::prv_i1 addr: " << &prv_i1 << endl;
           cout << "A::prv_i2 addr: " << &prv_i2 << endl;
   
           printf("A::prv_foo1() addr: %p\n", (void *)&A::prv_foo1);
           printf("A::prv_foo2() addr: %p\n", (void *)&A::prv_foo2);
       }
       void prv_foo2() {}
   };
   ...
   a.pub_foo1();
   ```

   输出为：

   ```
   sizeof A: 16
   a addr: 0x7ffdbbfe6980
   A::pub_i1 addr: 0x7ffdbbfe6980
   A::pub_i2 addr: 0x7ffdbbfe6984
   A::pub_foo1() addr: 0x400ace
   A::pub_foo2() addr: 0x400bb0
   A::prv_i1 addr: 0x7ffdbbfe6988
   A::prv_i2 addr: 0x7ffdbbfe698c
   A::prv_foo1() addr: 0x400bba
   A::prv_foo2() addr: 0x400bc4
   ```

   可以看到：private类并没有特别之处，变量也是存储到对象内存中的。私有函数也是独立于对象a存储的。重点是非虚函数

   ![image-20230801084956653](src/image-20230801084956653.png)

5. 虚函数

   ```c++
   class A {
   public:
       ...
       void pub_foo2() {}
       virtual void pub_vfoo1() {}
       virtual void pub_vfoo2() {}
   private:
       ...
   };
   ...
   printf("A::pub_vfoo1() addr: %p\n", (void *)&A::pub_vfoo1);
   printf("A::pub_vfoo2() addr: %p\n", (void *)&A::pub_vfoo2);
   
   a.pub_foo1();
   ```

   输出为：

   ```
   sizeof A: 24
   a addr: 0x7fffb26a22a0
   A::pub_i1 addr: 0x7fffb26a22a8
   A::pub_i2 addr: 0x7fffb26a22ac
   A::pub_foo1() addr: 0x400b28
   A::pub_foo2() addr: 0x400bc2
   A::pub_vfoo1() addr: 0x400bcc
   A::pub_vfoo2() addr: 0x400bd6
   A::prv_i1 addr: 0x7fffb26a22b0
   A::prv_i2 addr: 0x7fffb26a22b4
   A::prv_foo1() addr: 0x400be0
   A::prv_foo2() addr: 0x400bea
   ```

   可以看到：2个虚函数增加了1个指针的大小（指针指向内存地址，在这里是64为机器位数，占用内存空间即2^64=8byte）。也就是说，**这个指针即虚函数表的地址**，这个地址指向的内存表空间中存储着两个虚函数。

   ![image-20230801085854130](src/image-20230801085854130.png)

根据内存地址，就可以解释：

```c++
class Entity{
public:
    Entity();
    int a;
    void getname()
    {
        cout<< "Entity" <<endl;
    }
};
class Player : public Entity{
public:
    Player();
    int b;
    void getname()
    {
        cout<< "player" <<endl;
    }
};
int main() {
    Player* p = new Player();
    Entity* e = new Entity();
    Entity* entity = dynamic_cast<Entity* >(p);
    entity->getname();
}
```

上面这一段输出的是Entity，因为getname不是虚函数，基类定义了该函数的地址，在进行类型转换`Entity* entity = dynamic_cast<Entity* >(p);`的时候，getname的地址是Entity类的，所以会输出“Entity”

---

```c++
class Entity{
public:
    Entity();
    int a;
    virtual void getname()
    {
        cout<< "Entity" <<endl;
    }
};
class Player : public Entity{
public:
    Player();
    int b;
    void getname()
    {
        cout<< "player" <<endl;
    }
};
int main() {
    Player* p = new Player();
    Entity* e = new Entity();
    Entity* entity = dynamic_cast<Entity* >(p);
    entity->getname();
}
```

上面这一种情况，因为基类包含virtual函数，则会有个虚函数表指针（大小为指针大小）。子类是继承的，所以也有。在执行`Entity* entity = dynamic_cast<Entity* >(p);`时，基类的虚函数表指针是在内存中的，属于类的成员变量，那么基类的虚函数表指针也会被赋值为子类的虚函数表指针，这时，就会执行子类的函数。进而输出“”

# 9.初始化 ：

```cpp
class example
{
private:
	int x,y,z;
	std::string m_Name;
public:
	example()
		// 这是初始化的操作
		:x(0),y(0),z(0),m_Name("hello")
		{
		
		}
}
```

但是，但我们将初始化不用：表示时，

```cpp
class example
{
private:
	int x,y,z;
	std::string m_Name;
	// 在这里构造了一次
public:
	example()
		// 这是初始化的操作
		:x(0),y(0),z(0)
		{
		m_Name = "hello";
		//不用：进行初始化，这里会把上面初始化的删除，
		// 然后再用“hello”覆盖掉上面的
		// 所以是构造了两次，浪费了性能
		}
}
```




# 隐式转换

```cpp
class Entity
{
public:
	int m_age;
	Entity(int age)
		:m_age(age)
		{}
}

int main()
{
	Entity a = 22;
	// 此时会发生隐式转换
	Entity b(20);
	// 这样是显式转换
}
```

但是，如果在构造函数前放一个`explicit`关键词，那么隐式转换`implicit`就会被屏蔽，从而使用显式的构造函数

```
class Entity
{
public:
	int m_age;
	explicit Entity(int age)
		:m_age(age)
		{}
}

int main()
{
	Entity a = 22; //error
	// 此时隐式转换会错误
	
	Entity b(20);
	// 只能用显式转换
	Entity b = Entity(20);
	// 这样也可以
}
```



# 堆和栈(包含隐式转换的解释)

1. 栈的作用域：{}，所以一旦离开了栈的作用域，作用域内的内容会消失

2. 使用new关键词新建的内容是在**堆**上，所以即使是离开{}的作用域，指针也会继续存在 

**作用域指针(类)：**

> 这一类指针同样在**作用域内生效**，尽管使用new申请了堆上的内存，**但是离开作用域时，对象也会析构** 
>
> **这就是智能指针哦**

> ScopedPtr是一个智能指针，它包装了new操作符在堆上分配的动态对象，能够保证动态创建的对象在任何时候都可以被正确地删除。它与auto_ptr/unique_ptr类似，但是它不能被复制或赋值给其他指针
>
> e是一个ScopedPtr类型的变量，它指向一个Entity类的对象。当e离开作用域时（即大括号结束时），它会自动调用析构函数来删除指向的Entity对象。

> ScopedPtr e = new Entity(); 这段话会执行以下步骤：（**发生隐式转换**，new返回指针，然后赋值给m_Ptr）
>
> 1. 使用new表达式在堆上分配一个Entity类的对象，并返回一个指向它的指针。
> 2. 调用ScopedPtr的构造函数，将这个指针作为参数传递，并将它赋值给m_Ptr成员变量。
> 3. 创建一个ScopedPtr类型的变量e，它包装了这个指针，并管理它的生命周期

```cpp
class ScopedPtr
{
private:
	Enitty* m_Ptr;
public:
	ScopedPtr(Entity* ptr)
		:m_Ptr(ptr)
		{}
	~ScopedPtr()
	{
        delete m_Ptr;
    }
};

int main()
{
	{
	ScopedPtr e = new Entity();
	}
}
```





# 模板

模板是让编译器为你写代码。避免手动重载

## 函数模板

只有在调用模板的时候，模板才会被创建。如果模板函数内存在错误，是可以正常编译的。

```c++
template<typename T>
void Print(T value)
{
	std::cout<< value <<std::endl;
}
// 下面这种情况是隐式地调用了模板,可以推断是什么类型的
Print("hello");
Print(5.5f);
//下面则是显式地调用
Print<int>(5);
```



## 类模板

```c++
template<int N>
class Array
{
private :
	int array[N];
public :
	int GetSize() const {return N;}
}
void main()
{
	Array<5> array;
	std<<cout<<array.GetSize();
}
//输出为5
```

```C++
template<typename T,int N>
class Array
{
private :
	T array[N];
public :
	int GetSize() const {return N;}
}
void main()
{
	Array<std::string,5> array;
	std<<cout<<array.GetSize();
}
//输出为5
```



# auto关键词

# 线程

## 定义

在一个程序中，这些独立运行的程序片段叫作“线程”（Thread）

- 一个程序有且只有一个进程，按时可以有多个线程
- 不同的进程有不同的地址空间，互不相关。但是不同的线程有共同进程的地址空间
- 在c中有pthread的库进行多线程编程。但是在c++ 11中出现了std::thread的东西，所以在使用了这个threa的有的库的编译选项不用选择ptread

**基础使用：**

```c++
// Compiler: MSVC 19.29.30038.1
// C++ Standard: C++17
#include <iostream>
#include <thread>
using namespace std;
void doit() { cout << "World!" << endl; }
int main() {
	// 这里的线程a使用了 C++11标准新增的lambda函数
	// 有关lambda的语法，请参考我之前的一篇博客
	// https://blog.csdn.net/sjc_0910/article/details/109230162
	thread a([]{
		cout << "Hello, " << flush;
	}), b(doit);
	a.join();
	b.join();
	return 0;
}

```

**注意事项：**

- 线程是thread对象被定义的时候就会执行，而不是join函数才执行的，调用join函数只是阻塞等待线程结束并回收资源
- 分离的线程（执行过detach的线程）会在调用它的线程结束或自己结束时释放资源
- 线程会在函数运行完毕后自动释放

## std::atomic和std::mutex

多个线程进行时，如果操作同一个变量，那么肯定会出错，所以出现了这两个东西。

**std::mutex**

```c++
// Compiler: MSVC 19.29.30038.1
// C++ Standard: C++17
#include <iostream>
#include <thread>
#include <mutex>
using namespace std;
int n = 0;
mutex mtx;
void count10000() {
	for (int i = 1; i <= 10000; i++) {
		mtx.lock();
		n++;
		mtx.unlock();
	}
}
int main() {
	thread th[100];
	for (thread &x : th)
		x = thread(count10000);
	for (thread &x : th)
		x.join();
	cout << n << endl;
	return 0;
}

```

如上，100个线程同时操作同一个全局变量n，在每个线程中会将mutex锁住，其他线程都不能执行，所以只有一个线程在执行n的加法。

mutex实例化的对象成员函数：

|      函数       |                             作用                             |
| :-------------: | :----------------------------------------------------------: |
|   void lock()   | 将mutex上锁。如果mutex已经被其它线程上锁，那么会阻塞，直到解锁；如果mutex已经被同一个线程锁住，那么会产生死锁。 |
|  void unlock()  | 解锁mutex，释放其所有权。<br/>如果有线程因为调用lock()不能上锁而被阻塞，则调用此函数会将mutex的主动权随机交给其中一个线程；<br/>如果mutex不是被此线程上锁，那么会引发未定义的异常。 |
| bool try_lock() | 尝试将mutex上锁。<br/>如果mutex未被上锁，则将其上锁并返回true；<br/>如果mutex已被锁则返回false。 |

---

**std::atomic**



# 容器

## 容器入门

1.顺序容器 vector、list、queue

2.定义

```c
#include<vector>
vector<string> sver;
```

3.容器的容器

```c
vector<vector<string>>
```

4.1迭代器

  *iter 返回迭代器 iter 所指向的元素的引用

 iter->mem 对 iter 进行解引用，获取指定元素中名为 mem 的成员。等效于 (*iter).mem

++iter， iter++ 给 iter 加 1，使其指向容器里的下一个元素

4.2迭代器中点

vector::iterator iter = vec.begin() + vec.size()/2;

创建iter迭代器，指向容器中的元素

4.3迭代器  begin  end

begin 和 end 操作产生指向容器内第一个元素和最后一个元素的下一位置 的迭代器

c.begin()返回一个迭代器，指向容器c的第一个元素

c.end()返回一个迭代器，指向C最后一个元素的下一位置

c.rbegin()返回逆序迭代器，指向最后一个元素

c.rend()返回逆序迭代器，指向c的第一个元素前面的位置

4.4迭代器中增加元素  push_back

push_back向容器尾部插入一个元素

string txt;

container.push_back(txt);

![](src/2023-02-14-01-44-45-image.png)

4.5访问顺序容器内的元素

![](src/2023-02-14-01-45-12-image.png)

![](src/2023-02-14-01-45-21-image.png)

4.6 删除顺序容器内的元素

![](src/2023-02-14-02-02-59-image.png)

删除所有元素时：c.clear()

4.7 仅适用string容器的操作  append  replace

![](src/2023-02-14-02-03-28-image.png)

5.emplace

直接向构造函数传递参数

6.访问容器

```c
//1.1 iterator显示声明
for (std::map<int, std::string>::iterator iter = test.begin(); iter != test.end(); iter++)
{
    std::cout << iter->second << std::endl;
}

//1.2 iterator auto关键字自动推断类型
for (auto iter = test.begin(); iter != test.end(); iter++)
{
    std::cout << iter->second << std::endl;
}
```

```c
//2.1 for each，类型显示声明
for each (std::pair<int, std::string> tt in test)
{
    std::cout << tt.second << std::endl;
}

//2.2 for each, auto关键字自动推断类型
for each (auto tt in test)
{
    std::cout << tt.second << std::endl;
}
```

```c
//3.1 增强型for循环
for (auto iter : test)
{
    std::cout << iter.second << std::endl;
}
```

## 关联容器

**map**

按关键词有序保存元素，使用“键--值“对

***

**set**

关键字即值，即只保存关键词的容器

插入删除查找的复杂度为对数级，即使用红黑树算法实现，**内部数据是有序的**

可以进行：

1. 去重操作
2. 排序操作

使用方法：

```
set<int> s;
s.insert(x); // 插入元素
s.erase(x);  //删除元素，有就删除，无则不管
s.size(x);
s.find(x);  //查找，返回迭代器
s.count(x);
s.empty();看看是否为空
```

```
#include <iostream>
#include <set>
using namespace std;
int main()
{
	set<int> s;
	
}
```



***

**multimap**

关键字可以重复的map

