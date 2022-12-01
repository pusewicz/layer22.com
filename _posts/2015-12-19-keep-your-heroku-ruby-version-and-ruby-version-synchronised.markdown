---
title: Keep your Heroku Ruby version and .ruby-version synchronised
date: 2015-12-19 10:32 UTC
tags: ruby heroku
---

Not everybody realises that the `Gemfile` is just another Ruby script that can contain arbitrary Ruby code. Sure, it does understand some DSL such as `gem`, `ruby` or `source` but we can use it to make our lives a bit easier if we use Heroku to deploy our app and `rbenv` or `rvm` to manage Ruby version locally.

This is one trick that I use for my Heroku applications that allows me to quickly upgrade the Ruby version used. Especially useful for doing any security related upgrades, such as the latest [Ruby 2.2.4 security release](https://www.ruby-lang.org/en/news/2015/12/16/unsafe-tainted-string-usage-in-fiddle-and-dl-cve-2015-7551/) that fixes [CVE-2015-7551](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-7551).

Normally, your `Gemfile` looks like this:

```ruby
source 'https://rubygems.org'

ruby '2.2.4'

gem 'rails'
```

and your `.ruby-version` like this:

```
2.2.4
```

In order to have our `Gemfile` use the `.ruby-version` content to let Heroku know which version of Ruby to use, just edit the `Gemfile` as follows.

```ruby
ruby File.read('.ruby-version').chomp
```

This instructs the `Gemfile` to read the Ruby version from the `.ruby-version` file, making it that one step less to change your Ruby version, as you don't have to update two files anymore!
