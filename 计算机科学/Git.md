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
