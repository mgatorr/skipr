# Spend less on AI, do the same work

Most AI spend is not the work you ask for. It is the same conversation sent again and
again, and subscriptions nobody uses. Fix those first.

## Know which bill you have

- **Subscription:** a fixed price. Using too much shows up as rate-limit messages, not as a
  bigger bill.
- **Usage credits on top of a plan** (older pages call them extra usage): this one is real
  money. Run `/usage-credits` and set a low monthly limit, or turn them off.
- **API key:** every token is billed. Set a monthly spend limit in the provider's console
  before the first run.
- `/status` in Claude Code shows which account a session is billing. Check it after you
  set any provider key in your shell.

## Where the tokens go

Every message re-sends the whole conversation. The habits that fix it:
[One task per session](./novice-guide.md#one-task-per-session) and, if you use agents,
[Agents and workflows](../skills/fdd/models.md#agents-and-workflows).

## Measure before you change plan

1. Keep the habits for two or three weeks.
2. Look at `/usage`: how close you get to the limits, and whether you hit them.
3. Never near them? Try the next smaller plan for one month. You can go back.
4. Change one thing at a time, or you will not know which one worked.

## Subscriptions that overlap

1. List every AI subscription: price per month and the last thing you did with it.
2. Two tools doing the same job, such as two coding agents: keep the one your checks run with.
3. Not used in the last 30 days: cancel it. You can subscribe again in a minute.

---

*skipr is independent and not affiliated with Anthropic.* “Claude” and “Claude Code” are trademarks of their respective owner.
