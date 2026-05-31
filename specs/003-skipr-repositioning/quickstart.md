# Quickstart: skipr repositioning (feature 003)

Verification for the re-messaged landing under `landing/`.

## Run

```bash
cd landing
pnpm install
cp .env.example .env     # SUPABASE_* or WAITLIST_DRY_RUN=1
pnpm dev                 # http://localhost:4321
pnpm hero && pnpm og     # regenerate skipr hero + OG cards
pnpm test && pnpm test:e2e
pnpm build && pnpm lighthouse
```

## Verify the acceptance scenarios

1. **Understand skipr / anti-black-box (US1)**: open `/` → hero reads "Build real software with AI —
   and actually own it"; an anti-black-box section contrasts with Lovable/Base44 (you keep the code,
   the repo, the control); brand is **skipr** with the "not affiliated with Anthropic" disclaimer.
2. **How it works (US2)**: the 5 steps (setup → spec → code → GitHub → deploy) are shown in order.
3. **Waitlist (US3)**: submit a valid email → success; JS disabled → still works (unchanged).
4. **Article (US4)**: `/articles` shows "from no-code to software you own"; the token-cost article is
   gone (draft); the new article renders with SEO/OG + CTA.
5. **Spanish (US5)**: `/es/` renders the landing in Spanish; `lang`/`hreflang` correct.

## Quality / brand checks

- **Zero residual brand (SC-004)**: `grep -riE 'sorrel|cockpit' landing/dist || echo clean` → clean.
- **No secrets in bundle**: `grep -rE 'SUPABASE|eyJhbGci' landing/dist/client || echo clean` → clean.
- **Lighthouse ≥ 95** on `/`, `/es/`, and the article.
- **gitleaks** clean over tree + history.
