# Contract: i18n routing (English primary, Spanish secondary)

Astro built-in i18n. English is the default locale with **no URL prefix**; Spanish lives under
`/es/`. English is shippable on its own first.

## Routes

| Locale | Landing | Articles index | Article |
|--------|---------|----------------|---------|
| en (default) | `/` | `/articles` | `/articles/<slug>` |
| es | `/es/` | `/es/articles` | `/es/articles/<slug>` |

## Config

`astro.config.mjs`:
```js
i18n: {
  defaultLocale: 'en',
  locales: ['en', 'es'],
  routing: { prefixDefaultLocale: false },
}
```

## Metadata

- `<html lang="en">` or `<html lang="es">` per page.
- `<link rel="alternate" hreflang="en" href=".../">` and `hreflang="es"` alternates on each page,
  plus `hreflang="x-default"` → English.
- Canonical points to the current locale's URL.

## Strings

- `src/i18n/ui.ts` exports `en` and `es` dictionaries with the same keys and a `t(locale)` helper.
- Missing `es` keys fall back to `en`.

## Behavior

- A locale switcher links the current page to its equivalent in the other locale.
- The waitlist endpoint is locale-agnostic (one `/api/waitlist`); success/error copy is localized
  client-side / via the page that renders the state.

## Test obligations

- e2e: `/` renders English, `/es/` renders Spanish; `lang` attribute correct; `hreflang` present.
- Switching locale keeps the visitor on an equivalent page and does not break the waitlist.
