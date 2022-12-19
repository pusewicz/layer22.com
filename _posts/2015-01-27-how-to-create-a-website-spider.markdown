---
title: How to create a website spider
date: 2015-01-27 23:51 UTC
tags: ruby
redirect_from: /2015/01/28/how-to-create-a-website-spider/
---

Creating a spider that generates a list of URLs for a given domain is very easy to do.

Spider simply visits each page in a domain, finds all the links and visits those.

With help from a gem called [Spidr](https://github.com/postmodern/spidr) we can achieve that with few lines of code.

```ruby
require 'spidr'
urls = []

Spidr.site('http://www.layer22.com/') do |spider|
  spider.every_url do |url|
    urls << url
  end
end
```

Fetching page content is also easy:

```ruby
require 'spidr'
contents = []

Spidr.site('http://www.layer22.com/') do |spider|
  spider.every_page do |page|
    contents << page.body
  end
end
```

What if we are only interested in paragraphs?

```ruby
require 'spidr'
paragraphs = []

Spidr.site('http://www.layer22.com/') do |spider|
  spider.every_page do |page|
    next unless page.content_type =~ %r(text/html)
    paragraphs << page.doc.search('p').map(&:text)
  end
end
```
