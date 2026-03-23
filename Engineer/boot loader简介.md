# boot loader移植

## 1.介绍

### 1.1bootloader概念

boot loader是在系统运行之前的程序
boot loader支持不同cpu

![76cfad73c863ee909e49b75fe95930eb.png](src/boot%20loader简介/659a705d9397b46e9029adb8c750c36e2311a588.png)

![610ecd5779a6e42c8cd0bc0c044559a4.png](src/boot%20loader简介/c7608b703034696240c48bf244be011b9f1cd63b.png)

### 1.2启动过程分类

![e75cd356629788af37ab950409a43118.png](src/boot%20loader简介/a6b28a8f3c82682fe584b260cfac23fa4b765b25.png)

### 1.3 操作模式

![d0b287a0b8771d17da2d8593d3dfb903.png](src/boot%20loader简介/93790616b68aa84d1ec4097f3bcf253a4b7f13a4.png)

### 1.4 启动过程

分为stage1（使用汇编，快）和stage2（使用c，移植方便）
stage1：
![](src/boot%20loader简介/2023-01-24-02-02-35-image.png)

stage2：
![d8caadc99700389f8e67fd5818028bdb.png](src/boot%20loader简介/736b0387b1f43c2f1eda90fa14a576974e0c048d.png)

## 2.uboot

引导Linux系统

### 2.1 主要功能

![](src/boot%20loader简介/d1ae07d9d928629deae84947f3e68a2154242c1c.png)

### 2.2 uboot编译

```
tar xvjf uboot.tar.bz2
cd uboot-2013
make mini2440_config
make all
```

编译生成u-boot.bin在当前目录
