---
layout: post
title: Rails migration does speak! At last.
date: 2006-03-28 18:00 +0100
tags: [ruby-on-rails]
redirects_from: /2006/03/28/rails-migration-does-speak-at-last/
---

It is good to see that new version of migration script (rake migrate) does output what it is doing. Previously, you would not even know what does the script actually alter nor where it raises an error (well, it could output an error trace). Now we have such a beatiful:

```
== AddUserFromContact: migrating ==============================================
-- add_column(:users, :account_id, :integer)
-> 0.4220s
== AddUserFromContact: migrated (0.4220s) =====================================
```
