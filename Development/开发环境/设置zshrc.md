# 设置zshrc

## 1. 安装Oh My ZSH
* https://ohmyz.sh/

## 2. 添加alias
安装Oh My ZSH之后，`.zshrc`文件的comment中有添加aliases的方法。

此处，仅列出我使用的一种方法。
### 1. 创建zsh_alias文件: `/Users/<userName>/.oh-my-zsh/custom/zsh_aliases`
```shell
alias cdw="cd ~/Work"

alias ga="git add -u"
alias gs="git status"
alias gd="git diff"
alias gb="git branch"
```

### 2. 在`.zshrc`文件中引入zsh_alias文件
```shell
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Add alias
[[ -f $ZSH/custom/zsh_aliases ]] && source $ZSH/custom/zsh_aliases
```

### 3. Reload `.zshrc`
After saving `.zshrc`, you need to apply the changes:
```shell
source ~/.zshrc
```

### 4. 添加plugins
关于 oh-my-zsh 插件的管理是很简单的，有两个插件目录，其中 user 为你的用户名：
* `/Users/user/.oh-my-zsh/plugins`: oh-my-zsh 官方插件目录，该目录已经预装了很多实用的插件，只不过没激活而已；
* `/Users/user/.oh-my-zsh/custom/plugins`: oh-my-zsh 第三方插件目录；快捷命令：`$ZSH_CUSTOM/plugins`

需要安装哪个插件，只需要把插件下载到上面任何一个目录即可，然后在 `~/.zshrc` 配置文件中的 plugins 变量中添加对应插件的名称即可。

* `zsh-syntax-highlighting`: https://github.com/zsh-users/zsh-syntax-highlighting
* `zsh-autosuggestions`: https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md

安装plugins `zsh-autosuggestions` and `zsh-syntax-highlighting`
```shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

在`.zshrc`中配置这两个plugins
```shell
plugins=( 
    # other plugins...
    zsh-syntax-highlighting
    zsh-autosuggestions
)
```
当输入错误的命令时，命令会以红色现实，说明当前输入的命令是错的。

* Plugin `z`: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z

## Reference
* https://ohmyz.sh/
* [What is the difference between test, \[ and \[\[ ?](https://mywiki.wooledge.org/BashFAQ/031)
* [Are double square brackets \[\[ \]\] preferable over single square brackets \[ \] in Bash?](https://stackoverflow.com/questions/669452/are-double-square-brackets-preferable-over-single-square-brackets-in-b?noredirect=1&lq=1)
* [终端环境：zsh 、oh-my-zsh、提示主题与 7 效率插件](https://www.poloxue.com/posts/2023-10-16-zsh-themes-and-plugins/)