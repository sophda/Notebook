# Git

# 与本地服务器交互

## git add

添加文件到缓冲区

## git commit

提交分支

```
git commit -m "描述"
```

## git branch

创建分支

## git checkout

切换分支

## git merge

接下来咱们看看如何将两个分支合并到一起。就是说我们**新建一个分支，在其上开发某个新功能，开发完成后再合并回主线**。

```
//对于上面，综合应用
git branch newbranch
git checkout newbranch
git add ./src
git commit -m "2023/1/1"
git merge newbranch
git checkout master
//至此完成了本地git仓库的一次更新，后续要更新到gitee服务器上
```

# 与远程服务器交互

## git remote

添加远程仓库：

```
git remote add origin <仓库连接>
```

## git push

提交到远程服务器

```
git push origin master
```

## 远程提交分支

```
git branch new1 //创建一个分支
git push origin new1<分支名>
```

## 远程更新master

```
git checkout master
git add .
git commit -m ""
git push
```

**如果遇到**：`# error: failed to push some refs to ‘https://gitee.com/`

出现错误的主要原因是[gitee](https://so.csdn.net/so/search?q=gitee&spm=1001.2101.3001.7020)(github)中的README.md文件不在本地代码目录中,此时我们要执行

```
git pull --rebase origin master
```

命令README.md拉到本地，

任何然后执行

```
git push origin master
```

## 本地合并分支并推送master

一次更新，需要保存分支（方便回退版本）；同时需要更新master

```
git branch new2
git add .
git merge new2  //merge之后我的本地master也变了妈的
git push
```

最多保存分支，然后更新master

## 新建+提交分支

```
git branch node   //新建分支
git checkout node //切换分支
git add .         // 添加到缓存区
git commit -m ""  // 提交到本地git
git push origin node  // 提交到服务器
```





## .gitignore不起作用

其实这个文件里的规则对已经追踪的文件是没有效果的，所以我们需要使用 rm 命令清除一下相关的缓存内容，这样文件将以未追踪的形式出现，然后再重新添加提交一下 .gitignore 文件里的规则就可以起作用了。

```
git rm -r --cached .
git add .
git commit -m "update .gitignore"  // windows使用的命令时，需要使用双引号
```

