+++
draft = true
date = 2021-02-09T21:38:38Z
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
git rebase -i the_commit_before_the_commit_we_want
```

A new prompt will open. We then replace all the **pick** occurence except the
first one, and we save.

```bash
pick 7f9d4bf Accessibility fix for frontpage bug
squash 3f8e810 Updated screenreader attributes
squash ec48d74 Added comments & updated README

# Rebase 4095f73..ec48d74 onto 4095f73 (3 commands)
...
```

A new window will open in order to enter the commit message we want. Once, we
have saved our message, we can check the resulting commit via:

```bash
git log
```

Finally, we can push our branch:

```bash
git push origin --force bug_fix
```

## Merge
