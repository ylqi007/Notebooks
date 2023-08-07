# Rebase
`git rebase`的作用简要概括为：可以对某一段线性commit history进行编辑、删除、复制、粘贴。因此，合理使用`git rebase`命令可以使我们的提交历史干净、简洁！

⚠️ **注意:** 不用通过`rebase`对任何已经提交到公共仓库中的commit进行修改。

## 合并commits
目标：把当前branch上最后三个commits合并为一个commit
```shell
git rebase -i <start point> <end point>
```
* `-i`的意思是`--interactive`，即弹出交互式的界面让用户编辑完成合并操作。
* `<start point> <end point>`指定一个编辑区间(**前开后闭**，即`(start point, end point]`)。如果不指定`<end point>`，则该区间的终点默认是当前分支`HEAD`所指向的commit

或是
```shell
git rebase -i HEAD~3    # 个人比较喜欢这种方式
```

## 2. 将某一段commits粘贴到另一个分支上

我们可以通过`rebase`命令将一段commit history从一个分支复制到另一个分支上。
```shell
git rebase <start point> <end point> --onto <branch name>
```
* `<start point> <end point>`指定了一个编辑区间(前开后闭)
* `--onto <branch name>`是指定将选定的commit history复制到哪一个分支上

例子
```shell
git  rebase   90bc0045b   5de0da9f2   --onto master     # 此步复制完成后，当前HEAD处于游离状态
git checkout master
git reset --hard  0c72e64   # 将master所指向的提交id设置为当前HEAD所指向的提交id
```