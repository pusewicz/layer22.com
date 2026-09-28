# layer22.com

Personal blog/portfolio for Piotr Usewicz — a static site built by a small custom Ruby generator (Phlex components, Zeitwerk) and deployed to Cloudflare Pages. It replaced Jekyll and reproduces the Jekyll site's output, so keep that parity in mind when changing markup or URLs.

## Build Commands

```bash
rake dev                          # Dev server on http://localhost:4000, re-renders each request, Tailwind in watch mode
rake build                        # Production build into _site/ (includes WebP conversion)
rake build:fast                   # Build without WebP conversion
rake til["Title of TIL"]          # Create a new TIL post
rake post["Title"]                # Create a new blog post
rake note                         # Create a note from the clipboard (or: pbpaste | rake note)
rake resume:pdf                   # Regenerate piotr-usewicz-resume.pdf with headless Chrome (local only)
```

Ruby version comes from `.ruby-version`; JS dependencies (Tailwind) are installed with `bun`.

## Architecture

### Content
- `_posts/` — Blog posts, served at `/:slug`
- `_til/` — Today I Learned, served at `/til/:year/:month/:day/:title/`
- `_notes/` — Short untitled notes, Tumblr-style, served at `/notes/:year/:month/:day/:title/`, streamed at `/notes/` with an RSS feed at `/notes/feed.xml`
- `_pages/` — Pages; front matter `layout` picks the component (`page`, `archive`, `notes`, `resume`, `resume_print`), `redirect_to` makes a redirect, and `listing: tils|tags|categories` appends a listing
- `_data/*.yml` — Data files (`resume.yml` feeds the resume pages)
- `site.yml` — Site config (title, author, social links, `timezone`, WebP settings)

### Code (`lib/layer22/`)
- `site.rb` — Loads content and holds the route table (`Site#routes`, URL → renderer) used by both the build and the dev server
- `output_path.rb` — Maps URLs to files like Jekyll: `/about` → `about.html`, `/2015/` → `2015/index.html`
- `content/` — Post, TIL, Note (with its Link) and Page models, front matter parsing, dates (local time in `site.yml`'s timezone), git-based last-modified times, data files
- `components/` — Phlex views: `layouts/application_layout.rb` (HTML shell), `pages/` (one per page type), `shared/` (nav, footer, SEO head, post lists, note entries, link cards and the click-to-play YouTube card)
- `rendering/` — Markdown (commonmarker, configured to emit kramdown's markup), CSS assembly, word counts, excerpts, smart punctuation
- `generators/` — Files outside the route table: Atom `feed.xml`, RSS `rss.xml` and `notes/feed.xml`, `sitemap.xml`, `robots.txt`, WebFinger, WebP images; `archives_generator.rb` supplies the tag and date archive pages
- `rakelib/` — Rake tasks (Rake loads them automatically)

### Styles
- `styles/normalize.css`, `styles/base.css` — Site CSS (oklch palette, post and page typography), inlined into every page
- `styles/tailwind.input.css` + `tailwind.config.js` — Tailwind utilities, scanned from `lib/**/*.rb` and content; compiled to `tmp/tailwind.css`
- `styles/syntax.css` — Rouge highlighting, added on post and note pages

## Deployment

- **Platform**: Cloudflare Pages project `www-layer22-com`, deployed by GitHub Actions (`.github/workflows/deploy.yml`), not Cloudflare's Git builds (those compile Ruby from source on every build unless `.ruby-version` matches their preinstalled default)
- **Build command**: `rake build` (outputs to `_site/`), then `wrangler pages deploy _site`; `main` deploys to production, other branches to previews
- **Secrets**: `CLOUDFLARE_API_TOKEN` (Account › Cloudflare Pages › Edit) and `CLOUDFLARE_ACCOUNT_ID`, set for both Actions and Dependabot
- **Redirects**: `_redirects` is copied to `_site/`

## Key Conventions

- **TIL posts**: stored in `_til/:year/:month/YYYY-MM-DD-title.md`, use `rake til["Title"]` to scaffold
- **Notes**: `rake note` (`rakelib/notes.rake`) moves a URL at the start or end of the pasted text into `link:` front matter and fetches its title/site/thumbnail once, saving the image to `images/notes/`; builds never hit the network. YouTube videos instead keep only their id (`link.youtube`) and show YouTube's thumbnail, which swaps in the youtube-nocookie player on click. Notes are untitled, so their `<title>` comes from their first words
- **Resume**: edit `_data/resume.yml`, then run `rake resume:pdf` and commit the PDF; `rake build` warns when the PDF is stale
- **WebP conversion**: images in the `webp.img_dirs` of `site.yml`
- No test suite
