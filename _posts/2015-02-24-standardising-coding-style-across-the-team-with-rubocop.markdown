---
title: Standardising coding style across the team with RuboCop
date: 2015-02-24 21:45 UTC
tags: ruby
redirect_from: /2015/02/24/standardising-coding-style-across-the-team-with-rubocop/
---

As some of you realise, there are times when you open an old file containing code and you think "WTF". It's also very likely that it is a file that you have created months or even years ago, and completely forgot about it.

Some of the issues with code and people are that people have opinions. Some are more vocal than others, some are more passionate; some are plain silly. And it can be a pain, when you for the Nth time have a discussion about indentation, length of methods, naming conventions, hashrockets vs. new Ruby hash syntax, and all those silly things that really make no difference, but make people release their Krakens.

So I have an idea on how to improve the Standard™. [RuboCop](https://github.com/bbatsov/rubocop) is a great piece of software that can unobtrusively let you know about style problems within your code. It's fully configurable and comes with a vast collection of rules that one can enable and configure. You want hashrockets everywhere? No problem! You want new lines at the end of the file? Sure! Methods under 10 lines? Fuck yeah!

Now, I do realise that some of the rules within the [Ruby Styleguide](https://github.com/bbatsov/ruby-style-guide) are not fantastic, but I do believe that it's a great way to start unifying your team's codebase. It will make your lives easier, and writing code will be that much faster. The expectations when opening a file with code will be the same.

This is how RuboCop can work with your Vim:

![RuboCop in VIM with Syntastic](/images/articles/rubocop-in-vim.png)

It comes with plugins for Sublime Text, TextMate, Atom, what have you. There is also a hosted service at [HoundCI](https://houndci.com/) that checks your pull requests and posts comments about style improvements.

What's also great, that RuboCop has a built-in code upgrade tool. It will go through all your code and magically translate it to the style of our choosing. I've tried it, even on a big project and it works.

All it takes is just drop one [rubocop.yml](https://github.com/bbatsov/rubocop/blob/master/.rubocop.yml) file in our project and install the editor plugin or HoundCI.
