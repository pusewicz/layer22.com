# layer22.com

Personal blog/portfolio for Piotr Usewicz — a static site built by a small custom Ruby generator (Phlex components, Zeitwerk) and deployed to Cloudflare Pages. It replaced Jekyll and reproduces the Jekyll site's output, so keep that parity in mind when changing markup or URLs.

## Build Commands

```bash
rake dev                          # Dev server on http://localhost:4000, re-renders each request
rake build                        # Production build into _site/ (includes WebP conversion)
rake build:fast                   # Build without WebP conversion
rake til["Title of TIL"]          # Create a new TIL post
rake post["Title"]                # Create a new blog post
rake note                         # Create a note from the clipboard (or: pbpaste | rake note)
rake resume:pdf                   # Regenerate piotr-usewicz-resume.pdf with headless Chrome (local only)
rake test                         # Run the Minitest suite (TEST=test/layer22/slug_test.rb for one file)
rake standard                     # Lint with Standard (rake standard:fix to autofix)
rake                              # Lint, then test
```

Ruby version comes from `.ruby-version`. There is no JavaScript toolchain.

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
- `components/` — Phlex views: `layouts/application_layout.rb` (HTML shell), `pages/` (one per page type), `shared/` (nav, footer, SEO head, post lists, note entries, link cards, the click-to-play YouTube card, and the Bluesky and Instagram cards)
- `rendering/` — Markdown (commonmarker, configured to emit kramdown's markup), CSS assembly, word counts, excerpts, smart punctuation
- `generators/` — Files outside the route table: Atom `feed.xml`, RSS `rss.xml` and `notes/feed.xml`, `sitemap.xml`, `robots.txt`, WebFinger, WebP images; `archives_generator.rb` supplies the tag and date archive pages
- `rakelib/` — Rake tasks (Rake loads them automatically)

### Styles
Plain CSS, no build step. `Rendering::CSS` concatenates the site stylesheets and every page inlines them.
- `styles/normalize.css`, `styles/base.css` — Palette custom properties, elements, and the typography of rendered Markdown (post, page and note bodies)
- `styles/components.css` — One section per Phlex component, plus shared layout and type classes (`site-width`, `page-content`, `reading-width`, `page-title`, `display-label`, `display-caption`, `section-kicker`)
- `styles/syntax.css` — Rouge highlighting, added on post and note pages
- `<body>` carries each page's slugified title (and each tag archive its tag) as a class, as Jekyll did, so name component classes with more than one word to keep them from colliding

## Deployment

- **Platform**: Cloudflare Pages project `www-layer22-com`, deployed by GitHub Actions (`.github/workflows/deploy.yml`), not Cloudflare's Git builds (those compile Ruby from source on every build unless `.ruby-version` matches their preinstalled default)
- **Build command**: `rake build` (outputs to `_site/`), then `wrangler pages deploy _site`; `main` deploys to production, other branches to previews
- **Secrets**: `CLOUDFLARE_API_TOKEN` (Account › Cloudflare Pages › Edit) and `CLOUDFLARE_ACCOUNT_ID`, set for both Actions and Dependabot
- **Redirects**: `_redirects` is copied to `_site/`

## Key Conventions

- **TIL posts**: stored in `_til/:year/:month/YYYY-MM-DD-title.md`, use `rake til["Title"]` to scaffold
- **Notes**: `rake note` (`Layer22::Notes` in `lib/layer22/notes.rb`) moves a URL at the start or end of the pasted text into `link:` front matter and fetches its title/site/thumbnail once, saving the image to `images/notes/`; builds never hit the network. YouTube videos instead keep only their id (`link.youtube`) and show YouTube's thumbnail, which swaps in the youtube-nocookie player on click. bsky.app post URLs are read from Bluesky's public API instead, and the post itself (text, links, date, alt text; `link.bluesky`) is saved in the note along with its first image or video thumbnail, so the site renders it without contacting Bluesky. Instagram posts and reels (`link.instagram`, "reel" or "post") save the caption, author and thumbnail from Instagram's oEmbed endpoint, shown as a card that links out. Notes are untitled, so their `<title>` comes from their first words
- **Resume**: edit `_data/resume.yml`, then run `rake resume:pdf` and commit the PDF; `rake build` warns when the PDF is stale
- **WebP conversion**: images in the `webp.img_dirs` of `site.yml`
- **Tests**: Minitest, in `test/`, mirroring `lib/`. `test/test_helper.rb` gives `Layer22::TestCase` with `fixture_site` (a small site in `test/fixtures/site/`, deliberately full of edge cases) and `with_site` (a throwaway site in a temp dir). Timezone is pinned to Europe/Madrid; loaders read the working directory, so use `in_fixture_site`/`with_site` (never nested) and don't run tests in parallel. Warnings from project files fail the run (`test/warning_filter.rb`). `test/smoke_test.rb` renders the real content
- **CI**: `.github/workflows/test.yml` runs `rake standard` and `rake test` on every push, independently of the deploy workflow
