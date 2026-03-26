# libtorch & Executorch

# Executorch

## 编译

要把executorch作为一个子库来使用，

在executorch 的同级目录创建文件夹，torchwhole，在里面创建要调用 的子库函数文件夹，如mytorch

### 总工程

在torchwhole文件夹下创建CMakeLists.txt

```
# CMakeLists.txt

cmake_minimum_required(VERSION 3.4.1)
set(PROJECT_NAME torchwhole)
project(${PROJECT_NAME})
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(BUILD_SHARED_LIBS OFF)
option(EXECUTORCH_BUILD_EXTENSION_DATA_LOADER "" ON)
option(EXECUTORCH_BUILD_EXTENSION_MODULE "" ON)
option(EXECUTORCH_BUILD_KERNELS_OPTIMIZED "" ON)
option(EXECUTORCH_BUILD_XNNPACK "" ON) # Build with Xnnpack backend
# set(mytorch_DIR /home/sophda/torch/executorch/torchlib)
# find_package(mytorch REQUIRED)
include_directories(
/home/sophda/torch/
/home/sophda/torch/x64test
)

link_directories(
/home/sophda/torch/executorch/buildx64/lib
# /home/sophda/torch/executorch/arm64/third-party/gflags
# ${TORCH_INCLUDE_DIRS}
)
add_subdirectory(
    /home/sophda/torch/executorch
    /home/sophda/torch/x64bin
)
add_subdirectory(
    /home/sophda/torch/x64test
    /home/sophda/torch/x64testbin
)
add_executable(
    ${PROJECT_NAME} main.cpp
)
target_link_libraries(
    ${PROJECT_NAME}
    executorch
    extension_module_static
    torchtest
)
# target_link_options(${PROJECT_NAME} PRIVATE )

```

- 使用add_subdirectory()分别将executorch、以及自己的字库作为子文件夹进行构建，那么executorch构建的库就可以在总工程以及自己的子库中进行调用了。

构建脚本：

```sh
# rm -rf /home/sophda/torch/x64testbin/*
cd /home/sophda/torch/x64whole/build
# rm -rf ./*
cmake  ..
    # -DEXECUTORCH_BUILD_EXTENSION_DATA_LOADER=ON \
    # -DEXECUTORCH_BUILD_EXTENSION_MODULE=ON \
    # -DEXECUTORCH_BUILD_KERNELS_OPTIMIZED=ON \
make -j12
```

main.cpp

## 子工程

在子工程中创建fun.cpp

```c++
#include "fun.h"
#include <executorch/runtime/core/exec_aten/exec_aten.h>
#include <executorch/runtime/core/exec_aten/util/dim_order_util.h>
#include <executorch/runtime/core/exec_aten/util/tensor_util.h>
#include <executorch/runtime/core/exec_aten/exec_aten.h>
#include <executorch/runtime/core/exec_aten/util/scalar_type_util.h>
using namespace torch::executor;
#include <string>
// using namespace ::torch::executor;
extern "C"
{
int fun(int a)
{

    std::cout<<a<<std::endl;
  // runtime_init();

        
// Create a Module.
Module module("/home/sophda/torch/x64whole/xnn.pte");
module.load();

module.load_method("forward");

const auto method_names = module.method_names();

if (method_names.ok()) {
  std::cout<<"method_names.count"<<std::endl;
}
// names = *name;

// const std::string names = const_cast<std::string&> (name);
    std::cout<<module.is_loaded() <<std::endl;

// Wrap the input data with a Tensor.
float input[1 * 3 * 224 * 224];
Tensor::SizesType sizes[] = {1, 3, 224, 224};
TensorImpl tensor(ScalarType::Float, std::size(sizes), sizes, input);
std::cout<< "size:" <<tensor.size(3) <<std::endl;
// Perform an inference.
const auto result = module.forward({EValue(Tensor(&tensor))});
const auto c = result->at(0);
// Check for success or failure.
if (result.ok()) {
  // Retrieve the output data.
  const auto output = result->at(0).toTensor().const_data_ptr<float>();
//   std::cout<<result->at(0)<<std::endl;
  // std::cout<<"done  "<<output<<std::endl;
}
}
}
```

fun.cpp

```c++
#include <iostream>
#include <executorch/extension/module/module.h>
#include <executorch/extension/data_loader/file_data_loader.h>
#include <executorch/extension/evalue_util/print_evalue.h>
#include <executorch/extension/runner_util/inputs.h>
#include <executorch/runtime/executor/method.h>
#include <executorch/runtime/executor/program.h>
#include <executorch/runtime/platform/log.h>
#include <executorch/runtime/platform/runtime.h>
#include <executorch/runtime/core/exec_aten/exec_aten.h>
#include <executorch/runtime/core/exec_aten/util/dim_order_util.h>
#include <executorch/runtime/core/exec_aten/util/tensor_util.h>
#include <executorch/runtime/platform/assert.h>

#include <executorch/runtime/core/portable_type/tensor.h>
extern "C"
{
int fun(int a);
}
```

cmakelist.txt

```cmake
# CMakeLists.txt

cmake_minimum_required(VERSION 3.4.1)
set(PROJECT_NAME torchtest)
project(${PROJECT_NAME})
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(BUILD_SHARED_LIBS OFF)
# option(EXECUTORCH_BUILD_EXTENSION_DATA_LOADER "" ON)
# option(EXECUTORCH_BUILD_EXTENSION_MODULE "" ON)
# option(EXECUTORCH_BUILD_KERNELS_OPTIMIZED "" ON)
# option(EXECUTORCH_BUILD_XNNPACK "" ON) # Build with Xnnpack backend
# set(mytorch_DIR /home/sophda/torch/executorch/torchlib)
# find_package(mytorch REQUIRED)
include_directories(
/home/sophda/torch/

/home/sophda/torch/x64test
)

link_directories(
/home/sophda/torch/executorch/buildx64/lib
# /home/sophda/torch/executorch/arm64/third-party/gflags
# ${TORCH_INCLUDE_DIRS}
)
# add_subdirectory(
#     /home/sophda/torch/executorch
#     /home/sophda/torch/x64bin
# )
add_library(
    ${PROJECT_NAME}  fun.cpp 
)
target_link_libraries(
)
# target_link_options(${PROJECT_NAME} PRIVATE -Wl,-force_laod)

```

```
https://github.com/pytorch/executorch/issues/3922
```

## 交叉编译

```
rm -rf /home/sophda/torch/mobile/mylib/build
# rm -rf /home/sophda/torch/executorch/arm64
cd /home/sophda/torch/mobile/build
rm -rf ./*
# rm armtorch
cmake -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake \
    -DANDROID_PLATFORM=android-23 \
	-DANDROID_ABI="arm64-v8a" \
    ..
make -j12
```



## 编译的相关问题

跟上面说的一样，就是新建一个总工程，然后将几个子库添加进去。但是根据几天的debug，发现了一些注意事项：

1. 库的冲突问题

   主要是针对在**链接**的环节，经不断的尝试，发现`portable_kernels`和`optimized_kernels`会发生冲突，而冲突的表现就是**无法注册内核**，如下图所示：

   ![image-20240907233526151](src/EdgeComputing_img/image-20240907233526151.png)

   这个时候只需要把cmakelist中的链接选项修改一下就可以了：**xnnpack_backend是有必要加上的，这是一个cpu运算符库，即后端**

   ```
   target_link_libraries(
       ${PROJECT_NAME}
       # "$<LINK_LIBRARY:WHOLE_ARCHIVE,portable_kernels>"
       # -Wl,--start-group
       executorch
       xnnpack_backend
       portable_kernels
       extension_module_static
   )
   ```

   > 当时看executorch，有一点提到了kernel里的注册函数并不会主动执行，需要用一些链接选项（也就是上面cmake中的第1行），否则会被编译器优化掉。但是，**如果不加这几个选项的话，也是没有问题的！！**  可以参考官方给的几个cmakelist文件示例，都没有这几个选项的身影。。
   >
   > ![image-20240907233749792](src/EdgeComputing_img/image-20240907233749792.png)

2. EValue的符号问题

   这个其实不清楚，，，我他妈就是第二天重新编译了一下，链接库什么都没动，然后就没事了。。。

3. **dlopen failed: library "libclang_rt.ubsan_standalone-aarch64-android.so" not found**

   这个问题。。。。我操他妈的！！！

   我他妈的整整弄了一天，从maui到unity，最后到了Androidstudio，前两个平台是爆出了dllnotfound的错误，如果编译其他的简单测试用例是没问题的，我最初以为是这个executorch导致的。。。折腾了一天反复编译测试不同平台调用接口，还得是Androidstudio啊，直接kotlin调用的时候出现了`"libclang_rt.ubsan_standalone-aarch64-android.so" not found`的错误，网上一搜，好家伙，原来是个debug用的！！！！怎么这么熟悉捏？？？？？？他妈的在子库链接的时候使用了  `-fsanitize=undefined`，没错，就是他妈的这个sb，导致了我的库还需要链接其他的库，而这个库都没法找到。

   ```CMAKE
   target_link_options(${PROJECT_NAME} PUBLIC 
   -fsanitize=undefined
   -Wno-deprecated-declarations
   -fPIC)
   ```

4. 占坑



## 接口

### 调用动态库

```
void calldll()
{
    void* handle = nullptr;
    handle = dlopen("/home/sophda/torch/whole/mylib/build/libmylib.so",RTLD_LAZY );

    if(!handle)
    {
        std::cerr<<"error"<<dlerror()<<std::endl;
    }
    dlerror();
    void (*fun)();
    fun = (void (*)())dlsym(handle, "fun");
    fun();
}
```



### 模型的导出、委托与量化

导出的话需要将模型进行委托，也就是将模型使用一些后端的运算库进行构建；然后将模型量化。

> **有一点需要注意，如果网络中存在dropout层的话，需要使用 model.eval() 将drop层取消作用，因为executorch中并没有dropout算子**
>
> 关于dropout,有`nn.Dropout`和`nn.functional.dropout`两种，如果是使用的是`nn.Dropout`那么在train的过程中会用到dropout，在使用model.eval()后的推理环节就会把dropout层给省略，**也就是所有神经元都会参与作用**
>
> Dropout其实就是在训练的不同批次，随机选择一些神经元进行失活处理，那么**每一个批次的神经元肯定激活的不一样，因为是随机的**，这其实就是在训练一些小的神经元，在model.eval的时候，都激活，相当于将所有的子神经元都参与工作

> 在模型导出阶段使用了model.eval()后，尽管模型中存在drop，训练模型时也用了dropout（但是并没有神经元被删除了，只是分批次训练），最后导出的模型还是可以使用executorch调用

```python
import torch
import torchvision
from torch.autograd import Variable
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
from torch.export import export, ExportedProgram
# from torchvision.models.mobilenetv2 import MobileNet_V2_Weights
from executorch.backends.xnnpack.partition.xnnpack_partitioner import XnnpackPartitioner
from executorch.exir import EdgeProgramManager, ExecutorchProgramManager, to_edge
from executorch.exir.backend.backend_api import to_backend

class Model(torch.nn.Module):
    def __init__(self) :
        super(Model, self).__init__()
        self.conv1 = torch.nn.Sequential(torch.nn.Conv2d(1, 64, 3, 1, 1),
                                         torch.nn.ReLU(),
                                         torch.nn.Conv2d(64, 128, 3, 1, 1),
                                         torch.nn.ReLU(),
                                         torch.nn.MaxPool2d(2, 2)) 
        self.dense = torch.nn.Sequential(torch.nn.Linear(14*14*128, 1024),
                                         torch.nn.ReLU(),
                                        #  torch.nn.Dropout(p = 0.5),
                                         torch.nn.Linear(1024, 10))
        self.dropout = self.dropout = torch.nn.Dropout(p=0.5)
        
    def forward(self, x) :
        x = self.conv1(x)
        x = x.view(-1, 14*14*128)
        x = self.dropout(x)
        x = self.dense(x)
        return x
model = Model()
model.eval()
state = torch.load("/home/sophda/torch/Model/Minist/minist.pth")
model.load_state_dict(state['model'])

sample_inputs = (torch.randn(1, 1, 28, 28), )
inpu = torch.randn(1,1,28,28)
ot = model(inpu)
print(ot.shape)

exported_program: ExportedProgram = export(model, sample_inputs)
edge: EdgeProgramManager = to_edge(exported_program)
edge = edge.to_backend(XnnpackPartitioner())
exec_prog = edge.to_executorch()
with open("/home/sophda/torch/Model/minist.pte", "wb") as file:
    exec_prog.write_to_file(file)
```



## 运行模型





# libtorch交叉编译

## 编译libtorch

```
cd /home/sophda/libtorch/pytorch/arm64build
# rm -rf ./*
cmake \
    -DCMAKE_TOOLCHAIN_FILE=${NDK27}/build/cmake/android.toolchain.cmake \
    -DANDROID_PLATFORM=android-30 \
	-DANDROID_ABI="arm64-v8a" \
    -DUSE_VULKAN=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_MKLDNN=OFF \
    -DUSE_QNNPACK=OFF \
    -DUSE_PYTORCH_QNNPACK=ON \
    -DBUILD_TEST=OFF \
    -DUSE_NNPACK=OFF \
    -DUSE_CUDA=OFF \
    -DBUILD_PYTHON:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DUSE_NNPACK=ON \
    -DUSE_OPENMP=OFF \
    ..

make -j12

```

## 链接

如上文所示，是编译生成的静态库，所以后面调用的时候需要将静态库添加到可执行文件中

- main文件

  ```
  #include <iostream>
  #include <torch/torch.h>
  int main(int, char**){
      std::cout << "Hello, from mobile!\n";
      torch::Tensor a = torch::rand({2,3});
      
      std::cout << a <<std::endl;
  }
  
  ```

- cmake

  ```
  cmake_minimum_required(VERSION 3.5.0)
  
  project(mobile VERSION 0.1.0 LANGUAGES C CXX)
  # set(name mobile)
  
  include_directories(
    /home/sophda/libtorch/x64/libtorch/include
    /home/sophda/libtorch/x64/libtorch/include/torch/csrc/api/include
  )
  
  set(fbjni_DIR /home/sophda/libtorch/third-party/fbjni)
  set(fbjni_BUILD_DIR /home/sophda/libtorch/third-party/fbjni/build)
  add_subdirectory(${fbjni_DIR} ${fbjni_BUILD_DIR})
  
  # add_library(fbjni STATIC IMPORTED)
  # set_property(
  #     TARGET fbjni
  #     PROPERTY IMPORTED_LOCATION
  #     /home/sophda/libtorch/third-party/fbjni/build/libfbjni.a)
  
  #########################################################################
  function(import_static_lib name)
  add_library(${name} STATIC IMPORTED)
  set_property(
      TARGET ${name}
      PROPERTY IMPORTED_LOCATION
      /home/sophda/libtorch/pytorch/arm64build/lib/${name}.a)
  endfunction(import_static_lib)
  
  
  import_static_lib(libtorch)
  import_static_lib(libtorch_cpu)
  import_static_lib(libc10)
  import_static_lib(libnnpack)
  import_static_lib(libXNNPACK)
  import_static_lib(libpthreadpool)
  import_static_lib(libeigen_blas)
  import_static_lib(libcpuinfo)
  import_static_lib(libclog)
  import_static_lib(libpytorch_qnnpack)
  
  
  # Link most things statically on Android.
  set(pytorch_LIBS
    fbjni
    -Wl,--gc-sections
    -Wl,--whole-archive
    libtorch
    libtorch_cpu
    -Wl,--no-whole-archive
    libc10
    libXNNPACK
    libpthreadpool
    libeigen_blas
    libcpuinfo
    libclog
    libpytorch_qnnpack
    libnnpack
    # openmp
  
  )
  
  add_executable(mobile main.cpp)
  target_link_libraries(mobile ${pytorch_LIBS})
  
  ```

- 构建脚本

  ```
  cd /home/sophda/libtorch/mobile/armbuild
  rm -rf ./*
  cmake \
      -DCMAKE_TOOLCHAIN_FILE=${NDK27}/build/cmake/android.toolchain.cmake \
      -DANDROID_PLATFORM=android-30 \
  	-DANDROID_ABI="arm64-v8a" \
      ..
  
  make -j12
  ```





# libtorch  api


# JNI

呃按道理说，安卓也是边缘设备不是？所以也算边缘计算~

## kotlin与jni交互

**c++端：**

命名标准：

```
Java_com_example_chat_lib_gpt2_init(JNIEnv * env, jobject obj)
```

分别是：

- Java

- com_example_chat_lib：表示路径

  ![image-20241210153106963](src/EdgeComputing_img/image-20241210153106963.png)

- gpt2：类名

- init：c++中的函数

- (JNIEnv * env, jobject obj) 这两个都要有，不管有没有参数

```c++
#include "gpt2.hpp"
#include <iostream>
#include <memory>
#include <android/log.h>
#include <jni.h>

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_chat_lib_gpt2_init(JNIEnv * env, jobject obj)
{
    LOGI("gpt2init");
    gpt2 = std::make_shared<GPT2>(
        "/storage/emulated/0/gpt2/encoder.json",
        "/storage/emulated/0/gpt2/vocab.txt",
        "/storage/emulated/0/gpt2/gpt2.jit"
    );
    return 0;

}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_example_chat_lib_gpt2_getreply(JNIEnv * env,jobject obj, jstring input)
{
    // *output = *input + "c++你好";
    const char *input_char = env->GetStringUTFChars(input,NULL);
    std::string input_str = input_char;
    // std::string output;
    std::string output = gpt2->process(input_str);
    // std::string output = "123.";

    // std::string in = "";
    return env->NewStringUTF(output.c_str());
}

```

**kotlin端：**

```kotlin
package com.example.chat.lib

class gpt2 {
    companion object{
        init {
            System.loadLibrary("gpt2mobile")
        }
    }
    external fun getreply(input: String) : String
    external fun init() : Int


    fun test(input: Int):Int
    {
        return 7;
    }
}
```



# deploy GPT2 (libtorch)

## 使用python导出为jit权重

```python
import json
import numpy as np
import os
import urllib.request

# import requests
import tiktoken
import torch
from tqdm import tqdm
from model import GPTModel
def testTrace():
    model = torch.jit.load("./gpt2.jit")
    tokenids = torch.tensor([[31373]])
    output = model(tokenids)
    print(output)
    return


def saveTraced():
    CHOOSE_MODEL = "gpt2-small (124M)"
    INPUT_PROMPT = "hello,world"

    BASE_CONFIG = {
        "vocab_size": 50257,     # Vocabulary size
        "context_length": 1024,  # Context length
        "drop_rate": 0.0,        # Dropout rate
        "qkv_bias": True         # Query-key-value  
    }

    model_configs = {
        "gpt2-small (124M)": {"emb_dim": 768, "n_layers": 12, "n_heads": 12},
        "gpt2-medium (355M)": {"emb_dim": 1024, "n_layers": 24, "n_heads": 16},
        "gpt2-large (774M)": {"emb_dim": 1280, "n_layers": 36, "n_heads": 20},
        "gpt2-xl (1558M)": {"emb_dim": 1600, "n_layers": 48, "n_heads": 25},
    }

    model_size = CHOOSE_MODEL.split(" ")[-1].lstrip("(").rstrip(")")

    BASE_CONFIG.update(model_configs[CHOOSE_MODEL])


    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    gpt = GPTModel(BASE_CONFIG)
    # torch.save(gpt.state_dict(),'./gpt2.pth')
    gpt.load_state_dict(torch.load("./gpt2.pth",weights_only = True,map_location = "cpu"))
    # gpt.to(device)
    gpt.eval()
    tokenids = torch.tensor([[31373,    11,  6894,  4421]])
    output = gpt(tokenids)
    print(output)
    traced = torch.jit.trace(gpt,tokenids)
    traced.save("./gpt2.jit")

# saveTraced()
testTrace()
```

## libtorch加载权重、推理

加载权重并进行推理

```cpp
  int ids[] = {31373,11,6897};
  torch::Tensor ids_tensor = torch::from_blob(
    ids,
    {1,4}
  );
  std::vector<torch::jit::IValue> inputs;
  inputs.push_back(ids_tensor.to(torch::kLong));
  torch::jit::Module model = torch::jit::load("/home/sophda/libtorch/GPT2/model_py/gpt2.jit");
  // return 0;
  torch::NoGradGuard no_grad;

  auto out = model.forward(inputs).toTensor();
```

如果不把ids_tensor转换为kLong的话， 这样子的话会遇到：

```
RuntimeError: Expected tensor for argument #1 'indices' to have one of the following scalar types: Long, Int; but got CPUFloatType instead (while checking arguments for embedding)
```

这种问题，也就是保存的模型和输入的模型权重不匹配，于是需要将输入的types修改为Long或者Int类型的：即加上.to()

**需要新建一个inputs的vector，然后将需要输入的tensor push进去，但是放到vector里面并不是升维度，里面是啥推理的就是啥**





## 推理并输出结果

```c++
auto output = model.forward(input_vec).toTensor();
// std::cout<<output.shape()<<std::endl;

torch::Tensor sliced = output.index({Slice(0,None),-1,Slice(0,None)});
torch::Tensor max = torch::argmax(sliced,-1);
int new_token_id = max.item().toInt();
```

1.输出的output结果，需要对其进行索引，具体的**索引方法**如下：

> 前提：使用`using namespace torch::indexing`

![image-20241210151853067](src/EdgeComputing_img/image-20241210151853067.png)

如果是对tensor进行**赋值操作**，如下：

![image-20241210152003532](src/EdgeComputing_img/image-20241210152003532.png)

2.输出的结果需要取argmax得到维度上的最大值，也就是最大的那个token id，需要将argmax得到的tensor转换为int类型

```c++
torch::Tensor max = torch::argmax(sliced,-1);
int new_token_id = max.item().toInt();
```

