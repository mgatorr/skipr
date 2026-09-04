# Guía para principiantes — skipr

Espejo corto en español. Guía completa (EN): [../novice-guide.md](../novice-guide.md)

**skipr** te ayuda a **escapar de la complejidad** de la IA: pocas tools, un harness que puede decir *no*, Claude Code primero. La terminal se enseña, no se esconde.

## Camino rápido

1. **Instala Claude Code CLI** (`claude --version`) — no solo la app de escritorio.
2. **Abre una terminal** que uses de verdad ([Ghostty](https://ghostty.org) en macOS, o Terminal.app / iTerm).
3. **Entra en la carpeta del proyecto** (viaje, cliente, culling) — no un vault genérico de prompts.
4. **Copia** [`skills/setup-harness/`](../../skills/setup-harness/) a `~/.claude/skills/setup-harness/`.
5. En esa carpeta: `claude` → *“Monta el harness en esta carpeta”*.
6. Ejecuta un checker: `./checks/naming.sh` (verde o rojo claro = victoria).

## Primera victoria

- `claude` funciona en la carpeta
- `CLAUDE.md` corto (≤ ~40 líneas de cuerpo)
- Al menos un check ejecutable en `checks/`
- Entiendes pass vs fail

## Niveles

| Nivel | Qué | Estado |
|---|---|---|
| **L0** | Terminal + carpeta del proyecto | usable ya |
| **L1** | Claude Code + harness | usable ya (núcleo) |
| **L2** | Cursor / OpenCode / Hermes… | después, opcional |

## Esto crece contigo

L0/L1 son el producto hoy. L2 es crecimiento honesto, no una puerta al principio.

Skill canónica: [`skills/setup-harness/SKILL.md`](../../skills/setup-harness/SKILL.md)
