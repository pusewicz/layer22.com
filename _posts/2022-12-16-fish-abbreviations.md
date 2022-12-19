---
layout: post
title: Fish abbreviations–what are they and how to configure them?
date: 2022-12-16 05:27 +0100
tags: fish
redirect_from: /2022/12/16/fish-abbreviations/
---

Fish [abbreviations](https://fishshell.com/docs/current/cmds/abbr.html) are a fantastic way to configure what is commonly known as aliases for your day-to-day use.

The difference between an alias and an abbreviation is that it expands to the entire command whenever the abbreviation gets triggered. Traditionally, aliases are shown as they are typed in the shell’s history.

The expansion is an excellent benefit of using abbreviations. One can always see the actual command behind the shorthand version. This is both useful for remembering the actual command and significant when sharing commands with others (such as in screenshots of the terminal), as they do not have to decode the aliases.

## Let's configure some abbreviations

We will edit the `~/.config/fish/conf.d/abbreviations.fish` file. Any file in the `~/.config/fish/conf.d` directory will be [automatically loaded](https://fishshell.com/docs/current/#configuration) in a standard `fish` setup. A separate file for abbreviations makes it easier to find the right place to configure them.

Below is the content of my file:

```fish
abbr be "bundle exec"

abbr ghb "gh browse" # Open the current repository on GitHub
abbr ghc "hub compare" # Open the diff of the branch on GitHub

abbr bu "brew upgrade"
```

As you can see, the syntax is similar to the [alias](https://fishshell.com/docs/current/cmds/alias.html). We use the `abbr` command, followed by the abbreviation we'd like to use. Finally, the actual command it should expand to.

To use the configured abbreviation, we need to type it, and either press <kbd>Enter</kbd> to expand and execute, or <kbd>Space</kbd> to only expand it, allowing us to add any arguments to the command.

Here's a demo:

[![asciicast](https://asciinema.org/a/wOt70n7TKym3ijKtFhwUUTSvd.svg)](https://asciinema.org/a/wOt70n7TKym3ijKtFhwUUTSvd)

Abbreviations add another touch of clarity to your own workflow. Switching from using aliases is trivial. To me, they are superior and a clear improvement.

## Bonus points

I've found [`fish-git-abbr`](https://github.com/lewisacidic/fish-git-abbr) plugin to be a fantastic collection of predefined abbreviations for `git` usage. It's got everything you might need when working with `git` and save some keystrokes. I have also learned some new `git` arguments!
