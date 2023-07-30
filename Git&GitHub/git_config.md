## 1. `git config`配置
在Git中，我们使用`git config`命令来配置Git的配置文件。Git配置级别主要由以下3类：
1. 仓库级别(local, 优先级最高)。Git仓库级别对应的配置文件是当前仓库下的`.git/config`
2. 用户级别(global, 优先级次之)。Git用户级别对应的配置文件是用户主目录下的`~/.gitconfig`
4. 系统级别(system, 优先级最低)。Git系统级别对应的配置文件是`/etc/gitconfig`，但是我并没有配置过此级别的配置文件，也没有此文件。

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

    对于git来说，配置文件的权重是仓库>全局>系统。Git会使用这一系列的配置文件来存储你定义的偏好，它首先会查找`/etc/gitconfig`文件（系统级），该文件含有对系统上所有用户及他们所拥有的仓库都生效的配置值。接下来Git会查找每个用户的`~/.gitconfig`文件（全局级）。最后Git会查找由用户定义的各个库中Git目录下的配置文件``.git/config`（仓库级），该文件中的值只对当前所属仓库有效。

## References
* [git config配置](https://www.cnblogs.com/fireporsche/p/9359130.html)