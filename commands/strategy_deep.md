# /strategy_deep — Multi-Perspective Iterative Strategy Design

## Purpose

Run a deep strategy refinement loop where multiple agents (Claude, Codex, Gemini) iteratively critique, extract issues, and rebuild a strategy — forging out structural weaknesses that a single-pass `/strategy` would miss.

Use this when the decision is complex, high-stakes, or involves multiple viable directions that need rigorous comparison.

## What this gives you

- A strategy that has been stress-tested from technical and product perspectives
- A structured issue list (critical/major/minor) that shrinks each round
- A final 3-option output with a "forging summary" showing what was caught and fixed

## What this does NOT do

- Replace model-native reasoning (extended thinking). This is about **multiple perspectives**, not deeper single-model thought
- Guarantee correctness. This is prompt engineering — the quality depends on the agents' analysis
- Auto-continue to `/plan`. You choose when to stop and what direction to take

## Arguments

`$ARGUMENTS` — A description of the strategic theme to explore

## Parameters

- **No round limit** — You decide when to stop at each checkpoint
- **Soft warning**: Round 3+ adds a diminishing-returns notice
- **Convergence**: When critical issues = 0, you're informed (continue or finalize is your call)

---

## Execution

### Phase 0: Define the Theme Core

Distill the theme into a single line. **This line is frozen across all rounds (drift prevention).**

```
Theme Core: [theme in one line]
```

Read context files as needed (only those relevant to the theme):
- Task file (`workflow.yaml` → `paths.tasks`)
- Roadmap (`workflow.yaml` → `paths.roadmap`)
- Lessons file (`workflow.yaml` → `paths.lessons`)
- Relevant source code (if applicable)

---

### Round 1: Broad Exploration + Issue Extraction

#### Step 1-1: Claude drafts the initial strategy

Build the strategy skeleton:
- Direction (what to achieve)
- Key components
- Expected risks

#### Step 1-2: Parallel critique from external agents

**Fix the roles. Do not send generic "review this" — constrain the perspective.**

Refer to `rules/agent-critics.md` for the role prompts.

##### Preferred Path (external tools available)

Run in parallel based on `workflow.yaml` tool settings:

- **tools.codex: true** → Send strategy + Technical Critic prompt to Codex
- **tools.gemini: true** → Send strategy + Product Critic prompt to Gemini

##### Fallback Path (no external tools)

Spawn two **Claude sub-agents** with the role prompts from `rules/agent-critics.md`:
- Sub-agent 1: Technical Critic role
- Sub-agent 2: Product Critic role

Mark their output as `(Claude fallback)` in the final summary.

#### Step 1-3: Claude integrates all issues

Merge all issues, deduplicate, and structure:

```
## Issue List (Round 1)

### Critical
- [source] Issue description

### Major
- [source] Issue description

### Minor
- [source] Issue description

(source = Codex / Gemini / Claude / Claude fallback)
```

---

### Checkpoint (mandatory after every round)

**Stop after each round and wait for user direction.**

Present:

```
## Round N Results

### Current Strategy (summary)
[2-3 sentences]

### Issue List
[structured list]

### Status
- Critical: N / Major: M / Minor: K
- [If Critical = 0] "No critical issues. You can refine majors further or finalize."
- [If Critical > 0] "N critical issues remain. Next round will attempt to resolve them."
- [If Round 3+] "Round N reached. Diminishing returns are possible from here."

Continue? Give direction if you want to adjust. Say "finalize" to proceed to final output.
```

Progress tracker:
```
Round N complete: Critical X→Y, Major A→B, Minor C→D
```

**User response patterns**:
- "OK" / "continue" → next round
- Direction adjustment → keep Theme Core, incorporate feedback into next strategy draft
- "finalize" / "wrap up" → jump to final output

---

### Round 2+: Issue Resolution Loop

#### Step N-1: Rebuild the strategy

Claude drafts a new strategy that resolves the previous round's issues.

**Context passed to next round (differential — not full history)**:
- Theme Core (always at the top)
- Current strategy (latest version only)
- Unresolved issue list (carried over from previous round)
- User direction adjustments (if any)

**Not passed**:
- Rejected drafts
- Resolved issues
- Detailed round discussions

#### Step N-2: Re-critique with external agents

Same format as Step 1-2. Include in the prompt: "The following issues were raised in the previous round. This is the revised strategy that addresses them."

#### Step N-3: Present checkpoint

Same format as the Checkpoint section above.

---

### Final Output

Present 3 options (A / B / C) plus a forging summary.

```
## Theme Core
[theme core]

## Forging Summary (Round Evolution)
| Round | Key Changes | Critical→ | Major→ | Notes |
|-------|-------------|-----------|--------|-------|
| R1 | Initial draft | N | M | - |
| R2 | [main issues resolved] | 0 | K | [user adjustments if any] |

## External Perspective Summary
| Perspective | Key Critique | Unique Insight |
|-------------|-------------|----------------|
| Codex (Technical) | [1-line summary] | [insight not found in other perspectives] |
| Gemini (Product) | [1-line summary] | [same] |

> Common across perspectives: [if any]
> (Claude fallback) marks indicate substitute analysis when Codex/Gemini were unavailable

## Options

### A: [user-facing change in one line]
- **What changes**: [non-technical description]
- **Issues resolved by forging**: [key issues this option addresses]
- **Remaining risks**: [minor issues still open]
- **Scope**: small / medium / large
- **Championed by**: Claude / Codex / Gemini

### B: [same format]
...

### C: [same format]
...

## Recommendation: [A/B/C] — Reason: [concise]

Which direction do you choose?
```

---

### Crystallization (after user selects an option)

Write the forging conclusion to `tasks/strategy_context.md`:

```markdown
status: completed
date: [YYYY-MM-DD]
theme: [Theme Core]

## Strategy: [selected option title]
- Direction: [1 sentence]
- Acceptance criteria:
  - [bullet points]
- Issues resolved by forging:
  - [list]
- Remaining risks:
  - [list]
```

Update the task file (`workflow.yaml` → `paths.tasks`) with the next task group and acceptance criteria.

**Stop here.** Do not continue to `/plan` without explicit user instruction.

---

### Mid-Round Saves (for interruption recovery)

At each checkpoint, also write interim state to `tasks/strategy_context.md`:

```markdown
status: in_progress
date: [YYYY-MM-DD]
theme: [Theme Core]
round: [N]

## Current Strategy (interim)
[2-3 sentence summary]

## Unresolved Issues
- [critical/major/minor] [issue]
```

This allows `/restart` to detect and resume an interrupted deep strategy session.

---

## Failure Modes

| Scenario | What happens | Mitigation |
|----------|-------------|------------|
| Theme is too vague | Agents produce generic critiques, rounds don't converge | Spend more time on Phase 0. A good Theme Core is specific and testable |
| No external tools (Codex/Gemini) | Claude fallback may echo-chamber | Role prompts in `agent-critics.md` constrain perspectives. Results are marked `(Claude fallback)` |
| Too many rounds (4+) | Context grows, response quality may degrade | Differential context (only latest + unresolved). Soft warning at Round 3 |
| User wants to change the theme mid-session | Theme Core is frozen by design | End the current session, start a new `/strategy_deep` with the new theme |

---

## Constraints

- **Do not change the Theme Core mid-session** (drift prevention lifeline)
- **Do not pass full history to next round** (differential context only)
- **Do not auto-continue to `/plan`** after final output
- **Do not skip user checkpoints** (mandatory gate after every round)
- **Do not artificially downgrade issue severity** to fake convergence
