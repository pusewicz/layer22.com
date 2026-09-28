# www.layer22.com

## Development

```
rake dev
```

Serves the site on http://localhost:4000, rendering each page from source on request.

### Build and Deploy

Using Cloudflare Pages. The `build` task renders the site into `_site/` and copies the `_redirects` file there, so that the Cloudflare build system can pick it up.

```
rake build
```
