---
title: Keep your Heroku Ruby version and .ruby-version synchronised
date: 2015-12-19 10:32 UTC
tags: ruby, heroku
redirect_from: /2015/12/19/keep-your-heroku-ruby-version-and-ruby-version-synchronised/
---

Not everybody realizes that the `Gemfile` is just another Ruby script that can contain arbitrary Ruby code. Sure, it does understand some DSL such as `gem`, `ruby` or `source` but we can use it to make our lives a bit easier if we use Heroku to deploy our app and `rbenv` or `rvm` to manage Ruby version locally.

This trick I use for my Heroku applications allows me to upgrade the Ruby version used quickly. Especially useful for doing any security-related upgrades, such as the latest [Ruby 2.2.4 security release](https://www.ruby-lang.org/en/news/2015/12/16/unsafe-tainted-string-usage-in-fiddle-and-dl-cve-2015-7551/) that fixes [CVE-2015-7551](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-7551).

Typically, your `Gemfile` looks like below:

```ruby
source 'https://rubygems.org'

ruby '2.2.4'

gem 'rails'
```

And your `.ruby-version` contains:

```
2.2.4
```

To have our `Gemfile` use the `.ruby-version` content to let Heroku know which version of Ruby to use, we need to read the `.ruby-version` file in the `Gemfile` as follows.

```ruby
ruby File.read('.ruby-version').chomp
```

The code above instructs the `Gemfile` to read the Ruby version from the `.ruby-version` file, making it one step less to change your Ruby version, as you don't have to update two files anymore.

The extra `chomp` at the end eliminates the new-line character at the end of the number that will exist when reading the `.ruby-version` file.
