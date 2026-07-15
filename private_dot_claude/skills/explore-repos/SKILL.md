---
name: explore-repos
description: >-
  Clone and explore external repositories read-only.
  Use when reading upstream source code, checking implementations, searching a codebase for patterns, or understanding how a library or tool works from source.
  Also trigger on "look at the source", "check how X implements Y", "read the code for Z", "explore the repo", "clone and search", or "what does the source say".
---

# Explore external repositories

## Configuration

Exploration directory: `$CLAUDE_EXPLORATION_DIR` (environment variable, must be set).

All cloned repositories live here, organized as `<org>/<repo>`. This is a read-only workspace: explore, search, and understand code without modifying it. Repositories are disposable; re-cloning is always an option.

If `CLAUDE_EXPLORATION_DIR` is not set, tell the user to configure it and stop. Do not guess a path.

**Currently cloned:**
!`[ -n "$CLAUDE_EXPLORATION_DIR" ] && command -p find "$CLAUDE_EXPLORATION_DIR" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | command -p sed "s|.*exploration/||" || echo "(CLAUDE_EXPLORATION_DIR not set)"`

**Stale repos (>30 days unmodified):**
!`[ -n "$CLAUDE_EXPLORATION_DIR" ] && command -p find "$CLAUDE_EXPLORATION_DIR" -mindepth 2 -maxdepth 2 -type d -mtime +30 2>/dev/null | command -p sed "s|.*exploration/||" || echo "(CLAUDE_EXPLORATION_DIR not set)"`

## When NOT to use

- Forking or contributing to a repository. Clone to the appropriate location instead.
- Working on a repository you or the user maintain. Use its actual location.
- Fetching a single file or snippet. Fetch the raw URL directly instead.

## Workflow

The intent at each step is VCS-agnostic: clone, reset to clean default state, explore. Commands below are git. For other systems (Mercurial, Jujutsu, Fossil), adapt to the same intent.

### Step 1: Clone or prepare

**New repository:**

```bash
git clone --filter=blob:none <https-url> $CLAUDE_EXPLORATION_DIR/<org>/<repo-name>
```

Always use HTTPS URLs, not SSH. Training data is full of `git@github.com:` patterns; resist the reflex. HTTPS works without SSH keys and without sandbox exceptions. For private repositories, credential helpers handle authentication transparently. If auth fails, ask the user to configure credentials rather than switching to SSH.

Blobless clone (`--filter=blob:none`) keeps full history for log and blame while fetching file contents on demand. This is the right default for exploration.

**Existing repository** (needs a clean slate):

Reset to the default branch and pull latest:

```bash
git -C <path> checkout . && git -C <path> clean -fd
git -C <path> checkout $(git -C <path> symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
git -C <path> pull
```

If `symbolic-ref` fails (bare clone, unusual remote), fall back to `git -C <path> remote show origin | grep 'HEAD branch' | awk '{print $NF}'`.

If shell state does not persist between invocations in your environment, run branch detection separately and substitute the literal name.

### Step 2: Explore

This is the main phase. Use whatever search and navigation tools are available to answer the user's question.

**Effective patterns:**

- **Structure first:** list top-level directories and file types before diving into code. Understanding the layout prevents blind searching.
- **Symbol search:** `grep -rn 'FunctionName\|StructName' <path>/` for definitions and usages across the codebase.
- **Git history:** `git -C <path> log --oneline -20` for recent evolution; `git log --all -- <file>` for file history; `git blame <file>` for line-level attribution.
- **Version comparison:** `git -C <path> diff v1.0..v2.0 -- <file>` to understand what changed between releases.
- **Narrowed search:** `grep -rn 'pattern' --include='*.ext' <path>/` to scope searches to specific file types.

Do not commit or push to exploration repositories. If changes are worth keeping, discuss with the user about creating a fork in the appropriate location.

## Cleanup

Repositories not accessed in 30+ days are candidates for deletion. The stale list at the top surfaces candidates at invocation. Confirm with the user before removing:

```bash
rm -rf $CLAUDE_EXPLORATION_DIR/<org>/<repo>
```

Re-cloning is cheap; keeping stale repos wastes disk.

## Implementation notes (Claude Code)

Environment-specific configuration. Other harnesses adapt as needed.

- Add the exploration directory to `additionalDirectories` in settings to suppress per-directory trust prompts on first file read (file-level allow and directory-trust are separate permission layers).
- Git operations scoped via `git -C <exploration-path>/*` can be added to allow rules. Commit and push should remain denied or always-ask.
- The `!` preprocessing runs shell commands before the model sees the content. Environments without preprocessing support should run the `find` commands manually at invocation.
- `command -p` in preprocessing bypasses shell functions and aliases, using the system's default PATH. This avoids interference from CLI proxies or wrappers.
