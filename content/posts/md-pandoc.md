+++
draft = true
date = 2021-02-17T21:38:38Z
title = "Markdown to PDF using Pandoc"
description = "Markdown to PDF using Pandoc"
slug = ""
authors = ["Nicolas VION"]
tags = ["markdown", "pandoc", "pdf", "presentation", "beamer", "latex"]
categories = ["markdown", "pandoc", "pdf", "presentation", "beamer", "latex"]
externalLink = ""
series = []
+++

# Introduction

This posts will explain how to:
  * Create a presentation in **Markdown** using **Beamer** and **Pandoc**
  * Create a PDF documentation in **Markdown** using **Pandoc** and **Latex**

# Create a presentation in Markdown with Beamer

## Prerequisites

First of all, we will install these dependencies:

```bash
# software
brew install pandoc gnu-sed
brew cask install basictex

# latex packages
sudo tlmgr install titlesec background everypage pgfopts
```

Then, we will installed this excellent
[theme](https://github.com/matze/mtheme):

```bash
git clone https://github.com/matze/mtheme.git
cd mtheme && make sty
mkdir -p ~/Library/texmf/tex/latex/metropolis
mv *.sty ~/Library/texmf/tex/latex/metropolis
```

## Markdown content

We create a file with the following content:

```markdown
---
title:
- Presentation
author:
- Nicolas VION
theme:
- metropolis
---

# Introduction

## Sub Section 1

* List 1
```

To generate the presentation:

```bash
pandoc file.md -t beamer -o file.pdf
```

**Result**:

![Presentation from MD](../../images/md_presentation.png)

# Create a documentation in Markdown with Latex

First of all, we will clone this
[template](https://github.com/nicolasvion/docker/tree/master/doc-as-code):

```bash
git clone https://github.com/nicolasvion/docker/
cd doc-as-code
for file in src/*; do make $(basename $file); done
```

**Result**:

https://github.com/nicolasvion/docker/blob/master/doc-as-code/out/notes-2018-02-28.pdf
