# 1.环境配置

## 1.WSL配置

### 设置内存和swap

在用户目录下新建**.wslconfig**

```
[wsl2]
memory=20GB
swap=20GB
localhostForwarding=true

```

即可设置内存为20G，设置交换内存为20G




# 2.命令

## 解压缩相关

### 解压

```
tar -xf cv.tar.xz  //解压
```

### 压缩

```
tar -cvf [文件名].tar [文件目录] //打包成.tar文件
tar -jcvf [文件名].tar.bz2 [文件目录] //打包成.bz2文件
tar -zcvf [文件名].tar.gz [文件目录] //打包成.gz文件
```




## 设置环境变量

```
1.设置可执行文件路径
vi ~/.bashrc
//在最后面加上
export PATH=$PATH:value
//其中value表示你的bin可执行文件的地址
```

```
2.设置变量值
vi ~/.bashrc
export NDK=/home/sophda/src/android-ndk-r25c/
//这样就可以直接
echo ${NDK}
```

![image-20230714044728254](src/Linux_img/image-20230714044728254.png)



## 查看动态库

1. readelf

   ```
   readelf -a libhello.so
   ```

   **查看库的平台，x86/arm：**

   ```
   readelf -h libopencv_photo.so
   ```

   ![image-20230716045800044](src/Linux_img/image-20230716045800044.png)

   **查看库的依赖：**

   ```
   readelf -a libxxx.so | grep "Shared"
   ```

2. nm

   ```
   nm libhello.so
   ```

3. 查看动态库函数

   ```
   nm -D lib***.so
   ```


4. 查看动态库是32为还是64位

   动态库：

   ```
   file xxx.so
   ```

   静态库

   ```
   objdump -a xxx.a
   ```
   



## 杀死进程

```
pgrep -f your_process_name //获取进程号，即pid
kill -15 pid  //根据pid杀死进程，15表示优雅的退出
```

比如，我的clion界面没有了（cnm在wsl中b事这么多），但是后台还在运行，所以需要kill掉

```
pgrep -f clion
kill -15 pid
```



## 查看文本文件

1. cat（concatenate-连接）

   核心功能是按顺序从头至尾，读取一个或多个文件，并将内容直接输出到标准输出

   ```
   cat /etc/hosts  查看单个文件
   cat file1.txt file2.txt  查看多个文件
   cat file1.txt file2.txt > combined_file.txt  连接文件并存入新的文件中
   cat -n script.sh  显示行号
   ```

2. nl（number-lines）添加行号

   核心功能是在输出文件时，自动计算并添加行号

   ```
   nl script.sh 默认不计算空行
   nl -b a config.conf 计算所有行，包括空行
   ```

3. tac（cat的反写）

   很明显是cat的反写，功能和cat完全相反，功能是：按行，从最后一行到第一行反向显示文件内容

   ```
   tac access.log
   # access.log 的最后一行会最先显示
   ```

4. more（更多）

   当文件内容非常长，使用 `cat` 会瞬间刷满整个屏幕，导致无法看清前面的内容。`more` 就是为了解决这个问题而生的，它是一个“分页器”（Pager），**允许你一页一页地查看文件内容**。

   ```
   more /var/log/syslog
   ```

   - **空格键 (Space)**：向下翻一页。

   - **回车键 (Enter)**：向下滚动一行。

   - **`q` 或 `Q`**：退出查看。

   - **`/`**：可以输入关键词进行搜索（向下搜索）。



## 权限

在深入命令之前，必须先理解Linux如何定义权限。使用 `ls -l` 命令可以看到文件权限：

Bash

```
$ ls -l my_script.sh
-rwxr-xr-- 1 user staff 1024 Sep 8 00:15 my_script.sh
```

我们来分解第一部分的 `-rwxr-xr--`：

- **第1位 (`-`)**: 文件类型。`-` 代表普通文件，`d` 代表目录，`l` 代表链接等。
- **第2-4位 (`rwx`)**: **所有者 (User)** 的权限。
- **第5-7位 (`r-x`)**: **所属组 (Group)** 的权限。
- **第8-10位 (`r--`)**: **其他人 (Other)** 的权限。

权限位本身的含义：

- **r (Read - 读取)**:
  - 对文件：可以读取文件内容。
  - 对目录：可以列出目录下的文件和子目录列表 (`ls`)。
- **w (Write - 写入)**:
  - 对文件：可以修改文件内容。
  - 对目录：可以在目录中创建、删除、重命名文件。
- **x (Execute - 执行)**:
  - 对文件：可以将文件作为程序来执行。
  - 对目录：可以进入（`cd`）该目录。

------

### 1. `chmod` (Change Mode) - 更改权限

`chmod` 是最核心的权限修改命令。它有两种设置权限的模式：**符号模式**和**八进制（数字）模式**。

#### a) 符号模式 (Symbolic Mode)

这种模式更直观，易于理解。语法结构是 `[用户身份][操作符][权限]`。

- **用户身份**:
  - `u`: 所有者 (user)
  - `g`: 所属组 (group)
  - `o`: 其他人 (others)
  - `a`: 所有人 (all)，即 `u`、`g`、`o` 的总和。
- **操作符**:
  - `+`: 添加权限。
  - `-`: 移除权限。
  - `=`: 直接设置权限（覆盖原有权限）。
- **权限**: `r`, `w`, `x`

**示例**:

```
# 给脚本所有者添加执行权限
chmod u+x my_script.sh

# 移除所属组的写入权限
chmod g-w shared_folder/

# 为其他人设置只读权限（覆盖掉w和x权限）
chmod o=r config.txt

# 给所有人都添加读取权限
chmod a+r public_info.txt

# 同时进行多个设置，用逗号分隔
chmod u+w,g-x,o=r some_file
```

#### b) 八进制/数字模式 (Octal Mode)

这种模式更快捷，是经验丰富的用户首选。它用一个三位数的数字来代表权限。

数字的来源是二进制的映射关系：

- `r` = 4 (二进制 `100`)
- `w` = 2 (二进制 `010`)
- `x` = 1 (二进制 `001`)

将所需权限的数字相加，得到一个总和：

- `7`: `rwx` (4+2+1)
- `6`: `rw-` (4+2)
- `5`: `r-x` (4+1)
- `4`: `r--` (4)
- `0`: `---` (无任何权限)

三位数的八进制数字分别对应 **[所有者][所属组][其他人]** 的权限。

**常见权限组合**:

- **`755`**: `rwxr-xr-x`。所有者有全部权限；所属组和其他人有读取和执行权限。**常用于目录和可执行脚本**。
- **`644`**: `rw-r--r--`。所有者有读写权限；所属组和其他人只有只读权限。**常用于普通文本文件**。
- **`700`**: `rwx------`。只有所有者有全部权限。**常用于私密目录或脚本**。
- **`600`**: `rw-------`。只有所有者有读写权限。**常用于私密的配置文件或密钥文件**。

```
# 设置脚本为 rwxr-xr-x
chmod 755 my_script.sh

# 设置普通文件为 rw-r--r--
chmod 644 my_document.txt

# 设置私钥文件为只有所有者可读写
chmod 600 ~/.ssh/id_rsa
```

**通用选项**:

- `-R` (Recursive): 递归地将权限应用到目录及其中的所有文件和子目录。

  Bash

  ```
  # 将整个网站目录设置为755，文件设置为644
  chmod -R u+rwX,go+rX,go-w /var/www/my_site
  # 注意：大写的 X 表示只对目录或已有执行权限的文件添加执行权限，防止普通文件被错误地加上x权限。
  ```

------

### 2. `chown` (Change Owner) - 更改所有者和所属组

此命令用于更改文件或目录的所有者和所属组。

- **基本语法**:

  ```
  chown [新所有者]:[新所属组] 文件/目录
  ```

**示例**:

Bash

```
# 将文件的所有者更改为 aaron
chown aaron some_file.txt

# 将文件的所有者更改为 aaron，所属组更改为 developers
chown aaron:developers some_file.txt

# 只更改所属组
chown :admins config.conf

# 递归更改目录的所有权
chown -R www-data:www-data /var/www/html
```

------

### 3. `chgrp` (Change Group) - 更改所属组

此命令专门用于更改文件或目录的所属组。不过，由于 `chown` 命令也能完成这个功能，`chgrp` 的使用频率相对较低。

- **基本语法**:

  ```
  chgrp [新所属组] 文件/目录
  ```

```
# 将文件的所属组更改为 staff
chgrp staff data.csv

# 递归更改目录的所属组
chgrp -R developers /opt/project
```

------

### 4. `umask` (User Mask) - 设置默认权限掩码

`umask` 命令用于控制新创建文件和目录的**默认权限**。它设置的是一个“权限掩码”，代表要从最大权限中“减去”的权限位。

- Linux 的默认最大权限是：
  - 对**目录**: `777` (`rwxrwxrwx`)
  - 对**文件**: `666` (`rw-rw-rw-`)，默认不给执行权限，因为大多数文件不需要执行。
- `umask` 的值会从这个最大权限中被“拿走”。

**示例**: 大多数系统的默认 `umask` 是 `0022` 或 `022`。我们以 `022` 为例：

- **创建新文件**:
  - 默认最大权限: `666` (`rw-rw-rw-`)
  - 减去 umask: `022` (`----w--w-`)
  - 最终权限: `644` (`rw-r--r--`)
- **创建新目录**:
  - 默认最大权限: `777` (`rwxrwxrwx`)
  - 减去 umask: `022` (`----w--w-`)
  - 最终权限: `755` (`rwxr-xr-x`)

**常用 `umask` 命令**:

Bash

```
# 查看当前的 umask 值
umask

# 临时设置 umask (只在当前 shell 会话有效)
# 设置为077，使得新文件权限为600，新目录为700，非常安全
umask 077
```

### 总结表格

| 命令        | 主要功能                             | 常用场景                                              |
| ----------- | ------------------------------------ | ----------------------------------------------------- |
| **`chmod`** | 更改文件或目录的读、写、执行权限     | 设置脚本可执行 (`755`)，保护配置文件 (`644` 或 `600`) |
| **`chown`** | 更改文件或目录的所有者和所属组       | 将网站文件所有权交给Web服务器用户 (`www-data`)        |
| **`chgrp`** | 更改文件或目录的所属组               | 将项目文件归属到特定的开发组 (`developers`)           |
| **`umask`** | 设置创建新文件和目录时的默认权限掩码 | 提高系统安全性，控制新文件的默认访问级别              |



## 分区文件

第一步：识别目标磁盘和分区

首先，你需要找出要修改的分区所在的磁盘。以 root 用户或使用 `sudo` 运行以下命令来列出所有磁盘及其分区表：

Bash

```
sudo fdisk -l
```

在输出中找到你的目标磁盘（例如 `/dev/sda`, `/dev/sdb`, `/dev/nvme0n1` 等）和要修改的分区号。

你也可以使用 `lsblk` 或 `swapon --show` 来辅助识别。`swapon --show` 会列出当前已激活的交换空间，可以帮你确认是否已经存在活动的交换分区。

**示例输出 `fdisk -l`:**

```
Disk /dev/sda: 238.47 GiB, 256060514304 bytes, 500118192 sectors
...
Device         Boot   Start       End   Sectors   Size Id Type
/dev/sda1        * 2048   1050623   1048576   512M ef EFI (FAT-12/16/32)
/dev/sda2           1050624 483526655 482476032 230.1G 83 Linux
/dev/sda3         483526656 500117503  16590848   7.9G 83 Linux  <-- 假设我们要将这个分区改为Swap
```

在这个例子中，我们假设要将 `/dev/sda3` 的类型从 `83 (Linux)` 改为 `82 (Linux swap)`。

第二步：启动 fdisk 工具

使用 `fdisk` 命令进入对目标磁盘的交互式操作模式。请确保你指定的是整个磁盘设备，而不是分区（例如，使用 `/dev/sda` 而不是 `/dev/sda3`）。

Bash

```
sudo fdisk /dev/sda
```

执行后，你将进入 `fdisk` 的命令提示符界面：

```
Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Command (m for help):
```

第三步：更改分区类型 (使用 't' 命令)

1. 在 `fdisk` 提示符下，输入 `t` 并按回车。这个命令用于更改分区的系统 ID。

   ```
   Command (m for help): t
   ```

2. `fdisk` 会要求你选择要修改的分区号。在我们的例子中，是分区 `3`。输入 `3` 并按回车。

   ```
   Partition number (1-3, default 3): 3
   ```

3. 接下来，`fdisk` 会要求你输入新的分区类型的十六进制代码。对于 Linux Swap，代码是 `82`。输入 `82` 并按回车。

   ```
   Hex code (type L to list all codes): 82
   ```

   如果你不确定代码，可以输入 `L` 来查看所有支持的类型代码列表。

4. 更改成功后，`fdisk` 会显示确认信息。

   ```
   Changed type of partition 'Linux' to 'Linux swap / Solaris'.
   ```

第四步：验证并保存更改

1. **验证更改 (可选但推荐)** 在保存之前，输入 `p` 命令来打印当前的分区表，检查 `/dev/sda3` 的 `Type` 是否已经变成了 `Linux swap / Solaris`。

   ```
   Command (m for help): p
   ```

   **示例输出 `p`:**

   ```
   Disk /dev/sda: 238.47 GiB, 256060514304 bytes, 500118192 sectors
   ...
   Device         Boot   Start       End   Sectors   Size Id Type
   /dev/sda1        * 2048   1050623   1048576   512M ef EFI (FAT-12/16/32)
   /dev/sda2           1050624 483526655 482476032 230.1G 83 Linux
   /dev/sda3         483526656 500117503  16590848   7.9G 82 Linux swap / Solaris
   ```

   确认无误后，继续下一步。

2. **写入更改 (保存)** 输入 `w` 命令将刚才的所有更改写入磁盘分区表并退出 `fdisk`。这是最关键的一步，在此之前的所有操作都只在内存中进行。

   ```
   Command (m for help): w
   The partition table has been altered.
   Calling ioctl() to re-read partition table.
   Syncing disks.
   ```

   如果分区正在使用中，你可能会看到一条消息提示内核仍在旧的分区表，建议重启系统。

   如果你想放弃所有更改并退出，可以输入 `q` 而不是 `w`。

第五步：格式化并激活交换分区

仅仅更改分区 ID 并不会格式化该分区。你需要使用 `mkswap` 命令来将其设置为交换区格式。

1. **格式化分区：**

   ```
   sudo mkswap /dev/sda3
   ```
   
2. **激活交换分区：**

   ```
   sudo swapon /dev/sda3
   ```
   
3. **验证激活：** 再次运行 `swapon --show` 或 `free -h`，你应该能看到新的交换分区已经被激活并正在使用。

   ```
   $ swapon --show
   NAME      TYPE      SIZE  USED PRIO
   /dev/sda3 partition 7.9G    0B   -2
   ```





## 查看后台进程

好的，在 Linux 系统中查看和管理后台执行的进程，有几个常用且高效的指令。最核心的两个是 `jobs` 和 `ps`。



### 1. `jobs` 命令 (最常用和直接)



`jobs` 命令用于显示当前终端会话（shell session）中启动的后台任务。它非常直接，但**只能看到在当前终端放入后台的任务**。

**使用场景:** 当你使用 `&` 将一个命令放到后台执行，或者使用 `Ctrl+Z` 暂停一个前台任务后用 `bg` 命令将其转到后台时，`jobs` 就能看到它。

**基本语法:**

Bash

```
jobs [选项]
```

**常用选项:**

- `-l`: 除了显示任务号和状态，还会显示进程ID (PID)。
- `-p`: 只显示任务的进程ID (PID)。
- `-r`: 只显示正在运行 (running) 的任务。
- `-s`: 只显示已停止 (stopped) 的任务。

**示例:** 假设我们后台运行了 `sleep` 和 `ping` 命令。

Bash

```
$ sleep 100 &
[1] 12345
$ ping google.com > /dev/null &
[2] 12346

$ jobs
[1]-  Running                 sleep 100 &
[2]+  Running                 ping google.com > /dev/null &

$ jobs -l
[1]-  12345 Running                 sleep 100 &
[2]+  12346 Running                 ping google.com > /dev/null &
```

**输出解读:**

- `[1]`, `[2]`: 任务号 (Job ID)。你可以用 `%1`, `%2` 来操作这些任务 (例如 `fg %1` 切换回前台)。
- `+`: 代表当前默认的任务。
- `-`: 代表次于默认的任务。
- `Running`: 任务的当前状态。
- `sleep 100 &`: 启动任务的原始命令。



### 2. `ps` 命令 (功能更强大，查看所有进程)

`ps` (process status) 命令可以查看系统上所有用户的所有进程，而不仅仅是当前终端会话的后台任务。因此，它的范围更广。

**使用场景:**

- 查看由其他终端、脚本或系统服务启动的后台进程。
- 查看已经与终端分离的“守护进程”(daemons)。
- 当你关闭了原来的终端，想查看之前启动的后台任务时 (`jobs` 此时已无法使用)。

**基本语法 (常用组合):**

Bash

```
# BSD 风格，最常用，显示所有用户的进程，包括没有终端的
ps aux

# System V 风格，功能类似
ps -ef

# 结合 grep 查找特定进程
ps aux | grep [进程名]
```

**示例:** 假设我们想查找所有 `sleep` 相关的进程。

Bash

```
$ ps aux | grep sleep
# 输出可能如下
# USER      PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# myuser  12345   0.0  0.0   7228   888 pts/0    S    02:10   0:00 sleep 100
# myuser  12500   0.0  0.0   6136   640 pts/0    S+   02:15   0:00 grep --color=auto sleep
```

**输出解读:**

- `USER`: 启动该进程的用户。
- `PID`: 进程ID (Process ID)，是操作系统的唯一标识符。
- `%CPU`, `%MEM`: CPU 和内存的使用率。
- `TTY`: 进程关联的终端。如果是 `?`，表示该进程没有控制终端，通常是系统守护进程。
- `STAT`: 进程状态 (如 `S` 表示休眠, `R` 表示运行, `Z` 表示僵尸进程)。
- `COMMAND`: 启动进程的命令。

**`ps -f` 结合 `pgrep` (更精确的查找)**

有时 `grep` 会把自己也搜索出来。使用 `pgrep` (process ID grep) 可以更精确地找到PID，然后再用 `ps` 查看详细信息。

Bash

```
# 1. 查找所有名为 'sleep' 的进程的 PID
$ pgrep sleep
12345

# 2. 使用 PID 查看进程的详细信息
$ ps -f -p 12345
# 或者
$ ps -fp $(pgrep sleep)

# 输出
# UID         PID   PPID  C STIME TTY          TIME CMD
# myuser    12345  11200  0 02:10 pts/0    00:00:00 sleep 100
```

- `-f`: 显示完整格式的列表 (full format)。
- `-p`: 指定要查询的 PID。



### 3. 其他工具



- **`top` / `htop`**: 这两个是实时进程监控工具。它们会动态刷新显示系统中所有进程的状态，包括后台进程。`htop` 是 `top` 的增强版，界面更友好。你可以直接在它们的界面里看到所有正在运行的进程。



### 总结

| 命令             | 主要用途                             | 优点                                              | 缺点                                       |
| ---------------- | ------------------------------------ | ------------------------------------------------- | ------------------------------------------ |
| **`jobs`**       | 查看和管理**当前终端会话**的后台任务 | 非常直接、简单，易于管理（`fg`, `bg`, `kill %1`） | 只能看到当前终端的任务，关闭终端后信息丢失 |
| **`ps aux`**     | 查看系统上**所有用户**的所有进程     | 功能强大，信息全面，能看到任何后台进程            | 信息量大，通常需要配合 `grep` 来筛选       |
| **`pgrep`**      | 根据名称或其他属性查找进程的 PID     | 查找精确，适合在脚本中使用                        | 只返回 PID，需要配合 `ps` 查看详细信息     |
| **`top`/`htop`** | 实时、动态地监控所有系统进程         | 实时刷新，交互式，信息直观                        | 不适合在脚本中使用，用于即时监控           |


## 硬盘

### 查看连接的硬盘，即使没有挂载

```
fdisk -l
```



### 机械硬盘速度

磁盘120个扇区，每个扇区512B，转速是3600转/min，那么该磁盘的速度是多少kb/s？

第一步：计算每条磁道的总数据量

首先，我们计算磁盘旋转一圈可以读取多少数据。一条磁道上有120个扇区，每个扇区的大小是512字节（B）。

- **每磁道数据量** = 扇区数 × 每个扇区的大小
- `120 个扇区/转 × 512 B/扇区 = 61,440 B/转`

这意味着磁盘每旋转一整圈，可以读取 61,440 字节的数据。

第二步：计算每秒的转数

磁盘的转速是 3600 转/分钟（RPM）。我们需要将其换算成“转/秒”（RPS）。

- **每秒转数** = 每分钟转数 / 60
- `3600 转/分钟 / 60 秒/分钟 = 60 转/秒`

这意味着磁盘每秒钟可以旋转 60 圈。

第三步：计算每秒的数据传输量（B/s）

现在，我们将前两步的结果相乘，就可以得到每秒钟可以传输多少字节的数据。

- **数据传输率 (B/s)** = 每磁道数据量 × 每秒转数
- `61,440 B/转 × 60 转/秒 = 3,686,400 B/s`

所以，该磁盘的理论速度是每秒 3,686,400 字节。

第四步：将单位换算成 KB/s

题目要求以 KB/s（千字节/秒）为单位。在计算机中，标准的换算关系是：

- **1 KB = 1024 B**

现在我们进行单位换算：

- **数据传输率 (KB/s)** = 数据传输率 (B/s) / 1024
- `3,686,400 B/s / 1024 B/KB = 3600 KB/s`











## Nginx

### 配置代理

在/etc/nginx/config.d/nas.conf中配置：

```
server {
    listen 80;
    listen [::]:80;
    server_name www.sophda.top;  # 你的域名

    location /nas {
        proxy_pass http://localhost:20001;  # 转发到本地的20001端口
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

上面代码中，第三行特别重要，没有这行就会报错。

然后重启：

```
sudo systemctl restart nginx
```


## 编译

### **动态库编译：**

```
g++ main.cpp -lmath -L/usr/local/lib -o main
//-l指定库  -o指定输出  -L指定路径
```

**编译opencv：**

```
g++ main.cpp -o exam -I/home/sophda/include -L/home/sophda/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

```
 g++ main.cpp -o exam -I/lib/include -Wl,-rpath,/lib/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

### **静态库编译：**

```
g++ main.cpp -static -o exam -L/home/cvlib -mfpu=neon -mfloat-abi=hard  -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```

**交叉编译：（静态）**

```
arm-linux-gnueabi-g++ main.cpp -o exam -static -I/home/sophyda/opencv-3.2.0/arm-install/include -L/home/sophyda/opencv-3.2.0/arm-install/lib -lopencv_imgcodecs  -lopencv_imgproc -lopencv_core -ldl -lm -lpthread -lrt
```



## 可执行程序移植

### 查看程序需要的动态库

- ldd

我在wsl编译了slam系统，然后出差，打包到虚拟机上面去运行，所以说需要打包程序及相关的动态库。

linux程序在移植的时候，动态库是可以不看路径的。比如说，在wsl上程序依赖的动态库存在于各个文件夹，那么在虚拟机上，就可以把所有的动态库一次性打包过去，然后制定好路径即可。

- 查看程序需要哪些动态库，也就是需要打包的部分

  ```
  ldd ./AtlasORBslam
  ```

  寻找这些动态库：()

  ```
  find / -name libboost_system.so
  ```

  打包这些动态库：

  ```
  cd ....
  tar -cvf boost.tar ./libboost*.so
  ```

- 在虚拟机上面，解压相应的程序及动态库，要让程序能找到这些库，所以：

  ```
  cd /库的路径
  pwd  # 获取库的路径，方便一点，直接复制结果就可以了
  sudo vi /etc/ld.so.conf
  # 添加 库 的路径
  sudo ldconfig
  ```

  

## 添加守护进程

> 这里以配置virtualhere为例，因为需要后台运行，但是ssh不能一直挂着，所以需要通过守护进程来保证后台一直执行

1. 新建一个 `virtualhere.service` 的文件，写入一下内容

   ```
   [Unit]
   Description=virtualhere
   After=network.target
   
   [Service]
   ExecStart=/home/kickpi/virtualhere/vhusbdarm64
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   
   ```

   - After说明要在network之后启动
   - ExecStart说明要后台运行的程序

2. 将这个文件拷贝到系统配置目录中

   ```shell
   sudo cp ./virtualhere.service /etc/systemd/system/
   ```

3. 执行一下命令，启动service

   ```shell
   # 1. 重载 Systemd 配置（修改服务文件后必须执行）
   sudo systemctl daemon-reload
   
   # 2. 启动服务
   sudo systemctl start virtualhere.service
   
   # 3. 设置开机自启（关键！否则重启后进程不自动运行）
   sudo systemctl enable virtualhere.service
   ```

   ```shell
   sudo start virtualhere   # 启动
   sudo stop virtualhere    # 停止
   sudo restart virtualhere # 重启
   ```

   
