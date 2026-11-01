# Spend less on AI, do the same work

Most AI spend is not the work you ask for. It is the same conversation sent again and
again, agents left on maximum effort, and subscriptions nobody uses. Fix those first.

## Know which bill you have

- **Subscription:** a fixed price. Using too much shows up as rate-limit messages, not as a
  bigger bill.
- **Extra usage on top of a plan:** this one is real money. Give it a low monthly cap in
  your account's usage settings, or turn it off.
- **API key:** every token is billed. Set a monthly spend limit in the provider's console
  before the first run.
- `/status` in Claude Code shows which account a session is billing. Check it after you
  set any provider key in your shell.

## Where the tokens go

- Every message re-sends the whole conversation, so the cost is roughly messages times
  context size. Habits that fix it: [One task per session](./novice-guide.md#one-task-per-session).
- Agents and workflows copy the session's model and effort. Maximum effort left on for days
  is the most common surprise: [Agents and workflows](../skills/fdd/models.md#agents-and-workflows).
- Ask for a ceiling when you want something thorough: "use at most 3 agents".

## Measure before you change plan

1. Keep the habits for two or three weeks.
2. Count the rate-limit messages and look at `/usage`.
3. None, and well under the limit? Try the next smaller plan for one month. You can go back.
4. Change one thing at a time, or you will not know which one worked.

## Tools that run on their own

Scripts and bots that call a model by themselves should not share your interactive plan.

- Give them their own API key with a hard monthly cap. Keys go in environment variables,
  never in the repository.
- Use a small, cheap model for sorting, tagging and short summaries. A check decides if it
  is good enough, not taste.
- A gateway such as OpenRouter is handy for comparing models inside your own scripts.
  Through a gateway you pay per token, even for models your subscription already covers.
  Routing Claude Code itself to non-Claude models is not supported, and tool use can break.

## Subscriptions that overlap

1. List every AI subscription: price per month and the last thing you did with it.
2. Two tools doing the same job, such as two coding agents: keep the one your checks run with.
3. Not used in the last 30 days: cancel it. You can subscribe again in a minute.
4. The Claude Code extension also runs inside VS Code and Cursor; you do not need an editor
   subscription just to use it.
