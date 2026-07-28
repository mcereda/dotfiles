---
name: capture-sweep
description: >-
  Sweep capture buffers across all projects, promoting worthy entries to the current repository's documentation and discarding the rest.
  Consumes capture-buffer.md files from ~/.claude/projects/*/memory/ (per-project) and ~/.claude/memory/ (global, when present) in one pass.
  Use when the user says "sweep buffers", "process captures", "capture sweep", "promote buffers", or at the start of a session when buffers have pending entries.
  This is separate from extraction-triage: buffer entries are operator-captured with context (high signal, fast to triage), while extraction items are post-hoc agent guesses (lower signal, slower to verify). Do not combine them.
effort: xhigh
---

# Capture Sweep

Promote or discard buffered findings from across all projects.

**Arguments:** $ARGUMENTS

The argument is ignored; this skill always sweeps all buffers.

## Pre-filled context

**Pending buffers (global only; project buffers checked in step 2):**
!`ls ~/.claude/memory/capture-buffer.md 2>/dev/null`

## 0. Guard checks

Before scanning buffers, check for a same-name project skill:

```bash
ls .claude/skills/capture-sweep/SKILL.md 2>/dev/null
```

If it exists, warn the user: "This global capture-sweep skill shadows the project-level `.claude/skills/capture-sweep/SKILL.md`. The project version will not run while the global one is installed. Proceed, or abort so you can resolve the conflict?"

Wait for the user's answer. Do not proceed without confirmation.

## 1. Load project conventions

Check whether the current project has documentation conventions:

```bash
ls CONTRIBUTING.md CONVENTIONS.md .claude/docs/ 2>/dev/null
```

If `CONTRIBUTING.md` exists, read it. Follow its format, verification protocol, and writing conventions for all promoted content.

If no conventions file exists, use safe defaults:
- Standard markdown formatting
- No special frontmatter unless the project uses it
- Commit with conventional format
- Do not push unless the project's CLAUDE.md authorizes it

## Why discarding matters

Cheap capture moves the precision gate from write time to this sweep.
The sweep's job is to filter, not to preserve.
A sweep that promotes everything defeats the purpose: documentation stays high-signal because this sweep discards aggressively.
Target a discard rate of 25-65% across sweeps.
Below 25% suggests rubber-stamping; above 65% suggests capture is too noisy.

The training prior pulls toward preserving and including content.
This skill explicitly overrides that: discarding is the primary quality mechanism.
When uncertain, discard.
A discarded entry that was valuable will resurface in a future session or extraction; a promoted entry that was noise is maintenance debt forever.

## The content bar

For each entry, apply the reader-side test:

1. **State the prior:** "What would I assume here without this entry?"
2. **Compare:** Is that prior wrong or dangerously incomplete?
   - Wrong or incomplete: **promote** (a future session would act on stale knowledge without knowing to check)
   - "I'd look it up": **discard** (docs are fresher than any cache for things the session knows it doesn't know)

Two shapes:

- *Silent failure*: confident stale belief, nothing signals staleness at usage time. Admit, even from a single source.
- *Visible gap*: the session knows it doesn't know and would look it up. Discard.

## 2. Scan buffers

```bash
for f in ~/.claude/memory/capture-buffer.md ~/.claude/projects/*/memory/capture-buffer.md; do
  [ -s "$f" ] && echo "$f"
done
```

Glob-based because `!` preprocessing blocks `find` and `ls` on `~/.claude/projects` (not in `additionalDirectories`).
Regular Bash tool calls do not have this restriction, so step 2 can scan all projects.
This covers both project-level buffers and the global buffer (when present).

If no non-empty files exist, tell the user the buffers are empty and stop.

Read every file. Note the source (global or project name) and entry count.

## 3. Parse entries

Each buffer file follows this format:

```markdown
# Capture buffer

- [TAG1, TAG2] Title -- context. (session ID, date)
  Optional continuation lines with more context.
```

Tags are comma-separated inside one bracket pair: `KB`, `wiki`, `user-kb`.
An entry may have one tag (`[KB]`) or multiple (`[KB, wiki]`).
Identify which tags are relevant to the current repository. Process only those entries; leave the rest for a future sweep from the appropriate repo.

### In-project compliance check

When a buffer file belongs to the current project and contains entries targeting the current project's documentation, flag them as compliance gaps. These findings should have been written directly during the source session.

Example: the KB project's own buffer containing a `[KB]`-tagged entry means a KB session buffered instead of writing directly.

Still process them (they need promotion regardless). Count them separately in the report. Entries in OTHER projects' buffers targeting this repo are correctly buffered (cross-project routing is what the buffer is for).

## 4. Classify each entry

For each entry relevant to this repo:

1. Apply the content bar (state the prior, compare).
2. Classify the source type and confidence **now**, not during writing:
   - **Source type**: empirical (session observation), official docs, web content, training data.
   - **Confidence**: high (cross-verified or source code), medium (single authoritative source), low (inferred).
   - For empirical observations: external corroboration not required, but name the source (session ID, tool version, what was observed). Set confidence by documentation status.
   - For all other source types: follow the project's verification protocol.
3. Classify promoted entries:
   - **Update**: refines or corrects existing content. Search the project for the topic to find the target.
   - **Create**: warrants new content. Search to confirm nothing existing covers it.
   - **Defer**: potentially valuable but needs more context or verification.
4. Discarded entries: note the title and a one-line reason.
5. **Generalize**: for entries targeting other repos, check whether the finding overlaps with a topic the current project already documents. The current project's existing pages define what is in scope; generalization is not a reason to expand scope.
   Test: does the current repo already have a page about the tool, pattern, or system the finding is about? If yes, strip the project-specific context and check whether a general principle remains that the existing page does not yet cover. If no existing page overlaps, skip.
   Example (sweeping from KB): `[CONTRIBUTING.md gotchas] ignoreChanges on LaunchTemplate carries frozen AMI ID into new versions`. The KB already has `pulumi-aws-patterns.md`. Strip the LaunchTemplate-specific detail; the general principle (`ignoreChanges` on versioned resources carries state-frozen values into new versions) fits the existing page. Promote as a separate item. The original entry stays for the devops-start sweep.
   Off-ramp: not every project-specific finding generalizes. If stripping the specifics leaves only "this tool has a quirk" with no matching page in the current repo, it is project context.

Present the full classification to the user before processing, including source type and confidence for each promoted entry.
The user may override individual classifications.

## 5. Verify and process

Process in this order: edits first, creations second.

For each promoted entry, follow the verification protocol:
- If the project has a `CONTRIBUTING.md` with a verification protocol, follow it.
- Otherwise: name the source, classify confidence (high/medium/low). Mark claims that cannot be sourced as `[unverified]`.

Follow the project's documentation conventions for format, cross-referencing, and index updates.

### External target routing

Entries tagged for a different repository (e.g. `[wiki]` when sweeping from a non-wiki repo) stay in the buffer by default.
Do not auto-dispatch agents to other repos.
Report what is pending for other targets (tag, count, one-line summary each) so the user can decide: dispatch now, skip, or leave for a future sweep from the target repo.

If the user explicitly requests dispatch, compose the content and send it via the appropriate contributor agent. Include in the agent prompt:
- The composed content (not the raw buffer entry)
- Target file path
- Whether it is a new page or update
- "If you don't know or can't verify something, say so."

## 6. Validate and commit

Only when the sweep produced content changes in this repo.

If the project has a linter, run it:

```bash
# Check common locations
ls Taskfile.yml Makefile package.json 2>/dev/null
```

Use `task lint`, `make lint`, or `npm run lint` as appropriate. Fix any errors.

Commit all changes in one commit. Use a descriptive message:

```
update(<project>): capture sweep -- N promoted, M discarded
```

Push only if the project's CLAUDE.md authorizes it.

## 7. Clean up buffers

For each source buffer file:

- For entries with multiple tags: strip the processed tag(s), keep the entry with remaining tags.
- For entries whose last tag was just processed: remove the entry.
- Keep the file even when empty (only the header remains). Deleting and recreating adds MEMORY.md churn for no benefit.
- Update the corresponding `MEMORY.md` timestamp (global buffer uses `~/.claude/memory/MEMORY.md`; project buffer uses the project's `MEMORY.md`).
  Run `date +%Y-%m-%dT%H:%M:%S` to get the actual time; do not guess:
  `- [Capture buffer](capture-buffer.md) -- last swept YYYY-MM-DDTHH:MM:SS`

## 8. Report

Summarize:
- Buffers scanned and source projects
- Entry count and classification breakdown (include generalized entries as a separate line)
- In-project compliance gaps (entries that should have been written directly), if any
- Discard rate and whether it is within the 25-65% target band
- Content edited or created
- Entries pending for other targets (tag, count, summary)
- Deferred items (if any)
- Buffer cleanup status

## Self-monitoring

Check at the end:

- **Discard rate outside 25-65%.** Note in the report. Below 25%: the sweep may be rubber-stamping. Above 65%: capture may be too noisy.
- **Entries accumulating for unroutable tags.** If 3+ entries for a tag with no available target persist across sweeps, note in the report.
- **Discard rate below 25% by user direction.** When the user explicitly overrides discards ("save these, don't discard"), the rate drops below the monitoring band. This is correct, not rubber-stamping. The band monitors operator judgment; user-directed saves bypass it. Note in the report: "rate below band, N entries promoted by user direction."

## Worked example

Buffers: 3 projects, 7 entries total.

1. **Guard**: no project-level capture-sweep skill found. Proceed.
2. **Conventions**: `CONTRIBUTING.md` found, read. Project uses YAML frontmatter, `task lint`, `git push-reachable`.
3. **Scan**: `capture-buffer.md` in `devops`, `pikachu`, `claude-kb`.
4. **Parse**: 7 entries. Tags: 4 `[KB]`, 1 `[KB, wiki]`, 1 `[wiki]`, 1 `[user-kb]`.
5. **Classify** (sweeping from KB repo, processing `[KB]` tags):
   - `[KB]` "HAProxy notice drops info-level HTTP logs" -- prior: "notice level keeps HTTP request logs." Prior is wrong. Source: empirical (session observed syslog output). Confidence: high. Promote (update) target page.
   - `[KB]` "ECS task def requires explicit log driver" -- prior: "I don't know, I'd check the docs." Discard (visible gap, not silent failure).
   - `[KB, wiki]` "Spot drain via set-instance-health" -- prior: "only fix is more on-demand." Prior is incomplete. Source: empirical (tested in session). Confidence: medium. Promote (update). Wiki tag stays for future wiki sweep.
   - `[wiki]` "Pikachu DB failover requires manual DNS" -- skip (no KB tag; wiki-only).
   - `[user-kb]` "jq -S doesn't sort arrays" -- skip (not a KB tag).
   - (2 more classified similarly)
6. **Verify**: source and confidence already classified in step 5; verify non-empirical claims per protocol.
7. **Process**: updated target pages following CONTRIBUTING.md format.
8. **Validate**: `task lint` clean. Committed. `git push-reachable`.
9. **Cleanup**: fully processed entries removed. `[KB, wiki]` entry stripped to `[wiki]`. Non-KB entries unchanged.
10. **Report**: "3 projects, 7 entries (4 KB-relevant). 2 promoted, 1 discarded, 1 deferred. Pending for other targets: 1 wiki, 1 user-kb. Discard rate 33%."
