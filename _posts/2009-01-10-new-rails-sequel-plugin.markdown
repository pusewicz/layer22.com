---
title: New rails_sequel Plugin
date: 2009-01-10 18:00 +0100
redirect_from: /notebook/2009/01/10/new-rails-sequel-plugin.html
---

Recently, I was porting an Merb and Rails application from DataMapper to [Sequel](http://sequel.jeremyevans.net/). It is pretty much straightforward with Merb, as you only have to specify `use_orm :sequel` in your `init.rb` file to get Sequel configured automatically.

With Rails you have to do this manually eg.:

```ruby
DB = Sequel.connect('mysql://localhost/database')
```

or… use my new plugin [`rails_sequel`](https://github.com/pusewicz/rails_sequel).

`rails_sequel` is a simple plugin which loads Sequel, reads database.yml file and adds missing methods such as to_param or new_record?.

You can install it like any other Rails plugin:

```
script/plugin install git://github.com/pusewicz/rails_sequel.git
```

Alternatively you can install a gem:

```ruby
# Initializer for the class.
def initialize( string )
  @str = string
end
```

Load the gem in `environment.rb`

```ruby
Rails::Initializer.run do |config|
  config.gem 'pusewicz-rails_sequel', :version => '~> 0.0.2', :lib => 'rails_sequel', :source => 'http://gems.github.com'
end
```

You might want to remove ActiveRecord framework in environment.rb file as well:

```ruby
config.frameworks -= [ :active_record ]
```
