## 乱码
在使用`git status`查看workspace中的状态时，中文文件名总会显示成乱码。
![](images/git_status_乱码.png)
```bash
git config --global core.quotepath false
```

![](images/git_status_乱码_1.png)

Reference: [git status 显示中文和解决中文乱码](https://blog.csdn.net/u012145252/article/details/81775362)


## 删除hooks
> 如果你在使用 Visual Studio Code，并且它不停地自动提交 commit，可能是由于你安装了一些自动化插件或配置了 Git 钩子（hooks）导致的。
> 以下是一些可能的原因和解决方法：
> 自动化插件：检查你安装的 Visual Studio Code 插件，特别是与 Git 相关的插件。某些插件可能会自动化提交更改，你可以尝试禁用这些插件或者调整它们的配置。
> Git 钩子（Hooks）：检查你的项目是否配置了 Git 钩子，在提交时执行了某些自动化操作。你可以查看 .git/hooks 目录中是否有设置了提交钩子。如果有的话，你可以编辑或者删除这些钩子。
> 自动保存设置：检查 Visual Studio Code 的自动保存设置。在 VS Code 的设置中，搜索 autoSave ，确保它设置为 off 或者其他不是 onWindowChange 或 afterDelay 的选项。
> Git 设置：检查你的 Git 全局设置或者项目的 Git 配置，确保没有配置自动提交的选项。你可以使用命令 git config --list 查看你的 Git 配置。
> 其他可能的原因：如果以上方法都没有解决问题，那可能是由于其他原因导致的。你可以尝试暂时禁用 Git 插件或者使用其他编辑器来确认问题是否与 Visual Studio Code 相关。
> 希望以上方法能帮助你解决问题。

Run the following command inside project's root directory to remove hooks:
```
rm -rf .git/hooks
```

* [How to remove git hooks](https://stackoverflow.com/questions/39963695/how-to-remove-git-hooks)