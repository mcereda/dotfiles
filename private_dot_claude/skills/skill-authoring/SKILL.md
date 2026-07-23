---
name: skill-authoring
description: >-
  Orchestrate skill creation and modification with learned conventions, portability checks, and safety review.
  Use when creating a new skill, modifying an existing skill's instructions or frontmatter, or reviewing a skill for quality.
  Also trigger on "create a skill", "write a skill", "new skill for", "update the skill", "review this skill", or "skill-authoring".
  Do NOT use for trivial edits (typos, date bumps, single-value config changes).
---

# Skill authoring workflow

**Off-ramp:** trivial edits (typo, date bump, single-value config change) do not need this workflow. Edit directly.

## Step 0: Load context

If a knowledge base or wiki is available, search it for pages about skill authoring, portability, permissions, and preprocessing. These topics are always relevant; others depend on what the target skill does.

Look for coverage of:
- Skill preprocessing (`!` syntax), description optimization, frontmatter options, body writing style
- Tooling portability (separating judgment from harness mechanics)
- Permission rules and `allowed-tools` safety (if the skill uses them)
- Harness dependency tracking (if the skill uses agents, hooks, workflows, or MCP)

If no KB is available, the skill is self-contained: Steps 1-4 embed the critical checks. A KB adds depth (worked examples, edge cases, version-specific notes) but is not required.

## Step 1: Understand the requirement

Before writing anything, answer:
- **What** does this skill do? (one sentence)
- **When** should it fire? (trigger conditions, explicit and implicit)
- **Where** does it live? Global (`~/.claude/skills/`) or project (`.claude/skills/`)?
- **Who** invokes it? User only, or should the model invoke proactively?
- **What model tiers** will run it? (affects body explicitness and effort override decisions)

### Frontmatter decisions

- **`model`**: global skills should NOT set this (would override the user's session choice). Project skills on quality-critical shared artifacts may pin a model.
- **`effort`**: prefer `xhigh` over `high` for complex skills. On Opus 4.7, `xhigh` is already the session default, so `effort: high` would reduce reasoning. On older models, `xhigh` gracefully falls back to `high`. Haiku has no effort setting; instruction text is the only lever.
- **`allowed-tools`**: restricts which tools the skill can use. Review every entry for safety before adding (Step 4).
- **`disable-model-invocation`**: blocks the Skill tool from loading the skill, but the model can still Read the file directly. Not a real gate.
- **`context: fork`**: runs the skill in an isolated context. Use for skills that should not see or affect the current conversation.

## Step 2: Write the description and trigger language

If `/rule-writing` is available, invoke it. Skill descriptions are rule-shaped: the same trigger language patterns and model-tier considerations apply.

### Description conventions

- Third person ("Extracts text from PDFs"), not second person ("You can use this to...")
- Structure as **what + when**: what the skill does, then when to use it
- Include explicit trigger phrases ("Also trigger on: ...")
- State negative triggers if the scope is ambiguous ("Do NOT use for ...")

### Pre-flight checklist (apply to the description and any behavioral constraints in the body)

This checklist targets trigger language and behavioral instructions, not procedural steps. "Clone with `--filter=blob:none`" is a procedure; "stop after first failure" is a behavioral constraint that needs this review.

1. **Direction**: with or against the model's training priors? Against-training instructions need stronger reinforcement. Example: "stop after first failure" fights the completion instinct.
2. **Concrete example**: at least one per non-obvious instruction. Not just abstract principle.
3. **Off-ramp**: when does this instruction NOT apply? State it. Implicit carveouts are where faster models stumble.
4. **Mechanical fallback**: what to do when judgment is uncertain. Must be safe to follow literally.
5. **Model-tier safe**: would Haiku pattern-match this harmfully? Scope with examples if the scope is not "always" or "never."
6. **Effort-level safe**: does this require high reasoning? If yes, add a literal fallback.
7. **Scoped correctly**: is the instruction placed where the failure occurs, not hoisted to a more general level?

### Routing rule vs description

If trigger conditions are fully enumerable, a CLAUDE.md routing rule is more reliable than the description. Both can coexist: the rule guarantees critical paths, the description catches the long tail. When a routing rule fully covers the trigger, configure `name-only` in `skillOverrides` to eliminate the description's token cost.

## Step 3: Design the body

Write the body as discursive prose with explicit conditionals. All model tiers benefit from this; weaker models need the explicitness that stronger models tolerate.

### Portability check

Separate judgment from mechanics. The test: could a different model read this skill and build its own version?

- **Judgment** (criteria, heuristics, skip conditions): write as plain prose. This is the portable core.
- **Mechanics** (tool dispatch, agent types, hook syntax): put in a clearly marked "Implementation notes" block. State the intent first ("process items concurrently"), then the implementation ("Workflow tool: `pipeline(items, ...)`").

If the skill uses harness primitives, document them. A dependency map (listing which agents and skills depend on which harness features) makes migration cost visible when evaluating a harness switch.

### Preprocessing safety

If using `!` backtick preprocessing:
- **No shell variables** (`$var`) unless the invoking project has broad Bash permissions. Variable expansion is settings-dependent: projects with matching allow rules bypass the static analyzer; restricted projects reject unknown variables as `simple_expansion`. For global skills, defer variable-dependent commands to the skill body.
- **No `allowed-tools: Bash(find *)`** or similar as a workaround. `find` has `-exec` and `-delete`; adding it to allowed-tools lets mutations run without prompting.
- **Use `command -p`** to bypass shell functions and aliases. Note: `command -p` uses the system PATH (BSD grep on macOS, no `-P` flag).
- **Keep pipelines simple.** Complex multi-command chains get rejected by the static analyzer. Move complex logic to a script in the skill directory.
- **Directory restrictions apply.** Commands referencing paths outside `additionalDirectories` are blocked regardless of other permissions.

### Content embedding

Global skills should embed the operational concepts they need rather than only referencing KB pages. A skill that says "see KB page X for details" fails on hosts where the KB is not cloned. Carry the operational subset inline; the KB carries the full reference layer.

## Step 4: Review

Before finalizing, verify:

1. **Body size**: aim for under 500 lines. Split supporting content into referenced files if needed.
2. **References one level deep**: SKILL.md references files directly, not through other referenced files.
3. **No unrequested abstractions**: does every section earn its presence?
4. **Frontmatter correct**: `model` only on project quality-critical skills; `effort` for reasoning quality; `allowed-tools` reviewed for safety.
5. **`allowed-tools` safety**: for each entry, check if the tool has mutation capabilities (find, git, etc.). If so, is the permission scope safe?
6. **Filing location matches scope**: global for cross-project, project for project-specific.
7. **Cold invocation test**: invoke the skill from scratch (`/skill-name`) and verify it loads without errors. Preprocessing failures (`simple_expansion`, directory restrictions, pipeline complexity) only surface on invocation, not when reading the file.

## Step 5: Optimization (optional)

If trigger precision matters and the description needs tuning, reference `/skill-creator:skill-creator` for the eval loop approach. Be aware of the cost: the loop spawns `claude -p` per query from the project root, loading full project context each time. Run from a minimal project directory to avoid burning budget.

## Step 6: File and configure

- **Global skill**: write to `~/.claude/skills/<name>/SKILL.md`. If global skills are managed by a dotfile manager (e.g. chezmoi), save to the manager's source after writing.
- **Project skill**: write to `.claude/skills/<name>/SKILL.md`.
- **CLAUDE.md routing rule** (if needed): draft the rule text. Apply the pre-flight checklist. Include an off-ramp for trivial edits.
- **`skillOverrides`** (if needed): `name-only` when a routing rule covers the trigger (eliminates description token cost); `user-invocable-only` when proactive invocation is unwanted.

## Implementation notes (Claude Code)

- `/rule-writing` is invoked via the `Skill` tool during Step 2. If unavailable, the pre-flight checklist embedded above is self-sufficient.
- `/skill-creator:skill-creator` (Step 5) is a plugin skill for description optimization. If the plugin is not installed, manual tuning with the pre-flight checklist is sufficient.
- Step 0 searches whatever KB or documentation system is available in the session. No specific KB structure is assumed.
