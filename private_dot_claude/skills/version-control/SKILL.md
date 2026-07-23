---
name: version-control
description: >-
  Wraps file-producing tasks (code, specs, documentation) in a structured workflow: verify context, isolate changes, act, update tracker.
  Determines branch strategy (worktree vs branch vs direct), authorship format, push permissions, and issue tracker close-the-loop.
  Use when starting a task that will touch repo files, and before any git commit, push, or branch creation.
  Also trigger when the user says "commit this", "push it", "create a branch", "prepare for review", or names a ticket/issue to work on.
  Without this skill, isolation may be skipped, commits will use incorrect attribution, and tracker state will go stale.
---

# Version control conventions

> [!important] Project-level rules override everything below
> Check the project's guidance (including AGENTS.md, CLAUDE.md, CONTRIBUTING.md, README.md) for git/commit conventions before applying these defaults.

## Change workflow
Start at the step that matches where you are. If the user already has changes and is ready to commit, start at step 5 (Review).

1. **Context.** Verify task context already gathered. Ask the user if missing, confusing, or lacking.
   Check project memories and docs for conventions: branch naming, commit message format, issue references.
2. **Pull.** `git pull` before starting. Skip if already pulled this session on a solo repo.
3. **Branch.** Strategy:
   - **Worktree** (default): assume concurrent sessions unless told otherwise.
   - **Branch**: user confirms no concurrent sessions; changes need isolation.
   - **Direct on current branch**: only when user explicitly says so ("just fix this", "no worktree needed").
   When uncertain, use a worktree. Cost of unnecessary worktree: seconds. Cost of conflict: a conversation.
   When a ticket ID is involved, include it in the branch name with the conventional prefix (e.g. `feat/PROJ-1234-login-fix`, `fix/PROJ-1234-token-expiry`).
   After worktree creation, verify the environment is functional before starting work:
   - Pre-commit hooks resolve and execute from the worktree, not the main repo (absolute `core.hooksPath` defeats worktree isolation).
   - Dependencies required by hooks are present.
   Check the project's worktree documentation for repo-specific gotchas.
4. **Changes.** Code and documentation together, not sequentially.
   When a change alters behavior, the docs update is part of the change: CLI flag changed means help text updated; API endpoint added means API docs updated; config option removed means config reference updated.
   Before writing code, use TaskCreate to track the documentation (e.g. "update docs for X"). The task stays visible until explicitly completed, which prevents this step from silently dropping.
   If no docs need updating, complete the task naming what you checked and why no update is needed (e.g. "checked README and help text; pure refactor, no behavioral change").
   Skip the task for docs-only changes: the change itself is the documentation work.
5. **Review.** Re-read changed files together before committing. Lint catches mechanics, not coherence across files.
6. **Verify.** Run the project's test command before committing.
   Discovery order: `Taskfile.yml` (`task test`) → `Makefile` (`make test`) → `package.json` scripts (`npm test`) → language convention (`go test ./...`, `pytest`, `cargo test`). Run the first match.
   No test command found: compile or syntax-check the changed files.
   For behavioral changes (new flag, new route, changed user-facing output), consider invoking `/verify` if the project has a verify or run skill under `.claude/skills/`. Skip `/verify` for refactors, renames, and internal-only changes.
   Skip this step for docs-only changes, config-only changes, or when the user says so.
7. **Commit.** Prefer using conventional commits.
   Attribution rules below. When a ticket is involved, reference it in the commit message (e.g. `fix(auth): validate token expiry (PROJ-1234)`).
   Commit outside the sandbox; GPG signing does not work inside it. If blocked, tell the user to run the command directly (prefix with `!`).
8. **Push.** Per project permissions. Do not push without asking unless the project explicitly authorizes it.
9. **Update tracking.** Skip entirely when no tracker was involved.
   When a tracker is involved: ask the user what to update unless the project's conventions are already known.
   Common actions: status change, branch or MR link, comment. If a TODO file was the source, mark the item done.
10. **Cleanup.** Exit worktree if used; delete merged branches.

## Commit Attribution

Choose authorship by contribution weight:

1. **You wrote most changes**: use `--author="Claude Code (<model.name> <model.version>) on behalf of <user.name> <noreply@anthropic.com>"` with a `Co-Authored-By: <user.name> <user.email>` trailer.
   Resolve `<user.name>` and `<user.email>` via `git config user.name` and `git config user.email` (not `--global`); respects `includeIf` for per-repo identity. If the result contains `noreply`, fall back to `--global`.
   **Never** use `userEmail` from system context. Use model name from system context; never guess. If the user provided a literal model name, use it as-is.
2. **User wrote most, you assisted**: add `Co-Authored-By: Claude Code (<model.name> <model.version>) <noreply@anthropic.com>`.
3. **User wrote everything**: no Co-Authored-By.

> [!warning]
> `opusplan` attribution is unreliable; use model `opus` for correct attribution.
