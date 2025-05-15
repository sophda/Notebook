![image-20250424152600215](src/image-20250424152600215.png)



# 介绍

docker是一种方便部署的，通过 镜像-容器 快速实现对应功能的平台



# 基础操作



# 安装

详见：[Ubuntu Docker 安装 | 菜鸟教程](https://www.runoob.com/docker/ubuntu-docker-install.html)



# 常用命令

![img](src/deda3bd54e604739d2802a6a5b61060c.jpeg)

## 下载镜像

下载镜像到本地

```
docker pull ...
docker pull mysql
```

## 查询本机镜像

```
docker images
```

## 删除镜像

```
docker rmi 镜像名
docker rmi mysql
```



## 根据镜像启动容器

```
docker run [params] image

params:
--name="name" 指定容器名称
-d  后台方式运行
-it 交互方式运行，可以进入容器查看内容
-p  指定容器的端口

eg：
docker run -it centos /bin/bash
```



## 列出所有容器

```
docker ps
```



## 删除容器

```
docker rm 容器id
```



## 清理已经停止的容器

```
docker rm -v $(docker ps -aq -f status=exited)
```



## 启动和停止容器

```
docker start 容器id
docker restart 容器id
docker stop 容器id  会等10s在停止
docker kill 容器id  立刻停止
```



## 容器启动后运行容器命令

```
docker exec -it 容器id【或者是名字】 /bin/bash
```

进入容器的命令行



## 查看容器的日志

```
docker logs 容器id
```

可以通过这个命令查看容器内部的log信息，比如说挂载U盘后，需要在U盘里存放东西，但是U盘是没有权限的，之前在3588的板子上也遇到过，就是无法执行命令。这种问题就可以通过log信息查看



## 在compose中设置entrypoint

```
services:
  vllm:
    image: 192.168.31.92:5000/arm64/vllm_arm:latest
    environment:
      - HTTP_PROXY=http://192.168.31.161.7899
      - HTTPS_PROXY=http://192.168.31.161:7899
    container_name: vllm_container
    ports:
      - "8000:8000"
    volumes:
      - /home/sophda/llmprojects:/home
    networks:
      - vllm_network
    entrypoint: ["/bin/bash", "-c", "tail -f /dev/null"]

networks:
  vllm_network:
```

如果在dockerfile中没有设置entrypoint或者是太简单了跑完直接容器exit了，那么可以在compose中覆盖掉原来的entrypoint，要加tail -f /dev/null这是挂住前台不让bash退出的

# Dockerfile

从dockerfile构建镜像

可能遇到的问题：

**pip报错： error: externally-managed-environment**

```
RUN mv /usr/lib/python3.12/EXTERNALLY-MANAGED /usr/lib/python3.12/EXTERNALLY-MANAGED.bk
```





# compose

这是一种运行多个容器的东东



## 使用docker-compose.yml

展示nextcloud的compose.yml

```
services:
  # 数据库服务
  db:
    image: mysql:latest                       # 使用最新版本的 MySQL 镜像
    container_name: nextcloud_mysql           # 自定义容器名称
    restart: always                           # 容器异常退出时自动重启
    environment:
      MYSQL_ROOT_PASSWORD: 666 # 定义 MySQL 的 root 用户密码
      MYSQL_PASSWORD: 666           # 定义 Nextcloud 用户的密码
      MYSQL_DATABASE: nextcloud               # 创建数据库，名为 nextcloud
      MYSQL_USER: nextcloud                   # 定义 MySQL 用户名
      TZ: Asia/Shanghai                       # 设置时区为上海
    volumes:
      - /media/sophda/d/nextcloud/db_data:/var/lib/mysql  # 将 MySQL 数据存储在主机的指定目录，实现持久化存储
    networks:
      - nextcloud_network                     # 连接到指定的网络

  # Nextcloud 应用服务
  app:
    image: nextcloud:latest                   # 使用最新版本的 Nextcloud 镜像
    container_name: nextcloud                 # 自定义容器名称
    restart: always                           # 容器异常退出时自动重启
    depends_on:
      - db                                     # 确保 db 服务先启动
    environment:
      MYSQL_DATABASE: nextcloud               # 使用与数据库服务相同的数据库名称
      MYSQL_USER: nextcloud                   # 使用与数据库服务相同的用户名
      MYSQL_PASSWORD: 666           # 使用与数据库服务相同的密码
      MYSQL_HOST: db                          # 数据库主机名为 db（即 db 服务）
      TZ: Asia/Shanghai                       # 设置时区为上海
    volumes:
      - /media/sophda/d/nextcloud/nextcloud_data:/var/www/html  # 将 Nextcloud 数据存储在主机的指定目录，实现持久化存储
    ports:
      - "20001:80"                             # 将容器的 80 端口映射到主机的 8080 端口
    networks:
      - nextcloud_network                     # 连接到指定的网络

  # OnlyOffice 文档服务
  onlyoffice:
    image: onlyoffice/documentserver:7.1.0     # 使用指定版本的 OnlyOffice 镜像
    container_name: nextcloud_onlyoffice       # 自定义容器名称
    restart: always                           # 容器异常退出时自动重启
    environment:
      JWT_ENABLED: 'false'                    # 关闭 JWT（无需密钥）
      JWT_SECRET:                             # 不设置 JWT 密钥
      TZ: Asia/Shanghai                       # 设置时区为上海
    ports:
      - "20002:80"                             # 将容器的 80 端口映射到主机的 8081 端口
    networks:
      - nextcloud_network                     # 连接到指定的网络

# 网络定义
networks:
  nextcloud_network:                          # 定义一个名为 nextcloud_network 的网络
# 卷定义，用于持久化存储数据
volumes:
  mysql_data:                                 # 定义 MySQL 数据的卷
  nextcloud_data:                             # 定义 Nextcloud 数据的卷

```



## 在compose中使用代理

这样在启动容器时，容器可以通过这个代理去访问网络

```
services:
  vllm:
    image: 192.168.31.92:5000/arm64/vllm_arm:qwen
    environment:
      - HTTP_PROXY=http://192.168.31.161.7899
      - HTTPS_PROXY=http://192.168.31.161:7899
    container_name: vllm_container
    ports:
      - "8000:8000"
    volumes:
      - /home/sophda/llmprojects:/home
    networks:
      - vllm_network

networks:
  vllm_network:

```



# harbor

## 配置网络

需要配置harbor的网址，否则会找不到的，报unreachable的问题

主要是配置insecure-registries这个地址

```
{
  "registry-mirrors": ["https://k1ktap5m.mirror.aliyuncs.com"],
  "insecure-registries": ["http://192.168.211.5:5000"]
}
```



## 标记容器

```
docker tag SOURCE_IMAGE[:TAG] 192.168.211.5:80/library/REPOSITORY[:TAG]
```



## 登录

```
docker login -u admin -p lupengda 192.168.31.92:5000
```





# vllm



## 跨平台构建



## 配置

```
 vllm serve Qwen/Qwen3-0.6B --max-model-len 500
```

