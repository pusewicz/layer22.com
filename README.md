# www.layer22.com

## Development

```
rake dev
```

Serves the site on http://localhost:4000, rendering each page from source on request.

### Build and Deploy

Using Cloudflare Pages. The `build` task renders the site into `_site/` and copies the `_redirects` file there. GitHub Actions (`.github/workflows/deploy.yml`) runs it on every push and uploads `_site/` with Wrangler: `main` goes to production, other branches to preview deployments. Cloudflare's own Git builds are off because they compile any Ruby that isn't preinstalled on every build.

```
rake build
```
