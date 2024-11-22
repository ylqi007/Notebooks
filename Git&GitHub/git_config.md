## 1. `git config`配置
在Git中，我们使用`git config`命令来配置Git的配置文件。Git配置级别主要由以下3类：
1. 仓库级别(local, 优先级最高)。Git仓库级别对应的配置文件是当前仓库下的`.git/config`
2. 用户级别(global, 优先级次之)。Git用户级别对应的配置文件是用户主目录下的`~/.gitconfig`
3. 系统级别(system, 优先级最低)。Git系统级别对应的配置文件是`/etc/gitconfig`，但是我并没有配置过此级别的配置文件，也没有此文件。

### a. 常用的`git config`命令
If you don't know how to use this command, then type in `git config` in command line to show the instructions

1. 查看仓库配置(必须要进入到具体的仓库中才可以查看)
    ```shell
    git config --local -l
    ```

2. 查看用户配置
    ```shell
    git config --global -l
    ```

3. 查看系统级别配置
    ```shell
    git config --system -l
    ```

4. 查看所有的配置信息(依次是系统级别、用户级别、仓库级别)
    ```shell
    git config -l
    ```

5. 常用的`git config`配置选项
* `git config -e`编辑配置文件
    * `git config --local -e` 编辑仓库级别配置文件
    * `git config --global -e` 编辑用户级别配置文件
    * `git config --system -e` 编辑系统级别配置文件
* `git config` 添加配置项目
    * `git config --global user.email “you@example.com”`
    * `git config --global user.name “Your Name”`
    * 上面的操作表示添加用户级别的配置信息，也就是说修改用户宿主目录下面的配置文件 (`~/.gitconfig`)

6. 配置文件是如何生效的？

    对于git来说，配置文件的权重是仓库>全局>系统。Git会使用这一系列的配置文件来存储你定义的偏好，它首先会查找`/etc/gitconfig`文件（系统级），该文件含有对系统上所有用户及他们所拥有的仓库都生效的配置值。接下来Git会查找每个用户的`~/.gitconfig`文件（全局级）。最后Git会查找由用户定义的各个库中Git目录下的配置文件`.git/config`（仓库级），该文件中的值只对当前所属仓库有效。

## References
* [git config配置](https://www.cnblogs.com/fireporsche/p/9359130.html)
* [A good starting point for ~/.gitconfig](https://gist.github.com/rab/4067067)

## My `~/.gitconfig`
```shell
$ git config --global -l
user.name=******
user.email=******
pull.rebase=true
fetch.prune=true
diff.colormoved=zebra
rebase.autostash=true
alias.lg=log --color --graph --pretty=format:'%Cgreen%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 10
core.excludesfile=/Users/******/.gitignore_global
difftool.sourcetree.cmd=opendiff "$LOCAL" "$REMOTE"
difftool.sourcetree.path=
mergetool.sourcetree.cmd=/Applications/Sourcetree.app/Contents/Resources/opendiff-w.sh "$LOCAL" "$REMOTE" -ancestor "$BASE" -merge "$MERGED"
mergetool.sourcetree.trustexitcode=true
filter.lfs.clean=git-lfs clean -- %f
filter.lfs.smudge=git-lfs smudge -- %f
filter.lfs.process=git-lfs filter-process
filter.lfs.required=true
color.branch=auto
color.diff=auto
color.status=auto
color.showbranch=auto
color.ui=auto
```

My `~/.gitconfig` in DevDesktop
```shell
(24-11-22 22:58:13 dev) <0> [~]
~ % cat .gitconfig
[user]
	email = qyunlon@amazon.com
	name = Yunlong Qi
[color]
	ui = auto
[core]
	pager = less -FMRiX
[push]
	default = simple
[alias]
	dag = log --graph --format='format:%C(yellow)%h%C(reset) %C(blue)\"%an\" <%ae>%C(reset) %C(magenta)%cr%C(reset)%C(auto)%d%C(reset)%n%s' --date-order
    lg = "log --color --graph --pretty=format:'%Cgreen%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 20"
    lg1 = log --format='%C(auto)%h %C(green)%aN%Creset %s' -n 20
[commit]
	template = /home/qyunlon/.gitmessage
[format]
    pretty = %C(auto)%h %C(green)%aN%Creset %s
[pull]
	rebase = true
[rebase]
	autostash = true
[log]
	number = 20
```


## Commands to config Git for a new device
```shell
cat .gitconfig

git config --global color.ui auto
git config --global core.pager "less -FMRiX"
git config --global push.default simple
git config --global alias.dag "log --graph --format='format:%C(yellow)%h%C(reset) %C(blue)"%an" <%ae>%C(reset) %C(magenta)%cr%C(reset)%C(auto)%d%C(reset)%n%s' --date-order"
git config --global alias.lg "log --color --graph --pretty=format:'%Cgreen%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 20"
git config --global pull.rebase true
git config --global rebase.autostash true
git config --global log.number 20
```