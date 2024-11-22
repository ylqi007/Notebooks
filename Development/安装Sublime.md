# 添加alias

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