# Landing Page & Nav Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the site-wide nav and home page to match the Paper portfolio design using Tailwind Play CDN.

**Architecture:** Add Tailwind Play CDN + Barlow Condensed font to `default.html`, move nav outside `<main>`, rewrite `nav.html` and `home.html` with Tailwind classes, strip the old `main > nav` CSS block.

**Tech Stack:** Jekyll 4.4.1, Tailwind CSS Play CDN (v3), Barlow Condensed via Google Fonts, existing SCSS (untouched except `_nav.scss`)

**Branch:** `redesign/landing-nav`

---

### Task 1: Add Tailwind CDN + Barlow Condensed to `default.html`

**Files:**
- Modify: `_layouts/default.html`

**Step 1: Add Google Fonts + Tailwind CDN inside `<head>`, before `</head>`**

In `_layouts/default.html`, find the closing `</head>` tag and insert before it:

```html
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@700;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
      tailwind.config = {
        theme: {
          extend: {
            fontFamily: {
              display: ['"Barlow Condensed"', 'Impact', 'sans-serif'],
            },
          },
        },
      }
    </script>
```

**Step 2: Move nav include to before `<main>` in `<body>`**

Find the `<body ...>` open tag line and the `<main ...>` line. Insert `{% include nav.html %}` between them:

```html
  <body ...>
    {% include nav.html %}
    <main class="container">{{ content }}</main>
```

**Step 3: Replace the existing `<footer>` with a new Tailwind footer**

Remove the existing footer block:
```html
    <footer class="container">
      <small>© 2004-<time datetime="{{ site.time | date_to_xmlschema }}">{{ site.time | date: '%Y' }}</time> <a rel="me" href="{{ 'about' | relative_url }}">Piotr Usewicz</a> · Benicarló, Spain · <a href="{{ 'contact' | relative_url }}">Contact</a> · <a href="{{ 'feed.xml' | relative_url }}"><abbr title="Really Simple Syndication">RSS</abbr>&nbsp;Feed</a></small>
    </footer>
```

Replace with:
```html
    <footer class="bg-white border-t border-gray-100 py-8 px-6">
      <div class="max-w-5xl mx-auto">
        <div class="flex items-center justify-between mb-3">
          <span class="text-xs font-bold tracking-[0.2em] uppercase text-gray-900">LAYER|TWENTY|TWO</span>
          <div class="flex gap-6">
            <a href="https://github.com/{{ site.github_username }}" class="text-xs font-semibold tracking-[0.15em] uppercase text-gray-500 hover:text-gray-900 no-underline">GitHub</a>
            <a rel="me" href="https://{{ site.mastodon.instance }}/@{{ site.mastodon.username }}" class="text-xs font-semibold tracking-[0.15em] uppercase text-gray-500 hover:text-gray-900 no-underline">Mastodon</a>
          </div>
        </div>
        <p class="text-xs text-gray-400">© 2004–<time datetime="{{ site.time | date_to_xmlschema }}">{{ site.time | date: '%Y' }}</time> <a href="{{ 'about' | relative_url }}" class="hover:underline">Piotr Usewicz</a> · Benicarlò, Spain</p>
      </div>
    </footer>
```

**Step 4: Verify**

Run: `bundle exec jekyll serve` (activate Ruby first via `eval "$(rbenv init -)"`)
Open: `http://localhost:4000`
Expected: page loads, no console errors, Tailwind classes work (check any existing page).

**Step 5: Commit**

```bash
git add _layouts/default.html
git commit -m "feat: add Tailwind CDN + Barlow Condensed, move nav to default layout"
```

---

### Task 2: Rewrite `nav.html` with Tailwind

**Files:**
- Modify: `_includes/nav.html`

**Step 1: Replace entire file content**

```html
<nav class="w-full bg-white border-b border-gray-100">
  <div class="max-w-5xl mx-auto px-6 h-20 flex items-center justify-between">
    <a href="{{ '/' | relative_url }}" class="flex items-center gap-3 no-underline">
      <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-red-700" style="color: var(--accent-color)"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/></svg>
      <span class="text-xs font-bold tracking-[0.2em] uppercase text-gray-900">{{ site.title }}</span>
    </a>
    <div class="hidden md:flex items-center gap-8">
      <a href="{{ 'about' | relative_url }}" class="text-xs font-semibold tracking-[0.15em] uppercase text-gray-600 hover:text-gray-900 no-underline">About</a>
      <a href="{{ 'archive' | relative_url }}" class="text-xs font-semibold tracking-[0.15em] uppercase text-gray-600 hover:text-gray-900 no-underline">Writing</a>
      <a href="{{ 'contact' | relative_url }}" class="text-xs font-semibold tracking-[0.15em] uppercase text-gray-600 hover:text-gray-900 no-underline">Contact</a>
    </div>
  </div>
</nav>
```

**Step 2: Verify**

Open `http://localhost:4000/about` (a non-home page).
Expected: new nav appears at top — brand left, About/Writing/Contact right, clean white bar, no red stripe.

**Step 3: Commit**

```bash
git add _includes/nav.html
git commit -m "feat: rewrite nav with Tailwind — brand left, links right"
```

---

### Task 3: Remove nav includes from post/page/til layouts

**Files:**
- Modify: `_layouts/post.html` (line 5)
- Modify: `_layouts/page.html` (line 5)
- Modify: `_layouts/til.html`

**Step 1: In each file, delete the `{% include nav.html %}` line**

`post.html`: delete line 5 (`{% include nav.html %}`)
`page.html`: delete line 5 (`{% include nav.html %}`)
`til.html`: find and delete the `{% include nav.html %}` line

**Step 2: Verify**

Open `http://localhost:4000` (any post URL).
Expected: nav appears once at the top — no duplicate nav.

**Step 3: Commit**

```bash
git add _layouts/post.html _layouts/page.html _layouts/til.html
git commit -m "refactor: remove nav includes from post/page/til (now in default layout)"
```

---

### Task 4: Strip old `main > nav` rules from `_nav.scss`

**Files:**
- Modify: `_sass/_nav.scss`

**Step 1: Remove the `main > nav { ... }` block (lines 1–17)**

Delete these lines entirely:
```scss
main > nav {
  display: flex;
  flex-flow: row nowrap;
  justify-content: space-between;
  align-items: normal;
  align-content: normal;
  padding: 0.5em 1em;
  border-top: 5px solid var(--accent-color);

  a {
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }
}
```

Leave `#brand`, `nav.menu`, `nav.archives`, `nav.browse` rules untouched — these are used by archive pages.

**Step 2: Verify**

Check `http://localhost:4000/archive` — archive nav (browse/archives) still looks correct.

**Step 3: Commit**

```bash
git add _sass/_nav.scss
git commit -m "style: remove old main > nav CSS block (replaced by Tailwind)"
```

---

### Task 5: Rewrite `home.html` — Hero + Craft & Capability

**Files:**
- Modify: `_layouts/home.html`

**Step 1: Replace the entire file with the hero and first section**

```html
---
layout: default
---

{{- /* Hero */ -}}
<section class="w-full bg-[#f5f0e8] py-24 px-6">
  <div class="max-w-5xl mx-auto">
    <p class="text-xs font-semibold tracking-[0.2em] uppercase text-gray-400 mb-6">Web Application Developer</p>
    <h1 class="font-display font-black uppercase text-gray-900 leading-none mb-6" style="font-size: clamp(5rem, 14vw, 11rem)">Piotr<br>Usewicz</h1>
    <div class="w-20 h-1 mb-8" style="background-color: var(--accent-color)"></div>
    <p class="text-base text-gray-600 max-w-sm leading-relaxed">Building functional web applications with Ruby, Rails, and modern JavaScript. Based in Benicarlò, Spain.</p>
  </div>
</section>

{{- /* Craft & Capability */ -}}
<section class="w-full bg-[#e8e5df] py-24 px-6">
  <div class="max-w-5xl mx-auto">
    <p class="text-xs font-semibold tracking-[0.2em] uppercase text-gray-400 mb-4">What I Do</p>
    <h2 class="font-display font-bold text-5xl uppercase text-gray-900 mb-16">Craft &amp; Capability</h2>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-12">
      <div class="border-t border-gray-300 pt-6">
        <h3 class="text-xs font-bold tracking-[0.15em] uppercase text-gray-900 mb-4">Backend</h3>
        <p class="text-sm text-gray-600 leading-relaxed">Ruby on Rails applications built for longevity — clean architecture, fast queries, and APIs that other services can rely on. Fifteen years of production experience.</p>
      </div>
      <div class="border-t border-gray-300 pt-6">
        <h3 class="text-xs font-bold tracking-[0.15em] uppercase text-gray-900 mb-4">Frontend</h3>
        <p class="text-sm text-gray-600 leading-relaxed">Hotwire, Stimulus, and vanilla JS for reactive interfaces without the framework weight. HTML and CSS with care for performance, accessibility, and craft.</p>
      </div>
      <div class="border-t border-gray-300 pt-6">
        <h3 class="text-xs font-bold tracking-[0.15em] uppercase text-gray-900 mb-4">Full Stack</h3>
        <p class="text-sm text-gray-600 leading-relaxed">End-to-end ownership from database schema to deployed interface. Comfortable with the full lifecycle: architecture, implementation, ops, and iteration.</p>
      </div>
    </div>
  </div>
</section>
```

**Step 2: Verify**

Open `http://localhost:4000`.
Expected: hero with large "PIOTR USEWICZ" in Barlow Condensed, red rule, tagline. Then gray "Craft & Capability" section with 3 columns.

**Step 3: Commit**

```bash
git add _layouts/home.html
git commit -m "feat: home hero + craft & capability sections"
```

---

### Task 6: Add remaining home sections — About, Blog, CTA

**Files:**
- Modify: `_layouts/home.html` (append to file)

**Step 1: Append the Three Remaining Sections**

Open `_layouts/home.html` and append after the Craft & Capability section:

```html
{{- /* Two Decades of Code */ -}}
<section class="w-full bg-white py-24 px-6">
  <div class="max-w-5xl mx-auto">
    <p class="text-xs font-semibold tracking-[0.2em] uppercase text-gray-400 mb-4">About</p>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-16 items-start">
      <div>
        <h2 class="font-display font-bold text-5xl uppercase text-gray-900 mb-8 leading-tight">Two Decades<br>of Code</h2>
        <p class="text-sm text-gray-600 leading-relaxed mb-4">I've been writing software professionally since 2005 — first in PHP, then Rails from the very early days. Over the years I've built SaaS products, internal tooling, developer APIs, and consumer applications, usually as the person who owns the whole stack.</p>
        <p class="text-sm text-gray-600 leading-relaxed">Today I work independently — consulting, contracting, and building products of my own. I care about readable code, sensible defaults, and software that stays maintainable long after the initial excitement fades.</p>
      </div>
      <div class="flex justify-end">
        {% assign avatar = "https://www.gravatar.com/avatar/dcbf676f860477e44b275cae5d6318a4.jpg?s=400" %}
        {% imagesize avatar:img alt="Piotr Usewicz" class="w-64 h-64 object-cover grayscale" %}
      </div>
    </div>
  </div>
</section>

{{- /* From the Blog */ -}}
<section class="w-full bg-[#e8e5df] py-24 px-6">
  <div class="max-w-5xl mx-auto">
    <p class="text-xs font-semibold tracking-[0.2em] uppercase text-gray-400 mb-4">Recent Writing</p>
    <div class="flex items-baseline justify-between mb-12">
      <h2 class="font-display font-bold text-5xl uppercase text-gray-900">From the Blog</h2>
      <a href="{{ 'archive' | relative_url }}" class="text-xs font-semibold tracking-[0.15em] uppercase text-gray-400 hover:text-gray-900 no-underline">View Archive</a>
    </div>
    <div class="divide-y divide-gray-300">
      {% for post in site.posts limit:3 %}
      <div class="flex items-baseline justify-between py-5">
        <a href="{{ post.url }}" class="text-sm font-medium text-gray-900 hover:underline">{{ post.title }}</a>
        <span class="text-xs text-gray-400 tracking-wide ml-8 shrink-0">{{ post.date | date: "%b %Y" | upcase }}</span>
      </div>
      {% endfor %}
    </div>
  </div>
</section>

{{- /* CTA */ -}}
<section class="w-full bg-[#f5f0e8] py-24 px-6 text-center">
  <div class="max-w-5xl mx-auto">
    <h2 class="font-display font-black uppercase text-gray-900 leading-none mb-6" style="font-size: clamp(3.5rem, 9vw, 7rem)">Let's Build<br>Something</h2>
    <p class="text-sm text-gray-500 mb-10 max-w-xs mx-auto leading-relaxed">Open to consulting engagements, contract work, and interesting conversations about hard problems.</p>
    <a href="{{ 'contact' | relative_url }}" class="inline-block text-white text-xs font-bold tracking-[0.2em] uppercase px-8 py-4 hover:opacity-90 transition-opacity" style="background-color: var(--accent-color)">Get in Touch</a>
  </div>
</section>
```

**Step 2: Verify**

Open `http://localhost:4000`.
Expected: all 5 sections visible — hero, craft, about with photo, blog list with 3 posts and dates, CTA with red button.

**Step 3: Commit**

```bash
git add _layouts/home.html
git commit -m "feat: home about, blog, and CTA sections"
```

---

### Task 7: Final cleanup and visual review

**Files:**
- Modify: `_sass/_nav.scss` (if `#brand` block is now unused — check first)

**Step 1: Check if `#brand` is used anywhere outside nav**

```bash
grep -r "id=\"brand\"\|#brand" _layouts/ _includes/ _pages/ _sass/
```

If only in `_sass/_nav.scss` and no longer in any template (we removed it from `home.html`), delete the `#brand { ... }` block from `_nav.scss` too.

**Step 2: Full page review**

Check these URLs:
- `http://localhost:4000` — home, all sections
- `http://localhost:4000/about` — nav + page layout looks right
- `http://localhost:4000/archive` — nav + archive nav looks right
- Any post URL — nav + post layout looks right

**Step 3: Commit cleanup**

```bash
git add _sass/_nav.scss
git commit -m "style: remove unused #brand styles"
```
