-- skipr waitlist — owned list in our own Neon Postgres (Vercel Marketplace).
-- Apply once against the Neon database, e.g. in the Neon SQL Editor or:
--   psql "$DATABASE_URL" -f db/migrations/0001_waitlist.sql
--
-- Security model: access is gated by the Neon connection string, which is a
-- secret used only in the server-rendered /api/waitlist endpoint (never shipped
-- to the client). No anon/public role touches this table directly.

create table if not exists waitlist (
  id          uuid primary key default gen_random_uuid(),
  email       text not null unique
              check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  source      text,
  created_at  timestamptz not null default now()
);
