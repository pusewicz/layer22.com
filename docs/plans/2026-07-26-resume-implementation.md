# Resume Page + PDF Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `/resume` (date-rail web page) and a committed, ATS-safe `piotr-usewicz-resume.pdf` to layer22.com, both rendered from a single `_data/resume.yml`.

**Architecture:** One YAML data file feeds two Jekyll templates: a Tailwind-styled web page in the site's design system, and a standalone print page at `/resume-print/` that a local headless-Chrome rake task turns into a committed PDF. Cloudflare Pages build is untouched — it just serves the committed PDF.

**Tech Stack:** Jekyll 4.4, Tailwind 3 (via bun), Rake, headless Google Chrome (local only), @fontsource/barlow-condensed for print fonts.

**Spec:** `docs/plans/2026-07-26-resume-design.md`. Content sources (LOCAL ONLY, gitignored, never commit): `docs/resume/extracted-facts.md`, `docs/resume/harvest-dossier.md`, `docs/resume/linkedin-recommendations.md`.

## Global Constraints

- Design tokens: bg `#F5F3F0`, text `#0F0E0D`, muted `#6B6968`, accent `#C00000`, rule `#D4D0CB`; name/headings in `font-display` (Barlow Condensed); no CTA-style buttons.
- PDF: white A4, single column, dates right-aligned, real text, no tables/icons/photo, target 2 pages, filename `piotr-usewicz-resume.pdf` at repo root.
- `/resume-print/` must be `noindex` and out of the sitemap.
- No new Ruby gems. One new bun devDependency: `@fontsource/barlow-condensed`.
- All builds must keep passing on Cloudflare (`rake build` with no Chrome available) — the PDF task is never part of `rake build`.
- Verification tooling: `pdftotext`/`pdfinfo` come from poppler (`brew install poppler` if missing).

---

### Task 1: Resume content — `_data/resume.yml`

**Files:**
- Create: `_data/resume.yml`

**Interfaces:**
- Produces: `site.data.resume` with keys `basics`, `summary`, `experience[]`, `open_source[]`, `skills[]`, `languages` consumed by Tasks 2 and 4. Field names exactly as below.

- [ ] **Step 1: Verify the Harvest scale figure**

Fetch https://www.getharvest.com (WebFetch or curl) and look for a customer-count claim ("70,000+ businesses" or similar). If found, use it in the Harvest `context` line below; if not found, keep the fallback wording `tens of thousands of businesses` already in the YAML.

- [ ] **Step 2: Create `_data/resume.yml`**

```yaml
basics:
  name: Piotr Usewicz
  headline: Senior Software Engineer
  location: Benicàrlo, Spain
  availability: Remote (CET, EU/US overlap)
  email: piotr@layer22.com
  links:
    - label: layer22.com
      url: https://layer22.com
    - label: github.com/pusewicz
      url: https://github.com/pusewicz
    - label: linkedin.com/in/piotrusewicz
      url: https://www.linkedin.com/in/piotrusewicz

summary: >-
  Software engineer with 20+ years of building web products, most of them in
  Ruby on Rails. I spent eleven years at Harvest shipping across the whole
  stack — platform rebuilds, public APIs, integrations, zero-downtime data
  migrations, developer tooling. Comfortable owning a product from database
  schema to deploy pipeline; happiest on a small team that ships.

experience:
  - role: Sabbatical
    company:
    tagline: systems programming, games & open source
    location:
    start: "Oct 2025"
    end: present
    context: A deliberate year off after eleven years at Harvest, spent learning in public.
    bullets:
      - Contributed 19 merged pull requests upstream to Cute Framework, a C game framework.
      - Built bielik2d, a 2D game engine in pure Swift 6 on SDL3's GPU API,
        running natively and in the browser (WebAssembly/WebGPU).
      - Shipped cf-mcp, an MCP server that gives LLM coding agents searchable
        Cute Framework documentation (4,500+ downloads).
      - Wrote three games in C with SDL3 and Cute Framework while learning the
        language; made agentic coding workflows part of daily practice.

  - role: Senior Software Engineer
    company: Harvest
    company_url: https://www.getharvest.com
    location: Remote
    start: "Dec 2014"
    end: "Sep 2025"
    context: >-
      Time tracking and resource planning SaaS used by tens of thousands of
      businesses; fully remote team across nine time zones. Promoted from
      Software Engineer in July 2021.
    bullets:
      - Rebuilt Harvest's embeddable button and widget platform as a React +
        TypeScript app and shipped it to all customers, coordinating directly
        with Asana's engineers to keep their desktop integration unbroken.
      - Drove the datastore evaluation for the new Events API — built a complete
        Firestore prototype in under a week and led load tests across MySQL,
        Firestore, and Elasticsearch; the data reversed the planned choice
        before it got expensive.
      - As Engineering Lead of the Integrations squad, shaped the 2024 roadmap
        with Product and shipped the Deel payroll integration, designing a
        timesheet sync that worked around third-party API rate limits.
      - Consolidated the Linear, Notion, Monday.com, and Trello browser
        extensions into one Vite codebase building for Chrome, Edge, and Firefox.
      - Self-assigned and completed a multi-year migration to ISO currency codes
        across the Rails monolith — coordinated database migrations with SRE,
        zero service disruption.
      - Co-built Harvest Developer Tools, cutting new-engineer environment setup
        to under 30 minutes.
      - Modernized the frontend from Backbone/jQuery to React and Preact;
        shipped Google Calendar and Outlook integrations, MFA, and critical
        security fixes.
      - Mentored six engineers, designed the team's technical interview
        exercises, reviewed up to 193 PRs per half-year, and helped set
        Harvest's direction for AI features in 2025.
    quote:
      text: >-
        Piotr is a deeply experienced engineer with a pragmatic approach and an
        exceptional ability to cut through complexity. … Any team would benefit
        from Piotr's technical expertise, critical thinking, and collaborative
        spirit.
      name: Sherry Umlah
      title: Engineering Manager, Harvest
      source: https://www.linkedin.com/in/piotrusewicz/details/recommendations/

  - role: Senior Software Engineer
    company: Homestay.com
    location: Dublin, Ireland
    start: "Aug 2012"
    end: "Dec 2014"
    bullets:
      - Designed and implemented core services of the vacation-rental platform
        (Rails, MySQL) as the product scaled through public launch.

  - role: Senior Software Engineer
    company: Mixbook
    location: Palo Alto, California
    start: "Jan 2012"
    end: "Jun 2012"
    bullets:
      - Shipped customer-facing Rails features on the photo products platform.

  - role: Senior Ruby on Rails Developer
    company: HouseTrip
    location: London, UK
    start: "Sep 2011"
    end: "Dec 2011"
    bullets:
      - Helped build out the development team and engineering processes at a
        fast-growing holiday-rental startup.
    quote:
      text: >-
        A great Ruby/Rails developer, Piotr is a good communicator, easy to work
        with and delivered high quality code in a challenging, high traffic app.
      name: Matthew Hutchinson
      title: teammate at HouseTrip, now Staff Engineer at Shopify
      source: https://www.linkedin.com/in/piotrusewicz/details/recommendations/

  - role: Application Developer
    company: AOL
    location: London, UK
    start: "Jun 2011"
    end: "Sep 2011"
    bullets:
      - Built scalable realtime applications in Node.js and Erlang.
    quote:
      text: >-
        I've worked with Piotr twice and he was so good the first time I made
        sure AOL got him when he was available again. … Hire him now, before
        someone else does :)
      name: Stephen Strudwick
      title: Digital Architect, AOL
      source: https://www.linkedin.com/in/piotrusewicz/details/recommendations/

  - role: Application Developer
    company: Mobile Interactive Group
    location: London, UK
    start: "Jan 2008"
    end: "Jun 2011"
    bullets:
      - Kickstarted and led the ground-up rewrite of MIGPay, the group's mobile
        payments platform (Ruby on Rails + Merb) — new integration tooling for
        partners and a new mobile web experience for end users.
      - Built distributed Erlang systems and SMS payment flows powering
        digital-goods sales.
    quote:
      text: >-
        Piotr has shown extraordinary dedication and expertise in recent work
        for Mobile Interactive Group. His passion for innovation has allowed MIG
        to participate in cutting edge development.
      name: Marcus Kern
      title: Founder, Mobile Interactive Group
      source: https://www.linkedin.com/in/piotrusewicz/details/recommendations/

  - role: Earlier roles
    company:
    location: Warsaw, Poland
    start: "2004"
    end: "2007"
    bullets:
      - Head developer at ITSS (PHP content management and e-commerce); led the
        design and build of an ITIL-based ServiceDesk platform in Ruby on Rails
        at Exorigo.

open_source:
  intro: >-
    Writing open source since 2008 — gems downloaded ~97,000 times.
    Everything at github.com/pusewicz.
  projects:
    - name: statique
      url: https://github.com/pusewicz/statique
      note: static site generator in Ruby, built on Roda
    - name: cf-mcp
      url: https://github.com/pusewicz/cf-mcp
      note: MCP server giving LLM agents searchable Cute Framework docs
    - name: vimpk
      url: https://github.com/pusewicz/vimpk
      note: Vim package manager in Ruby
    - name: bielik2d
      url: https://github.com/pusewicz/bielik2d
      note: 2D game engine in Swift 6 on SDL3, native + WebAssembly

skills:
  - group: Primary
    items: Ruby, Rails, MySQL/SQL, GraphQL, REST API design
  - group: Frontend
    items: JavaScript, TypeScript, React, Preact, Hotwire/Stimulus, Tailwind
  - group: Also
    items: C, Swift, mruby; production Erlang, Node.js and PHP in past lives
  - group: Practices
    items: TDD, code review, zero-downtime migrations, load testing, developer tooling, AI-assisted development

languages: Polish (native) · English (fluent) · Spanish (intermediate)
```

- [ ] **Step 3: Verify the YAML parses and the site still builds**

Run: `ruby -ryaml -e 'YAML.load_file("_data/resume.yml"); puts "OK"'`
Expected: `OK`
Run: `bundle exec jekyll build 2>&1 | tail -1` (or `jekyll build` if no bundler binstub)
Expected: `done in X seconds.` with no errors.

- [ ] **Step 4: Commit**

```bash
git add _data/resume.yml
git commit -m "Add resume data file"
```

---

### Task 2: Web page — `_layouts/resume.html` + `_pages/resume.md`

**Files:**
- Create: `_layouts/resume.html`
- Create: `_pages/resume.md`

**Interfaces:**
- Consumes: `site.data.resume` (Task 1 schema).
- Produces: `/resume` page (`_site/resume.html`), used by Task 3 links.

- [ ] **Step 1: Create `_pages/resume.md`**

```markdown
---
layout: resume
title: Resume
permalink: /resume
description: Resume of Piotr Usewicz — Senior Software Engineer (Ruby/Rails), 20+ years of building web products.
---
```

- [ ] **Step 2: Create `_layouts/resume.html`**

```html
---
layout: default
---
{% assign r = site.data.resume %}
<article class="w-full bg-[#F5F3F0] h-resume">
  <div class="max-w-[820px] mx-auto px-6 pt-12 pb-16">

    <header class="h-card flex items-start gap-5 mb-10">
      {% assign avatar = "https://www.gravatar.com/avatar/dcbf676f860477e44b275cae5d6318a4.jpg?s=176" %}
      {% imagesize avatar:img alt="Piotr Usewicz" class="u-photo w-[88px] h-[88px] rounded-full object-cover shrink-0" %}
      <div class="min-w-0">
        <h1 class="p-name font-display text-[44px] leading-none font-semibold text-[#0F0E0D] m-0">{{ r.basics.name }}</h1>
        <p class="p-job-title text-[17px] text-[#0F0E0D] mt-1 mb-0">{{ r.basics.headline }}</p>
        <p class="text-[14px] text-[#6B6968] mt-1 mb-2">
          <span class="p-locality">{{ r.basics.location }}</span> · {{ r.basics.availability }}
        </p>
        <p class="text-[14px] mt-0 mb-0 flex flex-wrap gap-x-4 gap-y-1">
          <a class="u-email" href="mailto:{{ r.basics.email }}">{{ r.basics.email }}</a>
          {% for link in r.basics.links %}<a class="u-url" rel="me" href="{{ link.url }}">{{ link.label }}</a>{% endfor %}
          <a href="{{ '/piotr-usewicz-resume.pdf' | relative_url }}" class="text-[#C00000]">Download PDF ↓</a>
        </p>
      </div>
    </header>

    <p class="p-note text-[17px] leading-relaxed text-[#0F0E0D] mb-12">{{ r.summary }}</p>

    <h2 class="font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-6">Experience</h2>
    {% for job in r.experience %}
    <section class="grid grid-cols-1 md:grid-cols-[110px_1fr] gap-x-8 gap-y-1 mb-9">
      <div class="text-[14px] text-[#6B6968] tabular-nums pt-[3px]">{{ job.start }} – {{ job.end }}</div>
      <div class="min-w-0">
        <h3 class="text-[18px] font-semibold text-[#0F0E0D] m-0">
          {{ job.role }}{% if job.company %} · {% if job.company_url %}<a href="{{ job.company_url }}" class="no-underline hover:underline">{{ job.company }}</a>{% else %}{{ job.company }}{% endif %}{% endif %}{% if job.tagline %} <span class="font-normal text-[#6B6968]">— {{ job.tagline }}</span>{% endif %}
        </h3>
        {% if job.location %}<p class="text-[13px] text-[#6B6968] mt-0.5 mb-0">{{ job.location }}</p>{% endif %}
        {% if job.context %}<p class="text-[15px] text-[#6B6968] mt-2 mb-0">{{ job.context }}</p>{% endif %}
        {% if job.bullets %}
        <ul class="mt-2 mb-0 pl-5 text-[15px] leading-relaxed text-[#3A3836]">
          {% for b in job.bullets %}<li class="mb-1.5">{{ b }}</li>{% endfor %}
        </ul>
        {% endif %}
        {% if job.quote %}
        <blockquote class="border-l-2 border-[#C00000] pl-4 mt-4 mb-0 italic text-[15px] text-[#57544F]">
          <p class="m-0">“{{ job.quote.text }}”</p>
          <footer class="not-italic text-[13px] text-[#6B6968] mt-1">— <a href="{{ job.quote.source }}">{{ job.quote.name }}</a>, {{ job.quote.title }}</footer>
        </blockquote>
        {% endif %}
      </div>
    </section>
    {% endfor %}

    <h2 class="font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mt-14 mb-4">Open Source</h2>
    <p class="text-[15px] text-[#6B6968] mb-4">{{ r.open_source.intro }}</p>
    <ul class="pl-5 text-[15px] leading-relaxed text-[#3A3836] mb-0">
      {% for p in r.open_source.projects %}
      <li class="mb-1.5"><a href="{{ p.url }}">{{ p.name }}</a> — {{ p.note }}</li>
      {% endfor %}
    </ul>

    <h2 class="font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mt-14 mb-4">Skills</h2>
    <dl class="m-0">
      {% for s in r.skills %}
      <div class="grid grid-cols-1 md:grid-cols-[110px_1fr] gap-x-8 mb-2">
        <dt class="text-[14px] text-[#6B6968]">{{ s.group }}</dt>
        <dd class="m-0 text-[15px] text-[#3A3836]">{{ s.items }}</dd>
      </div>
      {% endfor %}
      <div class="grid grid-cols-1 md:grid-cols-[110px_1fr] gap-x-8 mb-0">
        <dt class="text-[14px] text-[#6B6968]">Languages</dt>
        <dd class="m-0 text-[15px] text-[#3A3836]">{{ r.languages }}</dd>
      </div>
    </dl>

  </div>
</article>
```

- [ ] **Step 3: Build and verify the page renders from data**

Run: `bunx tailwindcss -i ./tailwind.input.css -o ./assets/css/tailwind.css --minify && bundle exec jekyll build`
Then: `grep -c "Cute Framework" _site/resume.html` → Expected: `>= 2` (sabbatical bullet + open source)
And: `grep -o "Sherry Umlah" _site/resume.html | head -1` → Expected: `Sherry Umlah`
And: `grep -o "Download PDF" _site/resume.html` → Expected: `Download PDF`

- [ ] **Step 4: Visual check**

Run `bundle exec jekyll serve` and eyeball http://127.0.0.1:4000/resume — date rail aligned, quotes styled, photo round, mobile collapse (narrow window) stacks dates above content.

- [ ] **Step 5: Commit**

```bash
git add _layouts/resume.html _pages/resume.md
git commit -m "Add resume page"
```

---

### Task 3: Site integration — nav, contact, about

**Files:**
- Modify: `_includes/nav.html` (add link between ABOUT and CONTACT, line 9–10)
- Modify: `_pages/contact.markdown` (replace "not looking" paragraph)
- Modify: `_pages/about.markdown` (link resume in "Elsewhere")

**Interfaces:**
- Consumes: `/resume` from Task 2.

- [ ] **Step 1: Nav — insert after the About link in `_includes/nav.html`**

```html
      <a href="{{ 'resume' | relative_url }}" class="font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline">Resume</a>
```

(The nav is desktop-only — `hidden md:flex` — there is no separate mobile menu to update.)

- [ ] **Step 2: Contact page — replace the second paragraph of `_pages/contact.markdown`**

Old: `I'm open to consulting engagements, contract work, and interesting conversations about hard problems. Not currently looking for full-time positions.`

New: `I'm open to senior engineering roles (remote), as well as consulting and contract work — here's my [resume](/resume). Always happy to talk about hard problems.`

- [ ] **Step 3: About page — in the "Elsewhere" section of `_pages/about.markdown`, extend the LinkedIn sentence**

Old: `Also on [Bluesky](https://bsky.app/profile/pusewicz.bsky.social) and [LinkedIn](https://www.linkedin.com/in/piotrusewicz).`

New: `Also on [Bluesky](https://bsky.app/profile/pusewicz.bsky.social) and [LinkedIn](https://www.linkedin.com/in/piotrusewicz). If you're hiring, my [resume](/resume) is here.`

- [ ] **Step 4: Verify**

Run: `bundle exec jekyll build && grep -c 'href="/resume"' _site/about.html _site/contact.html _site/index.html`
Expected: at least 1 match in each of about.html, contact.html, index.html (nav appears on every page).

- [ ] **Step 5: Commit**

```bash
git add _includes/nav.html _pages/contact.markdown _pages/about.markdown
git commit -m "Link resume from nav, about, and contact pages"
```

---

### Task 4: Print page — fonts, `_layouts/resume_print.html`, `_pages/resume-print.md`

**Files:**
- Create: `assets/fonts/` (4 WOFF2 files via @fontsource)
- Create: `_layouts/resume_print.html`
- Create: `_pages/resume-print.md`
- Modify: `package.json` (bun adds @fontsource/barlow-condensed)

**Interfaces:**
- Consumes: `site.data.resume` (Task 1 schema; ignores `quote` fields and photo).
- Produces: `_site/resume-print/index.html`, consumed by Task 5's Chrome invocation.

- [ ] **Step 1: Self-host Barlow Condensed for print**

```bash
bun add -d @fontsource/barlow-condensed
mkdir -p assets/fonts
for w in 400 500 600 700; do
  cp node_modules/@fontsource/barlow-condensed/files/barlow-condensed-latin-$w-normal.woff2 assets/fonts/
  cp node_modules/@fontsource/barlow-condensed/files/barlow-condensed-latin-ext-$w-normal.woff2 assets/fonts/
done
ls assets/fonts/ | wc -l   # Expected: 8
```

- [ ] **Step 2: Create `_pages/resume-print.md`**

```markdown
---
layout: resume_print
title: Resume (print)
permalink: /resume-print/
sitemap: false
---
```

- [ ] **Step 3: Create `_layouts/resume_print.html`** (standalone — no default layout, no nav/footer)

```html
<!DOCTYPE html>
<html lang="en">
{% assign r = site.data.resume %}
<head>
  <meta charset="UTF-8">
  <meta name="robots" content="noindex">
  <title>Piotr Usewicz — Resume</title>
  <style>
    /* ../assets resolves correctly both when served (/resume-print/) and when
       printed from file://_site/resume-print/index.html */
    @font-face { font-family: 'Barlow Condensed'; font-weight: 600; font-style: normal;
      src: url('../assets/fonts/barlow-condensed-latin-600-normal.woff2') format('woff2'); }
    @font-face { font-family: 'Barlow Condensed'; font-weight: 500; font-style: normal;
      src: url('../assets/fonts/barlow-condensed-latin-500-normal.woff2') format('woff2'); }
    @page { size: A4; margin: 16mm 18mm; }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
           font-size: 10pt; line-height: 1.45; color: #111; }
    a { color: inherit; text-decoration: none; }
    .name { font-family: 'Barlow Condensed', 'Arial Narrow', sans-serif;
            font-weight: 600; font-size: 26pt; letter-spacing: .01em; }
    .meta { font-size: 8.5pt; color: #555; margin-top: 2pt; }
    .rule { border: 0; border-top: 1.2pt solid #C00000; width: 26pt; margin: 8pt 0 10pt; }
    .summary { color: #222; }
    h2 { font-family: 'Barlow Condensed', 'Arial Narrow', sans-serif; font-weight: 500;
         font-size: 9pt; letter-spacing: .16em; text-transform: uppercase;
         color: #C00000; margin: 12pt 0 5pt; }
    .entry { margin-bottom: 8pt; break-inside: avoid; }
    .entry-head { display: flex; justify-content: space-between; align-items: baseline; gap: 12pt; }
    .role { font-weight: 700; }
    .co { color: #444; font-weight: 400; }
    .dates { color: #555; font-size: 9pt; white-space: nowrap; }
    .loc, .context { font-size: 9pt; color: #555; }
    .context { margin-top: 1pt; }
    ul { margin: 3pt 0 0 11pt; color: #222; }
    li { margin-bottom: 1.5pt; }
    .os-intro { color: #444; margin-bottom: 3pt; }
    .skills { display: grid; grid-template-columns: 70pt 1fr; row-gap: 2pt; column-gap: 10pt; }
    .skills dt { color: #555; font-size: 9pt; }
  </style>
</head>
<body>
  <header>
    <div class="name">{{ r.basics.name }}</div>
    <div class="meta">{{ r.basics.headline }} · {{ r.basics.location }} — {{ r.basics.availability }} ·
      {{ r.basics.email }}{% for link in r.basics.links %} · {{ link.label }}{% endfor %}</div>
    <hr class="rule">
  </header>
  <p class="summary">{{ r.summary }}</p>

  <h2>Experience</h2>
  {% for job in r.experience %}
  <div class="entry">
    <div class="entry-head">
      <span><span class="role">{{ job.role }}</span>{% if job.company %} <span class="co">· {{ job.company }}</span>{% endif %}{% if job.tagline %} <span class="co">— {{ job.tagline }}</span>{% endif %}{% if job.location %} <span class="loc">· {{ job.location }}</span>{% endif %}</span>
      <span class="dates">{{ job.start }} – {{ job.end }}</span>
    </div>
    {% if job.context %}<div class="context">{{ job.context }}</div>{% endif %}
    {% if job.bullets %}<ul>{% for b in job.bullets %}<li>{{ b }}</li>{% endfor %}</ul>{% endif %}
  </div>
  {% endfor %}

  <h2>Open Source</h2>
  <p class="os-intro">{{ r.open_source.intro }}</p>
  <ul>
    {% for p in r.open_source.projects %}<li><strong>{{ p.name }}</strong> — {{ p.note }}</li>{% endfor %}
  </ul>

  <h2>Skills</h2>
  <dl class="skills">
    {% for s in r.skills %}<dt>{{ s.group }}</dt><dd>{{ s.items }}</dd>{% endfor %}
    <dt>Languages</dt><dd>{{ r.languages }}</dd>
  </dl>
</body>
</html>
```

- [ ] **Step 4: Verify build, noindex, and sitemap exclusion**

Run: `bundle exec jekyll build`
Then: `grep -o 'name="robots" content="noindex"' _site/resume-print/index.html` → Expected: match.
And: `grep -c "resume-print" _site/sitemap.xml` → Expected: `0`.
And: `grep -c "/resume<" _site/sitemap.xml || grep -c "resume" _site/sitemap.xml` → Expected: `/resume` present.

- [ ] **Step 5: Commit**

```bash
git add package.json bun.lock assets/fonts _layouts/resume_print.html _pages/resume-print.md
git commit -m "Add print-ready resume page with self-hosted Barlow Condensed"
```

---

### Task 5: PDF pipeline — rake task, staleness warning, redirect

**Files:**
- Modify: `Rakefile` (add `resume:pdf` task + staleness check in `build`)
- Modify: `_redirects` (add `/resume.pdf` alias)
- Create: `piotr-usewicz-resume.pdf` (generated, committed)

**Interfaces:**
- Consumes: `_site/resume-print/index.html` (Task 4).
- Produces: `piotr-usewicz-resume.pdf` at repo root (Jekyll copies it into `_site/` on every build; the Task 2 header links to it).

- [ ] **Step 1: Add to `Rakefile`**

```ruby
RESUME_PDF = "piotr-usewicz-resume.pdf"

desc "Warn if the committed resume PDF is older than its sources"
task :resume_freshness do
  sources = ["_data/resume.yml", "_layouts/resume_print.html"]
  if File.exist?(RESUME_PDF)
    stale = sources.select { |f| File.exist?(f) && File.mtime(f) > File.mtime(RESUME_PDF) }
    warn "WARNING: #{RESUME_PDF} is older than #{stale.join(", ")} — run `rake resume:pdf`" if stale.any?
  else
    warn "WARNING: #{RESUME_PDF} missing — run `rake resume:pdf`"
  end
end

namespace :resume do
  desc "Regenerate the resume PDF with headless Chrome (local only)"
  task pdf: :build do
    chrome = ENV["CHROME_BIN"] || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    abort "Chrome not found at #{chrome} — set CHROME_BIN" unless File.exist?(chrome)
    src = File.expand_path("_site/resume-print/index.html")
    sh chrome, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
       "--virtual-time-budget=5000", "--print-to-pdf=#{RESUME_PDF}", "file://#{src}"
    puts "Wrote #{RESUME_PDF}"
  end
end
```

And change the build line at the top of the Rakefile:

```ruby
task build: [:tailwind, :jekyll, :redirects, :resume_freshness]
```

Note: the print layout's font URLs are already relative (`../assets/fonts/…`) so they
resolve under both the served site and `file://` printing — keep them that way.

- [ ] **Step 2: Add to `_redirects`**

```
/resume.pdf /piotr-usewicz-resume.pdf 302
```

- [ ] **Step 3: Generate the PDF**

Run: `rake resume:pdf`
Expected: exits 0, `Wrote piotr-usewicz-resume.pdf`.

- [ ] **Step 4: Verify the PDF**

```bash
pdftotext piotr-usewicz-resume.pdf - | head -5        # text layer present, starts with "Piotr Usewicz"
pdftotext piotr-usewicz-resume.pdf - | grep -c Harvest # Expected: >= 2
pdfinfo piotr-usewicz-resume.pdf | grep Pages          # Expected: Pages: 2 (3 acceptable; tune spacing if over)
```

(`brew install poppler` if pdftotext/pdfinfo are missing.)
Open the PDF and eyeball: site-branded header, no orphaned headings at page breaks, no photo.

- [ ] **Step 5: Verify staleness warning**

```bash
touch _data/resume.yml && rake resume_freshness 2>&1 | grep WARNING   # warns
rake resume:pdf && rake resume_freshness 2>&1 | grep -c WARNING       # 0 after regen
```

- [ ] **Step 6: Full build sanity (Cloudflare parity — no Chrome involved)**

Run: `rake build`
Expected: succeeds; `ls _site/piotr-usewicz-resume.pdf` exists; no Chrome invoked.

- [ ] **Step 7: Commit**

```bash
git add Rakefile _redirects piotr-usewicz-resume.pdf
git commit -m "Add resume PDF pipeline with staleness guard"
```

---

### Task 6: Final review pass

**Files:** none new — verification only.

- [ ] **Step 1: End-to-end checks**

```bash
rake build
grep -o "Download PDF" _site/resume.html                 # link present
grep -c "resume-print" _site/sitemap.xml                  # 0
pdftotext piotr-usewicz-resume.pdf - | grep -c "Sherry"   # 0 — quotes are web-only
```

- [ ] **Step 2: Serve locally and click through**

`bundle exec jekyll serve` → check `/resume`, nav link on `/`, `/about`, `/contact`, download link fetches the PDF at `/piotr-usewicz-resume.pdf`.

- [ ] **Step 3: Present result to Piotr for content/design tweaks** (he expects to iterate once he sees it).

## Self-review notes

- Spec coverage: YAML (T1), web page + h-card + photo + quotes (T2), nav/contact/about (T3), print page + noindex + sitemap + fonts (T4), rake + staleness + redirect + committed PDF (T5), verification (T6). Education intentionally absent (spec: ships only after confirmation). Headline default per spec.
- Types: `site.data.resume` keys used identically in T2 and T4; `RESUME_PDF` name matches T2's download href and T5's redirect target.
- Font path fix under `file://` is called out explicitly in T5 Step 1 (relative `../assets/fonts/` paths in the print layout).
