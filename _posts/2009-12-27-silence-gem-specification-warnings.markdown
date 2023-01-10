---
title: Silence gem specification warnings
date: 2009-12-27 18:54 +0100
tags: [gems, ruby-on-rails]
redirect_from: /post/303051413/silence-gem-specification-warnings
---

If you happen to get those:

    [565] $ rake
    (in /Users/piotr/Projects/Lookup)
    config.gem: Unpacked gem cache in vendor/gems has no specification file. Run 'rake gems:refresh_specs' to fix this.
    config.gem: Unpacked gem cache in vendor/gems not in a versioned directory. Giving up.
    config.gem: Unpacked gem doc in vendor/gems has no specification file. Run 'rake gems:refresh_specs' to fix this.
    config.gem: Unpacked gem doc in vendor/gems not in a versioned directory. Giving up.
    config.gem: Unpacked gem environment.rb in vendor/gems has no specification file. Run 'rake gems:refresh_specs' to fix this.
    config.gem: Unpacked gem environment.rb in vendor/gems not in a versioned directory. Giving up.
    config.gem: Unpacked gem gems in vendor/gems has no specification file. Run 'rake gems:refresh_specs' to fix this.
    config.gem: Unpacked gem gems in vendor/gems not in a versioned directory. Giving up.
    config.gem: Unpacked gem specifications in vendor/gems has no specification file. Run 'rake gems:refresh_specs' to fix this.
    config.gem: Unpacked gem specifications in vendor/gems not in a versioned directory. Giving up.


You can silent them in environment.rb’s config block with:

```ruby
Rails::VendorGemSourceIndex.silence_spec_warnings = true
```
