# Resume page + PDF — design spec

2026-07-26 · Status: approved pending Piotr's final review

## Goal

Add a resume to layer22.com after the year-long sabbatical: a `/resume` web page in the
site's design language plus a downloadable, always-in-sync PDF suitable for job boards
and ATS pipelines. Target: Senior/Staff IC (Ruby/Rails) and founding/early-stage
engineer roles, remote-only, EU/US overlap.

## Locked decisions

- **Single source of truth:** all resume content in `_data/resume.yml`; both outputs
  render from it. Content edits happen only there.
- **Web page:** `/resume`, date-rail layout (dates in a narrow left gutter), pull-quotes
  from public LinkedIn recommendations with full attribution, small circular photo next
  to the name (same asset as home page), "Download PDF" link in the header.
- **PDF:** site-branded (Barlow Condensed name, thin red rule, red section labels) on an
  ATS-safe skeleton — white A4, single column, dates right-aligned, real text, no
  tables/icons/photo. ~2 pages. Filename `piotr-usewicz-resume.pdf`.
- **No photo on the PDF** (US recruiting norms; web page carries the face).
- **Sabbatical is the top experience entry**, honestly labeled, backed by public GitHub
  work (Cute Framework PRs, bielik2d, cf-mcp, C games).
- **Career start claimed as 2004** ("20+ years"), matching LinkedIn. The 2007 London
  agency period stays out; 2004–2007 compresses into one "earlier roles" line.
- **Promotion shown:** Harvest entry reads Senior Software Engineer with
  "promoted from Software Engineer, Jul 2021" noted.
- **Testimonials:** web page quotes come only from the 10 public LinkedIn
  recommendations (Sherry Umlah's Aug 2025 exit reference is the anchor). Private
  performance-review quotes are interview/cover-letter material and never published.
- **Contact details on PDF:** email, layer22.com, GitHub, LinkedIn, "Benicàrlo, Spain
  (Remote, CET)". No phone, no street address.
- **PDF generation is local:** `rake resume:pdf` via headless Chrome; the PDF is
  committed to the repo; Cloudflare Pages build is unchanged and just serves it.

## Content model — `_data/resume.yml`

```yaml
basics:
  name: Piotr Usewicz
  headline: Senior Software Engineer
  location: "Benicàrlo, Spain"
  availability: "Remote (CET, EU/US overlap)"
  email: piotr@layer22.com
  links: [layer22.com, github.com/pusewicz, linkedin.com/in/piotrusewicz]
summary: >
  3–4 lines; generalist positioning lives here, not in the headline.
experience:
  - role: Sabbatical            # or company role
    company:                    # optional (sabbatical has none)
    location:
    start: 2025-10
    end: ~                      # null = present
    context:                    # optional one-line intro (used for Harvest)
    bullets: [ ... ]
    quote:                      # optional, web-only
      text: ...
      name: Sherry Umlah
      title: Engineering Manager, Harvest
open_source:
  - name: statique
    note: Static site generator in Ruby/Roda
skills:
  - group: Primary
    items: [ ... ]
education: [ ... ]              # ships only after Piotr confirms degrees/years
languages: "Polish (native), English (fluent), Spanish (intermediate)"
```

Web-only fields (`quote`, photo) are ignored by the print template; the schema stays
one file.

## Web page — `/resume`

- `_pages/resume.md` (permalink `/resume`) + `_layouts/resume.html` reading the YAML.
- Existing site design system: cream `#F5F3F0`, Barlow Condensed for the name, sparse
  red accent, Tailwind utilities, 40–60px section spacing, no CTA styling.
- Date-rail grid: `grid-template-columns: [narrow date col] [content col]`; collapses to
  stacked on mobile.
- Pull-quotes: left red border, italic, full name + role attribution; at most one per
  entry, only where they land (Harvest, HouseTrip, AOL, MIG candidates).
- Header: photo + name + headline + contact links + Download PDF (quiet text link, not a
  button, per site conventions).
- h-card microformats on the header, consistent with the site's microformats2 markup.
- SEO: normal jekyll-seo-tag handling; page in sitemap.

## PDF — template and pipeline

- Print page at `/resume-print/`: dedicated minimal layout (no nav/footer), `noindex`,
  excluded from `sitemap.xml`.
- Print CSS: `@page { size: A4; margin: ~18mm }`; `break-inside: avoid` on entries;
  site-branded typography (Barlow Condensed name, thin red rule, red uppercase section
  labels); body text in system sans ~10pt; targets 2 pages.
- Fonts self-hosted (WOFF2 in `assets/`) so headless Chrome renders identically offline —
  verify Barlow Condensed is currently local, not fetched from Google Fonts, and fix if not.
- `rake resume:pdf`: builds the site, then
  `chrome --headless=new --print-to-pdf=piotr-usewicz-resume.pdf --no-pdf-header-footer
  _site/resume-print/index.html`; output lands at repo root, committed to git, copied by
  Jekyll into `_site/` on every build.
- `_redirects`: `/resume.pdf /piotr-usewicz-resume.pdf 302`.
- Staleness guard: `rake build` warns (never fails) when `_data/resume.yml` or the print
  layout is newer than the committed PDF. Workflow: edit YAML → `rake resume:pdf` →
  commit both.

## Site integration

- Nav: RESUME link between ABOUT and CONTACT (desktop nav in `_includes/nav.html`;
  handle mobile nav wherever it lives).
- Contact page: replace "Not currently looking for full-time positions." with open-to-
  work wording plus a resume link (draft: "I'm open to senior engineering roles
  (remote), as well as consulting and contract work — here's my resume.").
- About page: one light link to `/resume`, no restructuring.

## Content inputs

Source dossiers live in `docs/resume/` — **gitignored; local only; never commit**
(contains private performance-review material): `extracted-facts.md` (timeline),
`harvest-dossier.md` (achievements + private quotes), `linkedin-recommendations.md`
(public quotes), `questions.md` (decisions log).

Open inputs, non-blocking for implementation:
1. **Education**: template supports it; the section ships only after Piotr confirms
   degrees/fields/years. Until then the resume omits education entirely.
2. **Harvest scale claim**: verify current public figure (e.g. "70,000+ businesses")
   from getharvest.com before using; otherwise phrase without a number.
3. **Headline**: defaults to "Senior Software Engineer" (as mocked and approved);
   Piotr may swap wording in the YAML at any time.
4. **Contact-page wording**: draft above, Piotr may edit.

## Verification

- `rake build` passes locally; `/resume` renders with data from YAML; nav link works.
- PDF: text-selectable (no rasterization), ~2 pages, sane page breaks, opens with
  correct title metadata; `pdftotext` (or equivalent) run confirms the text layer reads
  in document order — the cheap ATS sanity check.
- `/resume-print` absent from sitemap and noindexed; `/resume.pdf` redirect works after
  deploy.
- Staleness warning fires when YAML is touched without regenerating the PDF.

## Out of scope

- Spanish-language version; per-market PDF variants; photo on the PDF; cover-letter
  generator; analytics on downloads.
