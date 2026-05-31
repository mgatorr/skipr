-- Sorrel waitlist — owned list in our own Postgres (feature 001).
-- Run this in the Supabase SQL Editor of the dedicated Sorrel project.

create table if not exists public.waitlist (
  id          uuid primary key default gen_random_uuid(),
  email       text not null unique
              check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  source      text,
  created_at  timestamptz not null default now()
);

-- Row Level Security: the public endpoint uses the ANON key and may only INSERT.
-- No one with the anon key can read, update, or delete the list — reading requires
-- the service role (server/dashboard only).
alter table public.waitlist enable row level security;

drop policy if exists "waitlist_insert_only" on public.waitlist;
create policy "waitlist_insert_only"
  on public.waitlist
  for insert
  to anon, authenticated
  with check (true);
