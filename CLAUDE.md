# layer22.com

Personal blog/portfolio for Piotr Usewicz — Jekyll 4.4.1 static site deployed to Cloudflare Pages.

## Build Commands

```bash
bundle exec jekyll serve          # Local dev server
rake build                        # Production build (runs jekyll + copies _redirects)
rake til["Title of TIL"]          # Create a new TIL post
rake note                         # Create a note from the clipboard (or: pbpaste | rake note)
```

## Architecture

### Collections & Content
- `_posts/` — Blog posts (layout: `post`, permalink: `/:slug`)
- `_til/` — Today I Learned collection (layout: `til`, permalink: `/til/:year/:month/:day/:title/`)
- `_notes/` — Short untitled notes, Tumblr-style (layout: `note`, permalink: `/notes/:year/:month/:day/:title/`), streamed at `/notes/` with an RSS feed at `/notes/feed.xml`
- `_pages/` — Static pages (included via `include: [_pages]` in config)

### Layouts (layout inheritance)
- `default.html` — Base layout (HTML shell, head, nav, footer)
- `home.html`, `page.html`, `post.html`, `til.html`, `note.html` — extend `default.html`
- `archive.html`, `archive_year.html`, `archive_month.html`, `archive_day.html`, `archive_tags.html` — archive pages via `jekyll-archives`

### Includes
- `_includes/post/` — Post partials: `post-date.html`, `post-meta.html`, `post-tags.html`, `post-categories.html`, `post-list-item.html`, `word-count.html`
- `_includes/archives/` — Archive partials: `by-taxonomy.html`, `by-year.html`
- `_includes/note/` — Note partials: `entry.html` (stream item and permalink body), `link-card.html` (link preview), `youtube.html` + `youtube-script.html` (click-to-play YouTube video), `title.html` (derived `<title>` for untitled notes)
- `_includes/feed/rss.xml` — RSS 2.0 channel shared by `rss.xml` (posts) and the notes feed
- `_includes/nav.html`, `scripts.html`

### Styles
- `_sass/` — SCSS with **oklch color system** (`_base.scss` defines brand/background/link palettes)
- `_sass/_all.scss` — Main entry point importing all partials
- `_sass/_prose.scss` — `text` mixin for body copy shared by posts, pages and notes
- No JS build pipeline; assets are in `assets/`

### Jekyll Plugins (11 active)
`jekyll-archives`, `jekyll-feed`, `jekyll-image-size`, `jekyll-last-modified-at`, `jekyll-loading-lazy`, `jekyll-redirect-from`, `jekyll-seo-tag`, `jekyll-sitemap`, `jekyll-webp`, `jekyll/mastodon_webfinger`, `jemoji`

Also in Gemfile: `jekyll-compose` (not in `_config.yml` plugins list).

## Deployment

- **Platform**: Cloudflare Pages
- **Build command**: `rake build` (outputs to `_site/`)
- **Redirects**: `_redirects` file is copied to `_site/` by `rake redirects`

## Key Conventions

- **Front matter defaults** in `_config.yml`: posts get `layout: post` and `custom_css: [syntax.css]` automatically
- **Permalink**: `/:slug` for posts (slug defined in front matter)
- **Notes**: `rake note` (`rakelib/notes.rake`) moves a URL at the start or end of the pasted text into `link:` front matter and fetches its title/site/thumbnail once, saving the image to `images/notes/`; builds never hit the network. YouTube videos instead keep only their id (`link.youtube`) and show YouTube's thumbnail with a click-to-play youtube-nocookie player (`_includes/note/youtube.html`). Notes default to `title: ""`, so they render without a heading
- **TIL posts**: stored in `_til/:year/:month/YYYY-MM-DD-title.md`, use `rake til["Title"]` to scaffold
- **SASS style**: compressed in production, sourcemap in development
- **WebP conversion**: automatic for images in `/images`, `/images/articles`, `/images/articles/mov2gif`
- No JavaScript build pipeline, no test suite
- `timezone: Europe/Madrid` in config
