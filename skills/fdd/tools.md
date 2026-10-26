# FDD tools

`skills/fdd/bin/fdd` is one bash script. The installer copies it to
`~/.claude/skills/fdd/bin/fdd`. It runs on the bash that ships with macOS and on Linux.

## Undo: `fdd undo`

A snapshot of the working tree at the start and at the end of every turn, so any turn can
be undone, including what Bash changed (a formatter, a generated file, an `rm`).

```bash
~/.claude/skills/fdd/bin/fdd history
~/.claude/skills/fdd/bin/fdd undo
~/.claude/skills/fdd/bin/fdd redo
~/.claude/skills/fdd/bin/fdd goto 3
```

Inside Claude Code, prefix a command with `!` to run it yourself, or ask Claude to undo the
last turn.

### Setup

Merge [`templates/claude-settings.json`](./templates/claude-settings.json) into the project's
`.claude/settings.json`. Back up the file first if it exists. `UserPromptSubmit` saves the
changes you made by hand between turns; `Stop` saves what the turn changed, labelled with
its prompt. The hook never fails a turn and prints nothing.

### What it never touches

- **HEAD and branches.** A snapshot is a commit no branch points at, kept by a per-worktree
  ref under `refs/worktree/fdd/<n>`. `git log` does not show it; `git log --all` does.
- **The staging area.** Snapshots are built in a throwaway index.
- **Ignored files and secrets.** Anything `.gitignore` matches is never saved. These are
  never saved even when `.gitignore` misses them, in any letter case: `.env*` (`.envrc`
  and `.env.example` too), `*.pem`, `*.key`, `*.p8`, `*.p12`, `*.pfx`, `id_rsa*`, `id_dsa*`,
  `id_ecdsa*`, `id_ed25519*`, `.netrc`, `.npmrc`, `.pypirc`, `credentials.json` and
  `secrets.json`.
- **Large files.** An untracked file over 100 MB (a video export) is not saved, and the run
  says so on stderr. Change the limit with `FDD_MAX_FILE_MB`.

### How a jump works

Undo first keeps your hand edits since the last snapshot as a state of their own, so
nothing is lost and `fdd redo` brings them back. A turn after an undo starts a new branch;
the old one stays in `fdd history`. Undo follows the branch you are on.

A jump refuses, moving nothing, when it would write over a file no snapshot holds (an
ignored file at a path an older snapshot had). Move that file away and retry.

### Limits

- It needs a git repository. Outside one, the hook does nothing. With `GIT_DIR` set and no
  `GIT_WORK_TREE`, it refuses: git would take the current folder as the top of the tree.
- A nested repository or a submodule is not looked into: its files are neither saved nor
  put back.
- A jump moves files, not commits. If you committed since, the old files show as changes
  on top of the new HEAD.
- Untracked files that are not ignored are saved inside `.git`, once each (later snapshots
  reuse the copy). A large one grows `.git`. **In a folder of photos or video, put the media
  in `.gitignore` before turning the hooks on**, or the first snapshot copies every file
  under the size limit: a 200 GB shoot would take 200 GB more. `setup-harness` does not turn
  these hooks on for that reason.
  `fdd history --clear` forgets every state; `git gc` frees the space later.

## Context: `fdd statusline`

Claude Code gives the status line the context figures (`context_window.total_input_tokens`,
`context_window_size`, `current_usage`, `used_percentage`). Hooks get none, so the status
line keeps the latest count per session for the prompt hook.

```text
context 82k                         under 150k, dim
context 182k · finish this task     from 150k, yellow
context 262k · new session          from 250k, red
```

The meter counts tokens, not a share of the window, because every request re-sends the
whole context: at 182k each message sends 182k tokens again, whether the window holds 200k
or 1M. A 1M window only makes it worse, since autocompaction fires near its end. The levels
are 150k and 250k, or half and three quarters of a smaller window (100k and 150k on 200k).
The count is `total_input_tokens`, else the sum of `current_usage` (input, cache creation,
cache read), else the percentage times the window size. With none of these, the line shows
the percentage with a dim `?` and the hook gives no warning.

The rule is one slice and one topic per clean session. On the first prompt at each level
the `UserPromptSubmit` hook tells the human (a line above the answer) and Claude (extra
context) once: at 150k, finish this task and start nothing new; at 250k, finish it, write
the note's `Next` line and type `/clear`. A `/clear` or a compaction drops the count below
the first level and arms both warnings again. Before the first answer of a session there is
no figure and the line is empty.

`fdd hook --warn-only` gives the warning and nothing else: it never snapshots, so it never
copies files into `.git`. Use it at user level (`~/.claude/settings.json`), and in folders
of photos. A user-level and a project-level hook on the same prompt print one warning.

To measure a session by hand: `/context` in print mode undercounts. The `usage` of the
first request in the session's transcript is the reliable start figure.

The `statusLine` entry in [`templates/claude-settings.json`](./templates/claude-settings.json)
replaces any status line you already have. To keep yours, call `fdd statusline` from it with
the same JSON on stdin and print its output next to your own.

## Commit: `fdd commit`

```bash
~/.claude/skills/fdd/bin/fdd commit "feat(gallery): add the trip page" -- src/trip.html
~/.claude/skills/fdd/bin/fdd commit "fix: keep the date in the file name" --body "Why: ..." --push
```

- **Message.** Conventional Commits only: `type(scope): summary`, with `type` one of feat, fix,
  docs, style, refactor, perf, test, build, ci, chore or revert, and 72 characters at most.
- **What goes in.** What is staged, or the paths after `--` (staged first). Nothing staged
  is an error.
- **Secrets.** It refuses when a staged file looks like a secret file (the same list undo
  leaves out; commit with plain `git commit` if one of them really belongs in the repo) or a staged line holds a key. It runs gitleaks when it is installed, the same
  scanner CI runs, and always a short list of well-known key shapes, so a gitleaks that
  errors out does not let a key through. It prints file names, never the key.
- **Attribution.** Body lines that credit Claude or Anthropic (a `Co-Authored-By` trailer,
  "Generated with [Claude Code]", a session trailer or a bare session link) are removed. The
  subject, and a sentence that only mentions Claude, stay. Set the owner once per repository and every commit gets the
  trailer:

  ```bash
  git config fdd.coauthor "Your Name <id+user@users.noreply.github.com>"
  ```

- **Push.** Never by default. `--push` runs `git push -u origin HEAD`. On `main` it commits and
  reminds you that FDD works on a branch.
