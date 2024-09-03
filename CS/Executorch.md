# Executorch

# 部署

```
cmake_minimum_required(VERSION 3.4.1)
set(PROJECT_NAME torchtest)
project(${PROJECT_NAME})
set(CMAKE_CXX_STANDARD 17)
include_directories(
/home/sophda/torch/
/home/sophda/torch/executorch/extension/module
/home/sophda/torch/executorch/arm64install/include/executorch/kernels/portable
)
link_directories(
/home/sophda/torch/executorch/arm64xnninstall/lib
)
add_executable(${PROJECT_NAME} runner.cpp)
target_link_libraries(${PROJECT_NAME}
libexecutorch.a
libextension_module.a
libextension_data_loader.a
libexecutorch_no_prim_ops.a
libextension_module_static.a
libportable_kernels.a
libportable_ops_lib.a
libpthreadpool.a
libxnnpack_backend.a
)
target_link_options(${PROJECT_NAME} PRIVATE -fPIC )
```

```
cd armbuild
rm -rf ./*
cmake -DCMAKE_TOOLCHAIN_FILE="/home/sophda/src/android-ndk-r25c/build/cmake/android.toolchain.cmake"\
	-DCMAKE_BUILD_TYPE="Release" \
	-DANDROID_ABI="arm64-v8a" \
	..
make
```

```
https://github.com/pytorch/executorch/issues/3922
```

