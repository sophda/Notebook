# Executorch

# 部署

要把executorch作为一个子库来使用，

在executorch 的同级目录创建文件夹，torchwhole，在里面创建要调用 的子库函数文件夹，如mytorch

## 总工程

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
    optimized_native_cpu_ops_lib
    torchtest
)
# target_link_options(${PROJECT_NAME} PRIVATE )

```

- 使用add_subdirectory()分别将executorch、以及自己的字库作为子文件夹进行构建，那么executorch构建的库就可以在总工程以及自己的子库中进行调用了。

构建脚本：

```
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

```
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

```
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

```
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
    ${PROJECT_NAME}
    executorch xnnpack_backend
    extension_module_static
    optimized_native_cpu_ops_lib
    optimized_native_cpu_ops_lib portable_ops_lib quantized_ops_lib portable_kernels quantized_kernels
    optimized_kernels cpublas eigen_blas 
)
# target_link_options(${PROJECT_NAME} PRIVATE -Wl,-force_laod)

```







```
https://github.com/pytorch/executorch/issues/3922
```

