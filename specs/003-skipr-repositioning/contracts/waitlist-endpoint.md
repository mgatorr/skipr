# Contract: `POST /api/waitlist` (unchanged)

This feature does **not** change the waitlist endpoint. It remains as specified in
`specs/001-landing-waitlist/contracts/waitlist-endpoint.md`:

- On-demand Astro endpoint (`export const prerender = false`).
- Accepts form-encoded (no-JS) or JSON (fetch) POST.
- Honeypot → silent success; validate email; insert into Supabase `waitlist` (anon key, INSERT-only
  RLS); unique-violation → idempotent success; other error / missing creds → 502 (never fake success).
- No-JS path redirects to `/#wl-success|invalid|error` (revealed via CSS `:target`).
- Never logs the email or any secret.

Only change in this feature: the surrounding **copy** (and its localized `es` variant) — not the
endpoint behavior. The `source` field may carry the locale/section for attribution.
