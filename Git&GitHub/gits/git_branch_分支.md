## `git branch`
List, create, or delete branches.

### 1. 查看分支
```shell
# 1. 查看本地分支
git branch

# 2. 查看远程分支
git branch -r
git branch --remotes 

# 3. 查看本地和远程所有分支
git branch -a
git branch --all

# 4. 查看本地与远程分支的关联情况
git branch -v
git branch -vv  # 可以展示关联的远程分支名
```


### 2. 新建分支
```shell
# 1. 基于当前分支创建新分支，但并不切换分支
git branch <new-branch>

# 2. 基于当前分支创建新分支，并切换到新分支
git checkout -b <new-branch>

# 3. 基于某个commit、分支or标签创建新分支
git branch <branch-name> <commit-id>

# 4. 创建新分支，与指定的远程分支建立追踪关系
git branch --track <branch-name> <remote-branch>
```


### 3. 关联远程分支
> -u <upstream>, --set-upstream-to=<upstream>
    Set up <branchname>'s tracking information so <upstream> is considered <branchname>'s upstream
    branch. If no <branchname> is specified, then it defaults to the current branch.
```shell
# 1. 设置追踪的远程分支
git branch -u <branch-name>

# 2. 设置远程仓库，并同时push到远程仓库
git push -u origin/<branch-name>
git push --set-upstream origin/<branch-name>
```


### 4. 切换分支
```shell
# 切换到指定的远程分支
git checkout <branch-name>
```

### 5. 修改分支
`-m, --move`表示移动或重命名和相应的引用日志。
```shell
# 修改指定的分支名称
git branch -m <old_name> <new_name>
```


### 5. 删除分支
```shell
# 1. 删除分地分支
git branch -d <local-branch-name>

# 2. 删除远程分支
git push origin --delete <branch-name>
git branch -dr [remote/branch]

## 示例
git push origin --delete origin/feature
git branch -dr origin/feature

# 3. 删除后推送到远程仓库
git push origin:<branch-name>
```

-r, --remotes
   List or delete (if used with -d) the remote-tracking branches. Combine with --list to match the
   optional pattern(s).



### Reference
* [分支 git branch](https://tsejx.github.io/devops-guidebook/code/git/branch)