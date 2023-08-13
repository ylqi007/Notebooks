[TOC]

## 1. Branch
### 1. Create a new branch
```shell
# Create a new branch based on the current HEAD
git branch <new-branch>

# Create a new branch based on some existing one
git branch <new-branch> <base-branch>

# Create a new branch from a specific commit
git branch <branch_name> <commit-hash>

# Create a new branch using a symbolic reference
git branch <branch_name> HEAD~3

# Create a new branch and check out the new branch 
git checkout -b <branch_name> <commit-hash or HEAD~3>
```

* [How do I create a new branch in Git?](https://www.git-tower.com/learn/git/faq/create-branch)
* [Branch from a previous commit using Git](https://stackoverflow.com/questions/2816715/branch-from-a-previous-commit-using-git)
* [What is the difference between "git branch" and "git checkout -b"?](https://stackoverflow.com/questions/7987687/what-is-the-difference-between-git-branch-and-git-checkout-b)


### 2. Delete a branch
```shell
# Delete branch locally
git branch -d <lobal_branch_name>
git branch -D <local_branch_name>

# Delete branch remotely
git push origin --delete <remote_branch_name>
git branch -dr <remote_branch_name>
```
`error: The branch 'xxx' is not fully merged` is actually a warning. It means the branch you are about to delete contains commits that are not reachable from any of: its upstream branch, or HEAD (currently checked out revision). In other words, when you might lose commits.

Reference:
* [How to Delete a Git Branch Both Locally and Remotely]([https://www.freecodecamp.org/news/how-to-delete-a-git-branch-both-locally-and-remotely/#:~:text=Deleting a branch LOCALLY&text=Delete a branch with git branch -d .&text=The -d option will delete,branch is now deleted locally.)](https://www.freecodecamp.org/news/how-to-delete-a-git-branch-both-locally-and-remotely/#:~:text=Deleting%20a%20branch%20LOCALLY&text=Delete%20a%20branch%20with%20git%20branch%20%2Dd%20.&text=The%20%2Dd%20option%20will%20delete,branch%20is%20now%20deleted%20locally.))
* [Git "error: The branch 'x' is not fully merged"](https://stackoverflow.com/questions/7548926/git-error-the-branch-x-is-not-fully-merged)


### 3. Rename a branch
```shell
# If you are in the same branch
git branch -m "new_name"

# If you are in a different branch
git checkout -m "old_name" "new_name"
```
* [How to rename a branch in git](https://www.educative.io/answers/how-to-rename-a-branch-in-git?utm_campaign=brand_educative&utm_source=google&utm_medium=ppc&utm_content=performance_max&eid=5082902844932096&utm_term=&utm_campaign=%5BNew%5D+Performance+Max&utm_source=adwords&utm_medium=ppc&hsa_acc=5451446008&hsa_cam=18511913007&hsa_grp=&hsa_ad=&hsa_src=x&hsa_tgt=&hsa_kw=&hsa_mt=&hsa_net=adwords&hsa_ver=3&gclid=Cj0KCQiA37KbBhDgARIsAIzce14d2f9W5zGdZnOeSK2B9lRWzTSq2SiTjW9z0yrq1zzwpXCd_I6SB5MaAuKnEALw_wcB)



## 2. Commits
### 2.1 Pull the latest changes from remote
```shell
# Pull in the changes co-workers pushed to the remote repository and rebase commits
git pull --rebase
git pull --rebase --autostash

# Checkout the local feature branch, and rebase on mainline
git checkout featureBranch
git rebase mainline
```
* https://git-scm.com/docs/git-pull


### 2.2 Squash Commits into one
**Step 1**: The first thing is to invoke git to start an interactive rebase session:
```shell
git rebase --interactive HEAD~N
git rebase -i HEAD~N
```
**Note**: `N` is the number of commits you want to join, starting from the most recent one.

A downside of the `git rebase -i HEAD~N` command is that you have to guess the exact number of commits, by counting them one by one. Luckily, there is another way:
```shell
git rebase --interactive [commit-hash]
git rebase -i [commit-hash]
```
**Note**: `[commit-hash]` is not included. The above command would merge all commits on top of commit `[commit-hash]`.

**Step 2**: Picking and squashing

**Step 3**: Create the new commit


### 2.3 Revert a single file
```shell
git checkout [commit ID] -- path/to/file
git checkout ac12345 -- frontend/src/App.js
```
The following will checkout the `build.xml` file to the first parent commit
without `--`?

```shell
git checkout HEAD~1 -- build.xml
```
After reverting the file to a previous screenshot (i.e. referred by commit ID), we need to commit that change by
```shell
git commit -m 'commit message'
git commit --amend
```
* https://dev.to/lofiandcode/git-and-github-how-to-revert-a-single-file-dha
* [Can I delete a git commit but keep the changes?](https://stackoverflow.com/questions/15772134/can-i-delete-a-git-commit-but-keep-the-changes)



## 3. Rebase
### 3.1 How does Git `rebase` work?
Git `rebase` is the process of updating a series of commits of an existing branch to a new base commit.


## 4. Cherry Pick
```shell
git cherry-pick -n <HASH>
```
* [Git: Cherry-Pick to working copy without commit](https://stackoverflow.com/questions/32333383/git-cherry-pick-to-working-copy-without-commit)


## Check the difference
### How to compare files from two different branches?

* [How to compare files from two different branches](https://stackoverflow.com/questions/4099742/how-to-compare-files-from-two-different-branches)

```
git diff HEAD~1 HEAD --name-only

```

* `HEAD~1` means the previous commit of the last commit.


## 5. Renaming a reposiroty
You can rename a repository if you're either an organization owner or have admin permissions for the repository. 

When you rename a repository, all existing information, with the exception of project site URLs, is automatically redirected to the new name, including:
* Issues
* Wikis
* Stars
* Followers

In addition to redirecting web traffic, all `git clone`, `git fetch`, or `git push` operations targeting the previous location will continue to function as if made on the new location. 
However, to reduce confusion, we strongly recommend updating any existing local clones to point to the new repository URL. 
You can do this by using `git remote` on the command line:
```shell
git remote set-url origin NEW_URL
```

* [Renaming a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository)


## Appendix
### 1. `HEAD`
#### 1.1 What is Git `HEAD`?
The `HEAD` in Git is a file that references the current branch you are currently. Hence, if you are currently are in a mainline branch, the `HEAD` will have as a reference the mainline branch. If you checkout a different branch called styles, the `HEAD` reference will be updated to the styles branch.

#### 1.2 What's Git `HEAD^` (with caret)?
Git `HEAD^` (Git HEAD followed by a caret) is a shorten for git `HEAD^1`. Git `HEAD^1` means the commit's first parent. Hence, Git `HEAD^2` means the current commit's second parent.

#### 1.3 What's Git `HEAD~` (with tilde)?
Git `HEAD~` (Git HEAD followed by a tilde) is a shorthand for Git `HEAD~1`. Git `HEAD~1` means the previous commit of the last commit. Contrary to using the caret (^), Git `HEAD~` is simpler to understand as it references the previous commit of a specific branch.
* `HEAD~1` means go backward in a straightline. 

#### 1.4 What's Git `HEAD@{}` (with at symbol)?
Git `HEAD@{}` (Git `HEAD`` followed by the at symbol and curly braces displays where the reference of HEAD was pointing at different times in the local repository. If you saw `HEAD@{}` , you probably used the reflog git command. The reflog shows the reference logs.

[What is Git HEAD? A Practical Guide Explained with Examples](https://www.becomebetterprogrammer.com/git-head/#:~:text=Git)
