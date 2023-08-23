---
title:
  Configure MacVim to Automatically Switch Colorschemes Based on macOS Dark or
  Light Theme
date: 2023-08-23 15:08 +0200
tags: vim
---

## Introduction

MacVim is a powerful text editor that can be customized to suit your preferences. One of the ways to enhance your MacVim experience is by configuring it to change its colorscheme based on the macOS dark or light theme. In this blog post, I will guide you through the process of setting up MacVim to automatically switch colorschemes depending on your macOS theme.

Code for your `.vimrc`:

```viml
let g:light_theme = 'dayfox'
let g:dark_theme = 'nightfox'

func! s:ChangeBackground()
    let s:theme = g:light_theme

    if (v:os_appearance)
        let s:theme = g:dark_theme
        set background=dark
    else
        set background=light
    endif

    execute 'colorscheme ' . s:theme

    " Ensure we re-init lightline
    let g:lightline.colorscheme = s:theme
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()

    redraw!
endfunc

call s:ChangeBackground()

augroup AutoDark
autocmd!
autocmd OSAppearanceChanged \* call s:ChangeBackground()
augroup END
```

## What does it all do?

First, define the light and dark colorschemes you wish to use. In the example code, I'm using 'dayfox' for the light theme and 'nightfox' for the dark theme. You can replace these with any other colorschemes you prefer.

```viml
let g:light_theme = 'dayfox'
let g:dark_theme = 'nightfox'
```

Next, create a function called `s:ChangeBackground()` to handle the colorscheme change based on the macOS theme setting. This function will:

- Set the default colorscheme to the light theme.
- Check the value of `v:os_appearance`. If it's true (1), macOS is set to dark mode, and the dark theme will be used. Otherwise, the light theme will be used.
- Apply the chosen colorscheme and update the lightline colorscheme accordingly.
- Call the necessary lightline functions to initialize, set the colorscheme, and update the status line.

```viml
func! s:ChangeBackground()
    let s:theme = g:light_theme

    if (v:os_appearance)
        let s:theme = g:dark_theme
        set background=dark
    else
        set background=light
    endif

    execute 'colorscheme ' . s:theme

    " Ensure we re-init lightline
    let g:lightline.colorscheme = s:theme
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()

    redraw!
endfunc
```

Call the `s:ChangeBackground()` function to set the initial colorscheme based on the current macOS theme.

```viml
call s:ChangeBackground()
```

Finally, create an autocommand group called `AutoDark` that will listen for the `OSAppearanceChanged` event. When the event is triggered, the `s:ChangeBackground()` function will be called, and the colorscheme will be updated accordingly.

```viml
augroup AutoDark
autocmd!
autocmd OSAppearanceChanged * call s:ChangeBackground()
augroup END
```

## Conclusion

By following these steps and using the provided example code, you can configure MacVim to automatically switch between light and dark colorschemes based on the macOS theme.
