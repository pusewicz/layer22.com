# layer22.com

Personal blog/portfolio for Piotr Usewicz — a static site built by a small custom Ruby generator (Phlex components, Zeitwerk) and deployed to Cloudflare Pages. It replaced Jekyll and reproduces the Jekyll site's output, so keep that parity in mind when changing markup or URLs.

## Build Commands

```bash
rake dev                          # Dev server on http://localhost:4000, re-renders each request, Tailwind in watch mode
rake build                        # Production build into _site/ (includes WebP conversion)
rake build:fast                   # Build without WebP conversion
rake til["Title of TIL"]          # Create a new TIL post
rake post["Title"]                # Create a new blog post
rake resume:pdf                   # Regenerate piotr-usewicz-resume.pdf with headless Chrome (local only)
```

Ruby version comes from `.ruby-version`; JS dependencies (Tailwind) are installed with `bun`.

## Architecture

### Content
- `_posts/` — Blog posts, served at `/:slug`
- `_til/` — Today I Learned, served at `/til/:year/:month/:day/:title/`
- `_pages/` — Pages; front matter `layout` picks the component (`page`, `archive`, `resume`, `resume_print`), `redirect_to` makes a redirect, and `listing: tils|tags|categories` appends a listing
- `_data/*.yml` — Data files (`resume.yml` feeds the resume pages)
- `site.yml` — Site config (title, author, social links, `timezone`, WebP settings)

### Code (`lib/layer22/`)
- `site.rb` — Loads content and holds the route table (`Site#routes`, URL → renderer) used by both the build and the dev server
- `output_path.rb` — Maps URLs to files like Jekyll: `/about` → `about.html`, `/2015/` → `2015/index.html`
- `content/` — Post, TIL and Page models, front matter parsing, dates (local time in `site.yml`'s timezone), git-based last-modified times, data files
- `components/` — Phlex views: `layouts/application_layout.rb` (HTML shell), `pages/` (one per page type), `shared/` (nav, footer, SEO head, post lists)
- `rendering/` — Markdown (commonmarker, configured to emit kramdown's markup), CSS assembly, word counts, excerpts, smart punctuation
- `generators/` — Files outside the route table: Atom `feed.xml`, RSS `rss.xml`, `sitemap.xml`, `robots.txt`, WebFinger, WebP images; `archives_generator.rb` supplies the tag and date archive pages
- `rakelib/` — Rake tasks (Rake loads them automatically)

### Styles
- `styles/normalize.css`, `styles/base.css` — Site CSS (oklch palette, post and page typography), inlined into every page
- `styles/tailwind.input.css` + `tailwind.config.js` — Tailwind utilities, scanned from `lib/**/*.rb` and content; compiled to `tmp/tailwind.css`
- `styles/syntax.css` — Rouge highlighting, added on post pages

## Deployment

- **Platform**: Cloudflare Pages
- **Build command**: `rake build` (outputs to `_site/`)
- **Redirects**: `_redirects` is copied to `_site/`

## Key Conventions

- **TIL posts**: stored in `_til/:year/:month/YYYY-MM-DD-title.md`, use `rake til["Title"]` to scaffold
- **Resume**: edit `_data/resume.yml`, then run `rake resume:pdf` and commit the PDF; `rake build` warns when the PDF is stale
- **WebP conversion**: images in the `webp.img_dirs` of `site.yml`
- No test suite
