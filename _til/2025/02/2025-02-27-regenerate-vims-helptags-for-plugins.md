---
layout: til
title: Regenerate Vim's helptags for plugins
date: 2025-02-27 10:26:32 +0100
tags: [vim]
---

When you install a new plugin for Vim, you might need to regenerate the helptags to make the documentation available. You can do this by running `:helptags ALL` in Vim. This will generate the tags for all directories in your `runtimepath`.

```vim
:helptags ALL
```
