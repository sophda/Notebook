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

