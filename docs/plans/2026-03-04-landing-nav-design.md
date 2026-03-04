# Landing Page & Nav Redesign

**Date:** 2026-03-04
**Branch:** to be created
**Source:** Paper design — "layer|twenty|two — Landing Page (Light)"

## Goal

Transform the minimal blog homepage into a full portfolio landing page matching the Paper design, and update the site-wide nav to the new minimal style.

## Approach

Global Tailwind overhaul (Approach A):
- Add Tailwind Play CDN to `default.html`
- Rewrite `nav.html` with Tailwind classes (affects all pages)
- Rewrite `home.html` with all six sections in Tailwind
- Strip `main > nav` rules from `_nav.scss`; keep archive/browse nav rules

## Architecture

### Files to modify

| File | Change |
|---|---|
| `_layouts/default.html` | Add Play CDN `<script>` + inline Tailwind config; move nav outside `<main>` |
| `_includes/nav.html` | Full rewrite with Tailwind classes |
| `_layouts/home.html` | Full rewrite — six sections |
| `_sass/_nav.scss` | Remove `main > nav { ... }` block only |

### Files untouched

All other layouts, SCSS partials, posts, pages, and config.

## Typography

- **Display font:** Barlow Condensed (weights 700, 900) via Google Fonts
- **Body/nav:** existing system font stack (`var(--font-sans)`)
- Loaded via `<link>` in `default.html` and configured in Tailwind inline config

## Color

Reuse existing CSS variables from `_base.scss`:
- `var(--accent-color)` — brand red (hero rule, CTA button)
- `var(--bg-color)` — base white
- Section backgrounds: `#f5f0e8` (warm off-white), `#e8e5df` (light gray) as Tailwind arbitrary values

## Nav Design

- Full-width white bar, ~80px tall, no colored top border
- Left: target SVG + `LAYER|TWENTY|TWO` uppercase tracked
- Right: `ABOUT` / `WRITING` / `CONTACT` → `/about`, `/archive`, `/contact`
- Mobile: links hidden (JS-free, no hamburger for now)
- Nav lives outside `<main class="container">` for full-width span

## Home Page Sections

### 1. Hero
- Background: `#f5f0e8`
- "WEB APPLICATION DEVELOPER" — small uppercase tracked label
- "PIOTR USEWICZ" — Barlow Condensed Black, very large display size
- Short red rule (`var(--accent-color)`)
- Tagline: `site.description`

### 2. Craft & Capability
- Background: `#e8e5df`
- Label: "WHAT I DO" / Heading: "CRAFT & CAPABILITY"
- Three columns: Backend / Frontend / Full Stack
- Content: static copy matching Paper design

### 3. Two Decades of Code
- Background: white
- Label: "ABOUT" / Heading: "TWO DECADES OF CODE"
- Two-column: bio text left, Gravatar photo right
- Content: static copy matching Paper design

### 4. From the Blog
- Background: `#e8e5df`
- Label: "RECENT WRITING" / Heading: "FROM THE BLOG" + "VIEW ARCHIVE →" right
- `site.posts limit:3` — title left, date right, dividers between rows

### 5. Let's Build Something
- Background: `#f5f0e8`
- Large display heading + subtext + red "GET IN TOUCH" button → `/contact`

### 6. Footer
- Replaces existing footer in `default.html`
- `LAYER|TWENTY|TWO` brand left, GitHub + Mastodon links right
- Copyright line below
