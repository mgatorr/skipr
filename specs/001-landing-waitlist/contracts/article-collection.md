# Contract: `articles` content collection

Defines the article authoring contract so that **adding an article = adding one content file**
(FR-009 / SC-005), with the metadata SEO needs (FR-008).

## Location

- Files: `landing/src/content/articles/<slug>.md` (or `.mdx`)
- Schema: `landing/src/content/config.ts` (Zod, via `astro:content`)

## Frontmatter schema

```yaml
---
title: "How much context are your MCP servers wasting?"   # required
description: "A measured look at MCP tool-schema overhead." # required, ≤ ~160 chars
publishDate: 2026-05-31                                     # required (Date)
slug: how-much-context-your-mcp-servers-waste              # optional (defaults to filename)
ogImage: /og/mcp-context-cost.png                          # optional (falls back to default card)
draft: false                                               # optional (default false)
canonical: ""                                              # optional URL override
---
```

## Rendering rules

- **Index** (`/articles`): lists all `draft: false` entries, newest `publishDate` first, each as an
  `ArticleCard` (title, description, date, link).
- **Article page** (`/articles/<slug>`): renders body via `ArticleLayout`, includes per-page SEO/OG
  from frontmatter, structured data, and a **waitlist CTA** (FR-007).
- **Sitemap**: non-draft articles are included automatically; `draft: true` are excluded.

## Acceptance mapping

| Spec item | Contract guarantee |
|-----------|--------------------|
| FR-006 | Collection + index + per-article pages |
| FR-007 | Launch article present with a CTA |
| FR-008 | Frontmatter supplies title/description/canonical/OG; sitemap entry |
| FR-009 / SC-005 | New file → appears in index with no code change |
