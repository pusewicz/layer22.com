---
title: "TIL: Use Rails travel functions instead of timecop or time-warp"
date: 2015-03-09 10:21 UTC
tags: til, rails
redirect_from: /2015/03/09/til-use-rails-travel-functions-instead-of-timecop-or-time-warp/
---

If you were using [`timecop`](https://github.com/travisjeffery/timecop) or [`time-warp`](https://github.com/harvesthq/time-warp) gems like me before, you will be happy to hear that Ruby on Rails provides its own [`travel`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel) and [`travel_to`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to) methods that allow you move in time and test time sensitive methods.

It's great to see that you don't need an external gem for this!

```ruby
test 'creates a post in the past' do
  travel_to(5.days.ago) do
    @post = Post.create
  end
  assert_equal 5.days.ago, @post.created_at
end
```

Read more at [OmniRef](https://www.omniref.com/ruby/gems/activesupport/symbols/ActiveSupport::Testing::TimeHelpers#tab=Methods).
