---
title: Spring-load your Rails development environment to speed it up
date: 2013-12-05 11:15 UTC
tags: rails
---

There is a wide selection of tools that allow you to pre-load your Rails development environment to make it faster. We have [Zeus](https://github.com/burke/zeus), [Spork](https://github.com/sporkrb/spork) or [Spin](https://github.com/jstorimer/spin).

All of them are great and help you work with your development environment faster, but there is a new contestant---[Spring](https://github.com/jonleighton/spring) by Jon Leighton.

What sets it apart from others is fantastic integration with Rails---in fact, it will be a default with all new Rails 4.1 applications.

## So what does it give us?

It pre-loads your development environment in the background without all the hassle of starting up servers etc.

All you need to do is simply add it to your project, install the gem and off you go:

In your `Gemfile`:

```ruby
group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
end
```

The second gem also adds support for `rspec` binstub, so running your tests will use the preloaded environment.

We need to install the gem locally, so we don't need to load it via `bundle exec` (which is slow!).

```
gem install spring
gem pristine --all
spring binstub --all
```

Let's compare time differences for `rake routes`:

Without Spring:

```
$ time rake routes

  4.32 real 0.10 user 0.06 sys
```

Now with Spring:

```
$ time bin/rake routes

  0.89 real 0.12 user 0.07 sys
```

Notice that we are using the generated binstub. You can achieve the same result by using `spring rake routes`.

There are other commands and configuration options that allow you to fine-tune your environment. It's all available in the [README](https://github.com/jonleighton/spring/blob/master/README.md).

Enjoy your faster running development environment.
