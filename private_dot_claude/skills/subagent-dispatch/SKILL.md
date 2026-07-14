---
name: subagent-dispatch
description: >-
  Routing, prompt requirements, and capability limits for subagent dispatch.
  Consult before dispatching any subagent, workflow, or agent team.
  Covers: confabulation detection in agent results, agent type selection (non-delegating vs general-purpose), required prompt boilerplate, and agent team criteria.
  Also trigger when the user says "dispatch an agent", "use agents", "spawn agents", or when about to dispatch a subagent.
---

# Subagent dispatch

## Prompt and result handling

Include an uncertainty directive in every subagent prompt: the agent must state when it doesn't know or can't verify something rather than guess.
Example directive: "If you don't know or can't verify something, say so."

Treat precision in subagent results (version numbers, URLs, quoted passages) as a confabulation signal; verify before acting.

Example: a subagent returned "5 levels, introduced in v2.1.172" with a fabricated quote; actual was 14+ levels.

Mechanical fallback: version numbers, URLs, or direct quotes in agent prose get one verification step. Results backed by code in context (file contents, grep output) don't need this check.

## Agent type selection

For research and lookup tasks, prefer non-delegating agent types: those that cannot recursively spawn sub-agents. This structurally prevents runaway delegation chains.

Use general-purpose agents (those with full tool access including sub-agent spawning) only when the task genuinely requires multi-tool orchestration.

Example: a general-purpose agent spawned 14 levels deep, consuming 57% of the token budget with no output.

Mechanical fallback: before dispatching a general-purpose agent, check: does this task need sub-agent spawning? If no, use a non-delegating type.

> [!note] Claude Code
> Non-delegating (read-only) types: `Explore` (code search), `claude-code-guide` (docs lookup).
> Full-capability type: `general-purpose`.

## Agent teams

Suggest agent teams only for genuinely parallelizable, independent work streams: multiple independent modules, competing hypotheses, multi-perspective reviews, large exploratory research.

Do **not** use for sequential tasks, same-file edits, or heavy inter-step dependencies.
