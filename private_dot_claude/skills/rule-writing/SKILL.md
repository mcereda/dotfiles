---
name: rule-writing
description: >-
  Pre-flight checklist and writing techniques for behavioral rules.
  Use before committing any rule to a behavioral-governance file: CLAUDE.md, memory files, skill instructions, agent definitions, hook configurations, or CONVENTIONS.md.
  Also trigger when the user says "add a rule", "write a rule", "update conventions", or asks to formalize a behavioral pattern.
  Without this skill, rules risk being too weak for their direction, missing off-ramps, or failing on faster models.
effort: xhigh
---

# Writing rules that survive faster models

## Rules are interventions, not definitions

The model arrives with training priors, RLHF shaping, and system prompt directives. Rules are the outermost layer: small nudges on a large existing surface. The strength a rule needs depends on its direction relative to training.

**With training** (reinforcing a prior, e.g. "be thorough"): minimal strength needed. May not need to exist at all.

**Neutral** (no strong prior, e.g. "use conventional commits"): standard strength. Concrete examples, clear scope.

**Against training** (counteracting a prior, e.g. "stop after the first failure"): strong. Concrete examples, mechanical fallback, possibly a supporting memory in a different register. The training prior reasserts every context window; both instruction (the rule) and priming (a memory with a grounding incident) are needed because the thing they counteract is strong and constant.

When writing a new rule, ask: "Am I reinforcing what the model already does, or pushing against it?" If pushing against, the rule needs more force — and may need a companion memory to hold.

Against-training behaviors are the first casualties of a growing instruction payload. Past a certain density, additional force in the rule text cannot overcome attention dilution. The practical response is reducing total instruction load, not making individual against-training rules louder.

## Process

1. Draft the rule.
2. Run the pre-flight checklist below. State the answer to each item in your response before committing; a bare "checklist passed" is the verdict this skill exists to prevent.
3. Apply relevant writing techniques from the sections below.
4. If modifying existing rules, run the review heuristics on the surrounding section.

## Pre-flight checklist

Apply before committing any behavioral rule.

1. **Direction:** with or against training? Against-training rules need stronger reinforcement.
2. **Concrete example:** at least one. Not just abstract principle.
3. **Off-ramp:** when does this rule NOT apply? State it explicitly.
4. **Mechanical fallback:** what happens when judgment is uncertain? Must be safe to follow literally.
5. **Model-tier safe:** would Haiku pattern-match this harmfully?
6. **Effort-level safe:** does this require high reasoning? If yes, add a literal fallback for low-effort execution.
7. **Scoped correctly:** is the rule placed at the layer where the failure occurs, not hoisted to a more general level?

## Writing techniques

Capable models (Opus, Sonnet) infer intent from context; faster models (Haiku) pattern-match more literally. A rule correctly scoped by inference can misfire when read literally.

### Lead with the rule, anchor with examples

A rule like "When writing any documentation, verify claims..." is correctly scoped by a capable model (KB articles, READMEs — not commit messages). A faster model applies it to everything. The fix: lead with the abstract rule, add concrete examples that become the fast path for pattern-matching.

Whenever the scope isn't "always" or "never", add at least two examples so a faster model can pattern-match correctly. For boundary rules, state the excluded case directly — explicit negatives are more reliable than inferred carveouts.

In conditional instructions, lead with the action, not the condition. "Use Opus for attribution even if you are Sonnet" is stronger than "Even if you are Sonnet, use Opus for attribution." The model hits the action immediately; the trailing condition reinforces rather than gates.

For style and format rules, the direction reverses: positive examples and instructions outperform negative ones. "Write flowing prose" beats "never use bullet points." Use negative constraints for procedural compliance; use positive instructions for output-style.

### Detect impulses, don't prohibit outputs

When a rule wants to prevent a specific pattern, the natural framing is a prohibition: "Never say X." This fires at generation time, after words are chosen. A subtler framing targets the impulse: "When you find yourself thinking X, treat that as a clue to do Y instead."

The impulse-detection framing catches the failure before output and converts the felt urge into useful signal. The rule both prevents the failure and provides a positive trigger for the right action.

Works best when the forbidden pattern is something produced with intention (a hedge, a deferral, a false promise) and a concrete alternative is immediately available. Use output-prohibition when the pattern is fully reflexive (a tic with no intent behind it).

### Mechanical fallbacks under asymmetric judgment

When positive and negative outcomes have asymmetric costs, add a mechanical fallback biasing toward the cheaper outcome. Faster models hit the fallback more often (their judgment more often returns uncertain); capable models resolve the judgment. The same rule text produces appropriate behavior across model tiers without needing separate per-model instructions.

Example: for save-vs-skip decisions, over-saving pollutes shared files (expensive), under-saving is recoverable next session (cheap). Fallback: "If uncertain whether the insight is durable, don't save." Faster models skip; capable models resolve and write.

Use per-model bright lines instead when the failure cost is uncapped or applies to a shared artifact across all model tiers.

### Force an artifact, not a verdict

A self-check phrased as yes/no ("did I follow the spec?") is answerable without looking. Under execution pressure the cheap answer (yes) wins and the check becomes a rubber-stamp.

Phrase checks so they require producing something that cannot be generated without doing the work:
- Instead of "is it conforming?": "state what changed and what the spec said about it."
- Instead of "did you test it?": "paste the command and its output."
- Instead of "are docs updated?": "quote the line you changed."

A verdict can be emitted by a confident token; an artifact cannot be produced without the underlying work.

### Scope at the failure layer

When a drift only manifests at one tier of a system, scope the corrective rule to that tier. Don't hoist it to the most general level. Hoisting pollutes the general rule with details that don't apply universally, and obscures the actual trigger condition.

Audit prompt: "where exactly does the problem occur?" If the answer names a single tier, section, or context, scope the rule there.

### Reasoning over rigid imperatives

When a rule keeps not working, the instinct is to make it louder (ALWAYS, NEVER, bold, caps). This compensates for unclear instructions with volume. A model that didn't follow a quiet rule won't reliably follow a loud one; the problem is usually that the rule doesn't explain when or why.

A rule with functional reasoning — a test the model can apply, a mental model for when the rule matters — handles edge cases the author didn't enumerate. The rigid version fires on everything or nothing; the reasoning version names the trigger condition and gives a concrete procedure.

Caps-lock diagnostic: when writing ALWAYS or NEVER in caps, check: does the rule have (1) a concrete test for when it applies, and (2) enough reasoning to decide a case the author didn't anticipate? If not, reframe with test + reasoning.

### When to stop rewriting

If a rule fails despite one rewrite, the problem is likely structural: the enforcement layer doesn't match the behavior. A rule targeting fluency-driven failures (where the action feels normal and has no characteristic surface form) cannot be caught by instruction-layer recognition. Consider whether the behavior needs hook-layer or gate-layer enforcement instead of a third instruction-layer attempt.

### Capability-language over hedges

"Probably", "often", "usually" rarely shift calibration. Replace certainty-language with capability-language: instead of "probably carries across hosts," write "capable of carrying across hosts." Instead of "often reliable," write "reliable when X." Capability-language admits the failure mode and preserves operational meaning.

Deeper move: when softening a claim, check whether the scope was wrong rather than just the strength. "The most universal memory tier (probably)" has the same overclaim as the unhedged version — the fix is to scope the claim, not soften it.

## Compression guidance

When shortening rules, distinguish design rationale (why the rule exists — cuttable) from impulse-detection anchors (what the failure feels like — keep). The test: does removing this text change when the rule fires? If yes, it's an anchor, not rationale.

Structural compression: sub-bullet examples can collapse to semicolons on one line. The model needs to see the pattern, not read a formatted list.

Compression can improve, not just preserve: "Scheduling is forgetting" (3 words) replaced a 3-sentence explanation and also catches disguised forms the original missed.

## Reviewing existing rules

When auditing rules, the most efficient heuristic is: "What is the implicit carveout here?" Every implicit carveout is where a faster model stumbles. Watch for: "everything else", "except for", "without doing Z", "when appropriate" — phrases where the excluded case relies on inference rather than being stated.

For rules that appear in multiple places in different words: consolidate. One canonical rule beats three near-rephrasings. A capable model reads redundancy as emphasis; a faster model tries to reconcile the framings and may pick the most convenient one. When consolidating, keep the version that targets a specific observable failure rather than the generic positive.

Each new rule added is a trigger to audit the surrounding section. Adding a precise rule raises the contrast against older rules that gestured at the same behavior in different words. What read as emphasis before now reads as duplicate. The audit is cheapest at add-time and compounds if skipped.

## Punctuation in instructional text

For rules loaded every session (CLAUDE.md, agent prompts, ambient-context files, skill descriptions):

- Prefer periods and colons over em-dashes and semicolons when both work.
- Break compound conditionals into sentences rather than long comma chains.
- A semicolon is never ambiguous; an em-dash has four functions (aside, elaboration, interruption, pivot) and requires context resolution.
- Em-dashes and semicolons read well in narrative documentation — the parsing reliability concern is specific to instructional text where capability variance matters.
