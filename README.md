# www.layer22.com

## Development

```
bundle exec jekyll serve
```

### Build and Deploy

Using Cloudflare. The `build` task will build and copy the `_redirects` fils to the `_site` output directory, so that the Cloudflare build system can pick this up.

```
rake build
```
