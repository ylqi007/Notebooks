# Sublime 安装与配置

## 通过 Homebrew 安装
### Option 1. 通过 Homebrew 安装
```shell
brew install --cask sublime-text
```

### Option 2. 从官网下载安装


## 添加alias
1. 创建 `~/.zsh_alias` 文件，存放所有要添加的alias
2. 将打开 Sublime 的 alias 添加到  `.zsh_alias` 中
3. 在 `.zshrc` 中引入 `~/.zsh_alias` 文件
    ```
    #################################################################
    # Example aliases
    # alias zshconfig="mate ~/.zshrc"
    # alias ohmyzsh="mate ~/.oh-my-zsh"
    #################################################################
    [[ -f ~/.zsh_alias ]] && source ~/.zsh_alias
    ```


## Merge all tabs to one window
To consolidate all tabs from multiple windows into a single window in Sublime text, you can use a plugin specifically designed for this purpose.

Step 1: Using `Package Control` to install plugin `Merge Window`

1. Open the Command Palette (`Ctrl + Shift + P` (Win) or `Cmd + Shift + P` (Mac)). 
2. Type `Install Package` to open `Package Control: 


