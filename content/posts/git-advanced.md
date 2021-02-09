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

This article will present you some advanced techniques using Git.

# Squash you commits !

Imagine you have the following git repository:

![Git Squash](../../images/git_squash_01.png)

We want to merge all your commits in the bug_fix branches. We have two
solutions :
  * rebase
  * merge --squash

## Rebase

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

## Merge
