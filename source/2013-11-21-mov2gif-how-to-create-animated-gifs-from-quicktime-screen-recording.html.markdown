---
title: mov2gif&mdash;How to create animated gifs from QuickTime screen recording
date: 2013-11-21 22:01 UTC
tags: ruby
meta_keywrods: how to, gif, animated gif, animated gifs, github, mov2gif, quicktime, screencast, screen recording
---

Everybody loves animated GIFs. But what's even better is the ability to turn your screencast into one. I'm pretty sure that when working with GitHub, you use pull-requests very often. The ability to quickly attach an image when showing what's included is very useful. But what if you could also include a short video showing how it works in action?

## mov2gif

`mov2gif` is a simple script that uses two command line tools to convert a QuickTime movie into a gif. You will need `ffmpeg` and `imagemagick`.

```
$ brew install ffmpeg
$ brew install imagemagick
```

Now let's record a screencast. In QuickTime you pick the `New Screen Recording` option:

![QuickTime: New Screen Recording](/images/articles/mov2gif/new-screen-recording.png)

Next we simply record our screen.

![QuickTime: Record your screen](/images/articles/mov2gif/screen-recording.png)

After saving the file as MOV, we can convert it with our script:

```
$ ~/bin/mov2gif.rb ~/Documents/Changing\ Branches.mov ~/Documents/branches.gif
Processing: /Users/piotr/Documents/Changing Branches.mov -> /Users/piotr/Documents/branches.gif, {:fps=>15, :loop=>true}
Executing ffmpeg -loglevel quiet -i /Users/piotr/Documents/Changing Branches.mov -r 15 /var/folders/y3/73m4d5gs6xdbyjrxkmkwcj9r0000gn/T/mov2gif.rb20131121-83782-1761a1l/%5d.png
Executing convert -loop 0 -delay 1x15 /var/folders/y3/73m4d5gs6xdbyjrxkmkwcj9r0000gn/T/mov2gif.rb20131121-83782-1761a1l/*.png /Users/piotr/Documents/branches.gif
```

And that's it. We can simply drag and drop our newly created gif into the pull-request comment form!

![mov2gif converted gif](/images/articles/mov2gif/branches.gif)

The script can be downloaded on [GitHub Gist](https://gist.github.com/pusewicz/7590942).

Other similar scripts:

* [mov2gif.py](https://gist.github.com/motoishmz/7092877)
