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

## Reference
* https://ohmyz.sh/
* [What is the difference between test, \[ and \[\[ ?](https://mywiki.wooledge.org/BashFAQ/031)
* [Are double square brackets \[\[ \]\] preferable over single square brackets \[ \] in Bash?](https://stackoverflow.com/questions/669452/are-double-square-brackets-preferable-over-single-square-brackets-in-b?noredirect=1&lq=1)