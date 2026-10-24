# Model per task

A starting point, not a rule. Pick the model with `/model <id>` in Claude Code, or per
subagent. Change it when a check tells you to, not by feel: a cheaper model that needs
three tries is not cheaper.

| FDD step | Model | Why |
|---|---|---|
| Explore: search the code, the rules, the logbook | `claude-haiku-5-5`, often as a subagent | Reading and finding; fast and cheap |
| Close the questions, write the note | `claude-opus-5-5` | Judgment about what is a real decision |
| Build a slice | `claude-opus-5-5` | The default. Its effort defaults to `medium`; raise it for a hard slice |
| Many routine slices (renames, copy, wiring) | `claude-sonnet-5-5` | Same pattern repeated, at half the Opus price |
| A bug that resists, or a design across many files | `claude-fable-5-1` | The most capable model; slower and the most expensive |
| Reproduce: try to break the result | A different model from the author | A second model does not share the author's blind spots |
| Commit messages, logbook distill | `claude-haiku-5-5` | Short, well-shaped text |

## Prices

Per million tokens, input / output, on the Anthropic API, as listed on 2026-10-06. On a
Claude subscription you pay the plan, not per token; the order still says how fast each
one uses your limits.

| Model | Context | Input | Output |
|---|---|---|---|
| `claude-fable-5-1` | 1M | $10 | $50 |
| `claude-opus-5-5` | 1M | $4 | $20 |
| `claude-sonnet-5-5` | 1M | $2 | $10 |
| `claude-haiku-5-5` | 1M | $0.10 | $0.50 |

Haiku 5.5 costs more above 100K tokens of prompt. Check current prices before quoting them:
https://platform.claude.com/docs/en/about-claude/pricing

A 1M window is not a reason to fill it: one slice per clean session still holds (see
[`tools.md`](./tools.md#context-fdd-statusline)).
