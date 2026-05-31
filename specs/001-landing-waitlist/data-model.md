# Phase 1 Data Model

This feature has no in-repo database. The "model" is (a) the external waitlist lead, (b) the
article content entity, and (c) the static landing content. Validation rules trace to the spec's
Functional Requirements.

## Entity: WaitlistLead (external — stored in the Resend Audience)

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `email` | string | yes | Trimmed, lowercased; must pass RFC-5322-pragmatic validation (`validateEmail`); max 254 chars. |
| `source` | string | no | Optional UTM/source tag (e.g. `landing`, `article:<slug>`); used to attribute signups. |
| `audienceId` | string | yes (server) | From `RESEND_AUDIENCE_ID` env; never client-visible. |
| `unsubscribed` | boolean | yes | Always `false` on create. |

**State / transitions**: `new → created` (stored) | `new → already_exists` (treated as success,
idempotent) | `new → provider_error` (friendly retry, lead not lost silently).

**Privacy**: The email is sent only to Resend over HTTPS; it is never written to the repo, logs, or
any local store. No other PII is collected.

## Entity: Article (content collection `articles`)

Zod schema in `src/content/config.ts`:

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `title` | string | yes | Used in `<title>` and OG title. |
| `description` | string | yes | Meta description + OG description (≤ ~160 chars recommended). |
| `publishDate` | date | yes | Drives index sort (newest first). |
| `slug` | string | no | Defaults to filename; overridable for clean URLs. |
| `ogImage` | string | no | Path under `/og/`; falls back to the site default card. |
| `draft` | boolean | no | Defaults `false`; `true` excludes from index + sitemap. |
| `canonical` | string (url) | no | Optional override for syndicated content. |

**Rules**: A new non-draft file under `src/content/articles/` appears in the index and sitemap with
no code change (FR-009/SC-005). The launch article ships `draft: false` with a body CTA.

## Entity: LandingContent (static, in components)

Not persisted; encoded in components/layout. Required pieces (FR-002, FR-005):

- Hero value proposition + the token-cost hero angle + primary waitlist CTA.
- "Coming soon" framing.
- Visible "not affiliated with Anthropic" disclaimer.
- Mobile-reachable CTA (responsive).
