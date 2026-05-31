# Phase 1 Data Model

This feature is mostly content/UI; the only structural addition is the i18n strings. The waitlist and
article entities are unchanged from `specs/001-landing-waitlist`.

## Entity: UI strings (i18n) — `src/i18n/ui.ts`

A per-locale dictionary of the landing's user-visible copy.

| Field | Type | Rules |
|-------|------|-------|
| `locale` | `'en' \| 'es'` | `en` is the default (no URL prefix); `es` is secondary (`/es/`). |
| keys | string | Hero headline/sub, anti-black-box copy, the 5 step labels/descriptions, CTA, disclaimer, nav. |

**Rules**: English is complete and shippable first; Spanish mirrors the same keys. A missing `es` key
falls back to `en`. A `t(locale)` helper returns the dictionary for a locale.

## Entity: Article (content collection — unchanged schema)

| Field | Type | Notes |
|-------|------|-------|
| `title`, `description`, `publishDate` | required | per existing schema |
| `ogImage`, `canonical`, `draft` | optional | `draft: true` retires an article from index + sitemap |

**This feature**: add `from-no-code-to-software-you-own.md` (`draft: false`); set the token-cost
article to `draft: true`.

## Entity: Waitlist lead (unchanged)

An email (+ optional source) stored in the owned Supabase `waitlist` table (INSERT-only RLS). The
mechanism does not change; only the surrounding copy does.

## Brand (cross-cutting rule)

User-visible brand is **skipr** everywhere; **zero** residual `Sorrel`/`Cockpit` in copy, titles,
footer, or committed image assets. Verified by a build-output grep (SC-004).
