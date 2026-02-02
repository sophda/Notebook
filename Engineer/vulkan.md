

# vulkan

# 1.rk3588配置vulkan

1.1 按照vulkan tutorial  [Development environment - Vulkan Tutorial](https://vulkan-tutorial.com/Development_environment#page_Linux) 里面的教程，安装系列的包、动态库、

```
sudo apt install vulkan-tools
sudo apt install libvulkan-dev
sudo apt install vulkan-validationlayers-dev spirv-tools

```

相关的依赖：

```
sudo apt install libglfw3-dev
sudo apt install libglm-dev

```

1.2 shader compiler

```
sudo apt install glslc
```

有两个工具，一个是glslangvalidator，另一个就是这个glslc，一般使用后者。



1.3 enable vulkan on mali610

安装了vulkan相关的动态库，还需要驱动程序才能跟gpu进行驱动。

```
wget https://repo.rock-chips.com/edge/debian-release-v2.0.0/pool/main/r/rockchip-mali/rockchip-mali_1.9-12_arm64.deb

sudo dpkg -i rockchip-mali_1.9-12_arm64.deb

sudo ln -s /usr/lib/aarch64-linux-gnu/libmali-valhall-g610-g6p0-wayland-gbm-vulkan.so /usr/lib/aarch64-linux-gnu/libmali.so

sudo mkdir -p /etc/vulkan/icd.d/

echo '{
    "file_format_version": "1.0.0",
    "ICD": {
        "library_path": "/usr/lib/aarch64-linux-gnu/libmali-valhall-g610-g6p0-wayland-gbm-vulkan.so",
        "api_version": "1.0.0"
    }
}' | sudo tee /etc/vulkan/icd.d/mali.json
```



# compute shader

## 先火急火燎的上手

```
git clone https://github.com/Erkaman/vulkan_minimal_compute.git
```

首先下载这个仓库，然后进行修改。

这个仓库是通过compute shader进行分型，然后将图片保存到本地。

---

这个仓库本身没有什么要更改的，但是为了走一遍流程，通过在cmake中设置glsl，然后编译下*.comp文件为.spv，然后通过c++去调用这个spv文件，就可以执行vulkan compute shader了

---

```cmake
# compile comp -> spv
add_custom_command(
    OUTPUT comp.spv
    # MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/sum.glsl"
    COMMAND glslc
          -fshader-stage=comp ${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.comp
          -o ${CMAKE_CURRENT_SOURCE_DIR}/shaders/comp.spv
)

add_custom_target(
    shaders ALL
    DEPENDS comp.spv
)
```

编译spv主要是通过这段代码实现，主要是通过cmake执行命令，通过glslc工具将comp文件编译为spv文件，然后将文件名输入到c++的调用端实现调用。 

```c++
uint32_t* code = readFile(filelength, "../shaders/comp.spv");
VkShaderModuleCreateInfo createInfo = {};
createInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
createInfo.pCode = code;
createInfo.codeSize = filelength;
```

这样就可以实现调用了，是不是很简单呢~

---

