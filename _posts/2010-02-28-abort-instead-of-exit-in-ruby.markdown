---
title: Abort instead of exit in Ruby
date: 2010-02-28 23:14 +0100
tags: [ruby]
redirect_from: /post/418511103/abort-instead-of-exit-in-ruby
---

Are you familiar with this code?

```ruby
if error?
  puts "Sorry, error occured..."
  exit 1
end
```

Just replace that with:

```ruby
abort "Sorry, error occured..." if error?
```

Simple and beautiful.
