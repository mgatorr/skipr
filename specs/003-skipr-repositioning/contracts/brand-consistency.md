# Contract: brand consistency (zero residual)

The user-visible brand is **skipr** everywhere. After this feature, **no** `Sorrel` or `Cockpit`
string may remain in user-visible code, copy, titles, metadata, or committed image assets.

## Rule

- Brand string in all copy/titles/footer/OG/hero = `skipr`.
- Image asset files renamed: `assets/sorrel-hero.png` → `assets/skipr-hero.png`; OG cards regenerated.
- `package.json` name, README (root + `landing/`), and `specs/001` user-facing references updated.

## Out of scope (history, not user-visible brand)

- The repo working directory name `cockpit` and historical specs (`specs/001`, `002`) file paths.
- `docs/` historical notes that explicitly describe the rename.
- The GitHub repo is renamed `sorrel` → `skipr` (separate, via `gh repo rename`).

## Verification (SC-004)

- Build the site, then assert the built output contains no residual brand:
  `grep -riE 'sorrel|cockpit' landing/dist || echo clean` → must be clean (allowing only intentional
  history strings, which should not appear in `dist/`).
- A repository grep over `landing/src`, `landing/public`, `assets/`, and READMEs returns no
  user-visible `Sorrel`/`Cockpit`.
