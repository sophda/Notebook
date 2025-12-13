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

一个邮箱对应着一个**git**账号

## git remote

添加远程仓库：

```
git init
git add .
git commit -m "first"
git remote add origin <仓库连接>
```

## git push

提交到远程服务器

```
git push origin master
```

## 用户配置

主要是gitee这个网站是根据邮箱地址来给你参与仓库贡献的，所以说，你本地的邮箱地址和gitee端的邮箱地址不同的话，是会导致你一个仓库中有两个人贡献的。所以最好是把本地的邮箱地址改过来。

```
git config --global user.email 修改后的邮箱
git config --global --replace-all user.email 你的邮箱
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
git commit -m "update .gitignore2"

// windows使用的命令时，需要使用双引号
```



##  回滚操作

```
使用git log命令，查看分支提交历史，确认需要回退的版本
使用git reset --hard commit_id命令，进行版本回退
使用git push origin命令，推送至远程分支
```

快速操作：

```
回退上个版本：git reset --hard HEAD^ 
【注：HEAD是指向当前版本的指针，HEAD^表示上个版本,HEAD^^表示上上个版本】
```



## 文件太大了，被服务器拒绝了



---

​                                                                                          **ABORTED**

1. 按照提示，找出大文件

   ```
   git rev-list --objects --all | grep 90b39f4470e405ed852e517a73473b527ac60eaa
   ```

   会返回一个具体的路径以及文件名

2. 执行命令，忽视这个大文件，或者直接`git rm -r --cached .`

   ```
   git rm --cached file_name // 这个file_name些grep出来的文件名，不要是那一串代码
   #如果是文件夹
   git rm -r --cached directory_name
   ```

3. 在.gitignore中添加要忽略的文件（不知道管不管用）

4. 因为在push的过程中提示的**服务器拒绝大文件**，所以之前肯定是已经`commit`过的，所以要删除commit中的文件

   ```
   git filter-branch --tree-filter 'rm -f 文件名' HEAD
   ```

5. 然后执行`push`

---

**更新版：**

1.首先查看commit中大文件：

```
# 查看所有提交中文件大小排名前20的记录
git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -20 | awk '{print$1}')"
```

2.找到大文件之后使用下面的命令删除

```
git filter-branch --force --prune-empty --index-filter \
'git rm -rf --cached --ignore-unmatch ORB_SLAM3/Thirdparty/g2o/lib/libg2o.so' \
--tag-name-filter cat -- --all
```

3.在完成上面的命令之后，这些文件并没有直接被删除（可以用count-objects查看一下pack体积，并没有发生变化），然后执行下面的命令，用gc命令来删除


```
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

4.最后查看一下体积


```
git count-objects -vH
```

5.提交(将本地所有的分支都提交到云服务器上)

```
git push --all origin -u
```



# github

## 颜色说明

颜色说明

> 蓝色代表相同代码，他会自动帮你折叠
>
> 红色代表被修改的代码
>
> 绿色为修改后的代码
>
> 灰色空白表示消失的代码



## 多人合作

> 前情提要：我是 A，和 B 一起有一个 git 仓库，在同一个 commit 之后进行开发，他实现了需求 1，并且提交了，而我实现了需求 2，但我的本地没有他的代码，我怎么合并他的更改并提交呢



### 重要前提：先提交你的本地更改

在执行任何合并操作之前，请确保你本地“需求 2”的代码已经**提交（commit）**了。

**因为pull中的（fetch+merge）是针对的两个commit进行的，如果不提交的话，本地的修改只能是dirty work，也就是无法参与合并的。**

```
# 查看你修改了哪些文件
git status

# 添加所有更改
git add .

# 提交你的 "需求 2"
git commit -m "A 实现了需求 2"
```

------



### 方案一：使用 `rebase`（变基） (推荐)



这个方法会“拉取”B 的提交，然后把你（A）的提交**“重新播放”**到 B 的提交之上。

优点： Git 历史会保持为一条直线，非常干净，没有多余的“合并节点”。

缺点： 如果遇到冲突，解决起来会比 merge 稍麻烦一点点（但逻辑是清晰的）。



#### 操作步骤：



1. 拉取 B 的代码并执行 Rebase

   假设你们都在 main 分支上开发，并且远程仓库叫 origin：

   Bash

   ```
   # 拉取远程 main 分支的最新内容，并把你的本地提交（需求 2）“变基”到它上面
   git pull --rebase origin main
   ```

2. **处理后续情况（二选一）**

   - 情况 A：一切顺利（无冲突）

     命令执行完毕，Git 会提示你 Successfully rebased and updated...。

     此时你的本地历史已经变成了： [共同的 Commit] -> [B 的需求 1] -> [A 的需求 2]

   - 情况 B：遇到冲突（Conflict）

     Git 会停下来，提示你存在冲突（CONFLICT (content): Merge conflict in ...）。

     不要慌，按以下步骤操作：

     a. 打开提示冲突的文件（VS Code 等编辑器里会高亮显示）。

     b. 手动修改文件，解决冲突（即保留你们俩都想要的代码，删除 Git 留下的标记，如 <<<<< >>>>>）。

     c. 保存文件后，执行 git add .（标记冲突已解决）。

     d. 继续 Rebase：

     bash git rebase --continue 

     e. (如果中途想放弃，可以执行 git rebase --abort 来撤销一切)。

     f. 如果你（A）有多个 commit，可能会需要重复 b、c、d 步骤几次。

3. 推送你的代码

   当 rebase 成功完成后，你就可以把包含 B 代码 和 你代码的最终版本推送到远程仓库了。

   Bash

   ```
   git push origin main
   ```

   （此时你本地分支已经领先于远程分支，可以直接推送）。

------



### 方案二：使用 `merge`（合并）



这个方法会“拉取”B 的提交，然后创建一个**新的“合并提交”**，把 B 的“需求 1”和你（A）的“需求 2”在本地融合。

优点： 操作简单，符合直觉。

缺点： 会在 Git 历史上留下一个 Merge branch 'main' of ... 这样的合并提交节点，如果团队成员都这样做，历史会变得很“乱”。



#### 操作步骤：



1. 拉取 B 的代码并执行 Merge

   （确保你的“需求 2”已经 commit）

   Bash

   ```
   # git pull 默认就是 fetch + merge
   git pull origin main
   ```

2. **处理后续情况（二选一）**

   - 情况 A：一切顺利（无冲突）

     Git 可能会自动打开一个编辑器（如 Vim）让你输入合并信息，通常直接保存退出即可。

   - 情况 B：遇到冲突（Conflict）

     a. Git 会提示你冲突，并停下来。

     b. 手动修改文件，解决冲突。

     c. 保存文件后，执行 git add .。

     d. 完成合并提交：

     bash git commit 

     （此时 Git 会自动生成一个合并信息，保存退出即可）。

3. 推送你的代码

   合并完成后，你的本地代码就同时包含了 A 和 B 的工作。

   Bash

   ```
   git push origin main
   ```

------



### 总结



为了保持一个清晰的、线性的提交历史，我强烈建议你使用**方案一（`git pull --rebase`）**。

**简而言之，你的完整操作流程（使用 Rebase）：**

Bash

```
# 1. (如果还没提交) 提交你的 "需求 2"
git add .
git commit -m "实现需求 2"

# 2. 拉取 B 的更改并变基
git pull --rebase origin main

# 3. (如果遇到冲突) 解决冲突后 -> git add . -> git rebase --continue

# 4. 推送
git push origin main
```
