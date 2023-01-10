---
title: Having problems with MySQL loosing connection?
date: 2006-04-07 14:05 +0100
tags: [ruby-on-rails, windows]
redirect_from: /2006/04/07/having-problems-with-mysql-loosing-connection/
---

Ah, I was so mad at my Windows dev box. I got problems with MySQL loosing connection almost every refresh of the rails app. But today, after creating a skeleton of a new Rails app, I went into database.yml and read that I should install a `mysql.so` for Ruby.

It didn’t take much time to download RubyForApache which contains a compiled version of this library.

It turned out that:

  - It stopped complaining about loosing a connection
  - It gained much speed in queries

So, whenever you get into trouble with MySQL in Windows, install RubyForApache. It should solve all your problems.

UPDATE: Apparently this is not only issue with Windows. In Linux just install the `mysql` gem:

```
gem install mysql
```
