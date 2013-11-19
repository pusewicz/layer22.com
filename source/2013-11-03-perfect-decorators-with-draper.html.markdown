---
title: Perfect decorators with Draper
date: 2013-11-03
tags: rails
---

Draper gives you a great way to decorate your `ActiveRecord` objects. But what is even better is that it allows you to do that transparently.

Say we have an `Article` model for our blog.

```ruby
class Article < ActiveRecord::Base
  extend FriendlyId

  friendly_id :title, use: [:slugged, :finders, :history]

  validates :title, :slug, :body, presence: true

  scope :latest, -> { last(5) }
end
```

## Adding new article decorator

Additionally, we add a new decorator which will allow us to render the body as Markdown.

```ruby
class ArticleDecorator < Draper::Decorator
  delegate_all

  def markdown_body
    MarkdownService.call(body)
  end
end
```

Now thanks to Draper's built in helpers, we can transparently decorate all our objects with `decorates_assigned` which gives us new helper:

```ruby
class ArticlesController < ApplicationController
  decorates_assigned :articles, :article

  def index
    @articles = Article.all.page(params[:page])
  end

  def show
    @article = Article.friendly.find(params['article_slug'])
  end
end
```

`decorates_assigned` will decorate both `@articles` and `@article` for us under the `articles` and `article` helper methods defined autmatically.

In the view we can do:

```slim
h1= article.title
= article.markdown_body
```

It saves us from manually specifying `@article.decorate` or calling `ArticleDecorator.decorate(@article)`.
