# Contract: `POST /api/waitlist`

On-demand Astro endpoint (`export const prerender = false`) → Node serverless function on Vercel.
It is the only server-rendered route. It must work for **both** a no-JS native form POST and a
JS `fetch`.

## Request

- **Method**: `POST`
- **Content-Type**: `application/x-www-form-urlencoded` (native form) or `application/json` (fetch)
- **Fields**:
  | Field | Required | Notes |
  |-------|----------|-------|
  | `email` | yes | The lead's email. |
  | `company` | no | **Honeypot** — must be empty for a real human. Hidden from users. |
  | `source` | no | Optional attribution tag. |

## Behavior

1. Parse body (form or JSON).
2. **Honeypot**: if `company` is non-empty → respond as success (200 / redirect) but **do not**
   store anything.
3. **Validate** `email` via `validateEmail`. On failure → 400 (JSON: `{ ok:false, error:"invalid_email" }`;
   no-JS: redirect to `/#wl-invalid`).
4. **Store**: insert into the Supabase `waitlist` table using the anon key (INSERT-only RLS).
   - success → 200
   - unique-email violation (`23505`) → 200 (idempotent; same success UX)
   - any other DB/network error → 502 + retry message (no-JS: redirect to `/#wl-error`); never
     silently drop. Missing credentials in a real run also return 502 (never a fake success).
5. **Never** log the email value or any secret.

## Response

| Scenario | JS (`fetch`, JSON) | No-JS (form) |
|----------|--------------------|--------------|
| Success / duplicate | `200 { ok:true }` | `303` redirect → `/#wl-success` |
| Invalid email | `400 { ok:false, error:"invalid_email" }` | `303` redirect → `/#wl-invalid` |
| Provider error | `502 { ok:false, error:"provider" }` | `303` redirect → `/#wl-error` |
| Honeypot tripped | `200 { ok:true }` (not stored) | `303` redirect → `/#wl-success` |

The no-JS states are revealed on the static page via CSS `:target`.

## Security

- `SUPABASE_URL`, `SUPABASE_ANON_KEY` read from env only; never in the repo or client bundle.
- RLS on `public.waitlist` allows **INSERT only** for the anon role — the key cannot read or delete
  the list. Reading requires the service role (server/dashboard).
- No secret or raw email is logged.
- CORS: same-origin only (no cross-origin POST needed).

## Test obligations (test-first)

- `validateEmail`: valid/invalid/empty/overlong/whitespace cases (Vitest).
- `honeypot`: empty → proceed, non-empty → silent success (Vitest).
- `waitlist` mapping: builds the correct insert; maps unique-violation → success; maps other errors
  and missing credentials → error (Vitest, supabase-js mocked).
- e2e (Playwright): happy submit, **no-JS** submit, duplicate→success, invalid→inline error.
