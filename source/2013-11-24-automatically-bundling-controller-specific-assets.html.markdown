---
title: Automatically bundling controller specific assets
date: 2013-11-24 21:32 UTC
tags: rails
---

It's very convenient to be able to automatically bundle some of the assets in a separate file eg. when you have a lot of controller/resource specific CSS or JavaScript.

Let's say we are writing a blog, and we have two controllers---one for posts
and one for comments. We would also like to separate the stylesheets for them,
because, well, they are huge and only apply to either posts or comments.

All we have to do is add `rails-controller-assets` gem. It will look for assets
that match either `{controller_name}.css` or
`{controller_name}_{action_name}.css`.

In your `Gemfile` simply add:

```ruby
gem 'rails-controller-assets'
```

Now let's add a new bundle file for both posts and comments:

In `app/assets/stylesheets/posts.css`:

```css
.post-title { color: blue }
```

In `app/assets/stylesheets/comments.css`:

```css
.comment-title { color: brown }
```

The last step is to let the `stylesheets_link_tag` know what other files to
include:

In yout `app/views/layouts/application.html.erb`:

```erb
<%= stylesheets_link_tag 'application', *controller_stylesheets %>
```

This will make sure that the current action, when rendered will have all the
defined bundles included.

The same can be applied to JavaScript with:

```erb
<%= javascript_include_tag 'application', *controller_javascripts %>
```

Bundle files follow the same pattern: `{controller_name}.js` or
`{controller_name}_{action_name}.js`.

From now on, each page will be served with it's own bundle file which will give
us faster download speeds and rendering in browser.

The same pattern can be applied manually by adding `config.assets.precompile +=
%w(posts.css comments.css)` in your `application.rb` file, but this gem does it
automatically, so you will never forget to add your file there.
