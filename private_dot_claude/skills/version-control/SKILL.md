---
name: version-control
description: >-
  Commit attribution, branch strategy, and push safety conventions.
  Determines authorship format (--author vs Co-Authored-By) by contribution weight, branch strategy (worktree vs branch vs direct), and push permissions.
  Use before any git commit, git push, branch creation, or worktree setup. Also trigger when the user says "commit this", "push it", "create a branch", or "prepare for review".
  Without this skill, commits will use incorrect attribution format.
---

# Version control conventions

> [!important] Project-level rules override everything below
> Check the project's guidance (including AGENTS.md, CLAUDE.md, CONTRIBUTING.md, README.md) for git/commit conventions before applying these defaults.

## Change workflow

1. `git pull` before starting. Skip if already pulled this session on a solo repo.
2. Branch strategy:
   - **Worktree** (default): assume concurrent sessions unless told otherwise.
   - **Branch**: user confirms no concurrent sessions; changes need isolation.
   - **Direct on current branch**: only when user explicitly says so ("just fix this", "no worktree needed").
   When uncertain, use a worktree. Cost of unnecessary worktree: seconds. Cost of conflict: a conversation.
3. Make changes.
4. Commit outside the sandbox; GPG signing does not work inside it.
   If blocked, tell the user to run the command directly (prefix with `!`).
5. Cleanup: exit worktree if used; delete merged branches.

## Commit Attribution

Choose authorship by contribution weight:

1. **You wrote most changes**: use `--author="Claude Code (<model.name> <model.version>) on behalf of <user.name> <noreply@anthropic.com>"` with a `Co-Authored-By: <user.name> <user.email>` trailer.
   Resolve `<user.name>` and `<user.email>` via `git config user.name` and `git config user.email` (not `--global`); respects `includeIf` for per-repo identity. If the result contains `noreply`, fall back to `--global`.
   **Never** use `userEmail` from system context. Use model name from system context; never guess. If the user provided a literal model name, use it as-is.
2. **User wrote most, you assisted**: add `Co-Authored-By: Claude Code (<model.name> <model.version>) <noreply@anthropic.com>`.
3. **User wrote everything**: no Co-Authored-By.

> [!warning]
> `opusplan` attribution is unreliable; use model `opus` for correct attribution.
