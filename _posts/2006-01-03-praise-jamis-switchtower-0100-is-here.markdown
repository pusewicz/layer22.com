---
layout: post
title: Praise Jamis! SwitchTower 0.10.0 is here!
date: 2006-01-03 18:00 +0100
tags: [ruby-on-rails]
redirect_from: /2006/01/03/praise-jamis-switchtower-0100-is-here/
---

Just following [Jamis Buck’s blog](http://jamis.jamisbuck.org/articles/2006/01/02/switchtower-0-10-0), new SwitchTower release is here. So go get it with:

```
gem install --include-dependencies switchtower
```

## Bugs Fixed

  - Handle SSH password prompts formatted like “someone’s password:”
  - Allow the sudo password to be reentered if it was entered incorrectly
  - Errors during checkout are now caught and reported early
  - Avoid timeouts on long-running commands
  - Add a small sleep during command processing to give the CP
