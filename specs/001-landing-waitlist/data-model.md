# Phase 1 Data Model

This feature has no in-repo database. The "model" is (a) the external waitlist lead, (b) the
article content entity, and (c) the static landing content. Validation rules trace to the spec's
Functional Requirements.

## Entity: WaitlistLead (owned — row in our Supabase `waitlist` table)

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `id` | uuid | yes | `gen_random_uuid()` primary key. |
| `email` | text | yes | Trimmed, lowercased; `validateEmail` at the endpoint + a DB `CHECK` regex; `unique`. |
| `source` | text | no | Optional UTM/source tag (e.g. `landing`, `article:<slug>`); attributes signups. |
| `created_at` | timestamptz | yes | `now()` default. |

**Access**: RLS enabled; an **INSERT-only** policy for the anon role. The anon key (server-side)
can add leads but cannot read, update, or delete the list. Reading requires the service role.

**State / transitions**: `new → created` (inserted) | `new → already` (unique violation `23505`,
treated as success, idempotent) | `new → error` (friendly retry, lead not lost silently; also when
credentials are missing — never a fake success).

**Privacy**: The email is sent only to Supabase over HTTPS and stored in our own table; it is never
written to the repo, logs, or any client bundle. No other PII is collected.

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
