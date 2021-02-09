+++
draft = true
date = 2021-02-08T21:38:38Z
title = "Git Advanced Technique"
description = "Advanced technique with Git"
slug = ""
authors = ["Nicolas VION"]
tags = ["git", "advanced", "rebase", "merge", "squash"]
categories = ["git", "advanced", "rebase", "merge", "squash"]
externalLink = ""
series = []
+++

# Introduction

This article will present you some advanced techniques using Git:
  * Squash our last commits together
      * Rebase method
          * TIP: Undo a rebase
      * Squash method
          * TIP: Merge into master with new commits on this branch

# Squash you commits !

Imagine you have the following git repository:
  * **2 branches**:
      * **master** : 2 commits
      * **bug_fix** : 3 commits

![Git Squash](../../images/git_squash_01.png)

We want to merge all our commits in the bug_fix branches. We have two
solutions :
  * **rebase**
  * **merge --squash**

## Rebase method

The first solution uses **rebase**. Here is how to proceed:

```bash
git checkout bug_fix
git rebase -i 6bf1ea6
```

A new prompt will open. We then replace all the **pick** occurence except the
first one, and we save.

```bash
pick bc4e2e5 Accessibility bug fix
squash e80a149 Updated screenreader attributes
squash cc4d904 Added comments & updated README
...
```

A new window will open in order to enter the commit message we want. Once we
have saved our message, we can check the resulting commit via:

```bash
git log
bf212c6 (HEAD -> bug_fix) This is my new commit [Nicolas VION]
6bf1ea6 (master) m2 [Nicolas VION]
028c30c m1 [Nicolas VION]
```

Finally, we can push our branch:

```bash
git push origin --force bug_fix
```

### TIP: Undo a rebase

We will use the **reflog** command to identify where to reset our branch:

```bash
git reflog
```

**Result**:

```bash
bf212c6 (HEAD -> bug_fix) HEAD@{0}: rebase (finish): returning to refs/heads/bug_fix
bf212c6 (HEAD -> bug_fix) HEAD@{1}: rebase (squash): This is my new commit
5c5bc81 HEAD@{2}: rebase (squash): # This is a 2 commits combination
bc4e2e5 HEAD@{3}: rebase (start): checkout 6bf1ea6
cc4d904 HEAD@{4}: commit: Added comments & updated README
e80a149 HEAD@{5}: checkout: moving from master to bug_fix
6bf1ea6 (master) HEAD@{6}: checkout: moving from bug_fix to master
e80a149 HEAD@{7}: commit: Updated screenreader attributes
bc4e2e5 HEAD@{8}: commit: Accessibility bug fix
6bf1ea6 (master) HEAD@{9}: checkout: moving from master to bug_fix
6bf1ea6 (master) HEAD@{10}: commit: m2
028c30c HEAD@{11}: commit (initial): m1
```

In our case, we want to apply the commit "Added comments & updated README":

```bash
git reset --hard HEAD@{4}
```

**Result**:

```bash
❯ git ls
cc4d904 (HEAD -> bug_fix) Added comments & updated README [Nicolas VION]
e80a149 Updated screenreader attributes [Nicolas VION]
bc4e2e5 Accessibility bug fix [Nicolas VION]
6bf1ea6 (master) m2 [Nicolas VION]
028c30c m1 [Nicolas VION]
```

To come back to the origin HEAD (rebase origin state):

```bash
git reset --hard ORIG_HEAD
```

## Merge Method

We start with reseting the current branch to the commit before the last 3:

```bash
git reset --hard HEAD~3
```
And we merge and commit:

```bash
git merge --squash HEAD@{1}
git commit -m 'This is my new commit'
```
**Result**:

```bash
git ls
b60c85b (HEAD -> bug_fix) This is my new commit [Nicolas VION]
6bf1ea6 (master) m2 [Nicolas VION]
028c30c m1 [Nicolas VION]
```

## Merge into master with new commits on this branch

Imagine we have a new commit on master:

```bash
git ls
68f2d77 (HEAD -> master) new commit to master [Nicolas VION]
6bf1ea6 m2 [Nicolas VION]
028c30c m1 [Nicolas VION]
```

First, we need to get the last commit of the master branch:

```bash
git checkout bug_fix
git rebase -i master
```

Result of the **bug_fix branch**:

```bash
git ls
0ddd702 (HEAD -> bug_fix) This is my new commit [Nicolas VION]
68f2d77 (master) new commit to master [Nicolas VION]
6bf1ea6 m2 [Nicolas VION]
028c30c m1 [Nicolas VION]
```

Finally, we merge into master. Please note that we need to be in the **target
branch**:

```bash
git checkout master
git merge bug_fix
```

Result of the **master branch**:

```bash
git ls
0ddd702 (HEAD -> master, bug_fix) This is my new commit [Nicolas VION]
68f2d77 new commit to master [Nicolas VION]
6bf1ea6 m2 [Nicolas VION]
028c30c m1 [Nicolas VION]
```

Finally, we can push our branch:

```bash
git push origin --force bug_fix
```

> **Note**: you can use **--force-with-lease** instead of **--force**. This
> option allow to not override our friends' commits in case of error.

![Git push force](../../images/git_push_force.jpg)
