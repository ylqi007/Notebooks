# export命令
Linux `export` 命令为Shell内建命令，该命令用于设置或显示环境变量。

在shell中执行程序时，shell会提供一组环境变量。`export`可新增，修改或删除环境变量，供后续执行的程序使用。`export`的效力仅限于该次登陆操作。注销或者重新开一个窗口，`export`命令给出的环境变量都不存在了。
```shell
# 该命令语法
export [-fnp][变量名称]=[变量设置值]
```
其中:
* `-f`:　代表`[变量名称]`中为函数名称。
* `-n`:　删除指定的变量。变量实际上并未删除，只是不会输出到后续指令的执行环境中。
* `-p`:　列出所有的shell赋予程序的环境变量。

## Reference
* [Linux export 命令](https://www.runoob.com/linux/linux-comm-export.html)
* [说说shell脚本中的export 和 source，bash](https://www.cnblogs.com/flying-tiger/p/5616934.html)
* [Linux命令（49）——export命令（builtin）](https://cloud.tencent.com/developer/article/1365982)