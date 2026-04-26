# claude-easy-workflow-kit

A workflow automation kit for Claude Code. Type `/strategy` and Claude handles planning, implementation, testing, review, and saving — you just choose options and say yes or no.

Battle-tested across 1,600+ real development sessions on a 190K-line codebase (167K Python, 1,167 files, 900+ commits) — [Artificial Personality](https://github.com/Salmonellasarduri/Artificial-Personality), an autonomous Discord-based personality agent.

---

## Quick Start

### Unix / macOS / WSL

```bash
git clone https://github.com/Salmonellasarduri/claude-easy-workflow-kit.git
cd claude-easy-workflow-kit
./scaffold.sh /path/to/your/project
```

### Windows PowerShell

```powershell
git clone https://github.com/Salmonellasarduri/claude-easy-workflow-kit.git
cd claude-easy-workflow-kit
.\scaffold.ps1 -ProjectPath C:\path\to\your\project
```

### Manual Setup

Copy files to your project's `.claude/` directory:

```
commands/*.md  → .claude/commands/
rules/*.md     → .claude/rules/
schemas/       → .claude/schemas/
workflow.yaml  → .claude/workflow.yaml
```

---

## How It Works

Type `/strategy` in Claude Code. That's the only command you need to know.

```
You:    "I want to add login functionality /strategy"
Claude: "Here are 3 approaches. Which one?"
You:    "B"
Claude: (plans → implements → tests → reviews automatically)
Claude: "Review passed. Commit?"
You:    "Yes"
Claude: (commits, pushes, updates docs)
```

Under the hood, Claude chains these steps automatically:

```
/strategy → /design → /implement → /debug → /review → /save
```

You're only asked at decision points:

| When | What you're asked |
|------|------------------|
| Direction is set | "A, B, or C?" |
| Plan is ready | "Proceed with this plan?" |
| Review has issues | "Fix these?" |
| Ready to save | "Commit?" |

---

## 8 Commands

You typically only type `/strategy` (or `/strategy_deep` for complex decisions). Claude calls the rest automatically.

### `/strategy`

**Entry point.** Analyzes the current state and presents 3 directional options. You pick one, Claude sets up the tasks.

- **What it solves**: Decision paralysis, inconsistent project direction
- **Limitations**: Single-pass analysis. For complex, high-stakes decisions, use `/strategy_deep`

### `/strategy_deep`

**Multi-round strategy forging.** Runs iterative critique loops with multiple perspectives (Codex, Gemini, or Claude sub-agents) to stress-test a strategy before committing to it.

- **What it solves**: Blind spots in complex decisions. Catches structural weaknesses that a single-pass `/strategy` would miss
- **What it gives you**: A strategy tested from technical and product perspectives, with a documented trail of issues found and resolved
- **Limitations**: Token-intensive (multiple rounds). Best for high-stakes architectural or directional decisions, not routine tasks. External tools (Codex/Gemini) are recommended but not required

```
/strategy_deep "Should we migrate to microservices or keep the monolith?"
```

**When to use which:**

| Situation | Command |
|-----------|---------|
| Routine direction setting, small features | `/strategy` |
| Complex trade-offs, multiple viable paths | `/strategy_deep` |
| High-stakes architectural decisions | `/strategy_deep` |
| Quick bug fix or minor change | Neither (use fast path) |

### `/design`

Creates a detailed implementation plan with acceptance criteria. Automatically reads forging results from `/strategy_deep` if available.

### `/implement`

Writes code following the approved plan. Calls `/debug` automatically.

### `/debug`

Tests and verifies changes. Loops until acceptance criteria are proven.

### `/review`

Code review. Uses Codex CLI if available, otherwise self-reviews against a checklist.

### `/save`

Commits, pushes, and updates documentation. Only runs after `/review` passes.

### `/restart`

Detects where an interrupted session stopped and resumes. Also detects interrupted `/strategy_deep` sessions.

---

## Bundled Skills

Five skills are bundled in [`skills/`](skills/) and loaded on demand by the commands above:

| Skill | Purpose | Loaded by |
|---|---|---|
| `plan-researcher` | Codebase investigation, returns `ResearchResult/1.0` | `/design` |
| `codex-analyst` | Code/plan review via Codex CLI, returns `ReviewResult/1.0` | `/review` |
| `agent-dispatch` | Codex / Gemini / Claude role division reference | `/design`, `/review` |
| `ux-comm` | UX communication rules (timing semantics, plain language, copy-pasteable steps) | Before any user-facing report |
| `empirical-prompt-tuning` | Bias-free iterative prompt validation via blank subagents | When creating or revising any skill / slash command |

`empirical-prompt-tuning` is a Japanese translation/adaptation of [@mizchi](https://github.com/mizchi)'s upstream skill — see [Acknowledgments](#acknowledgments).

---

## Workflow

### Full Workflow (default)

```
/strategy ──→ /design ──→ /implement ──→ /debug ──→ /review ──→ /save
     │                                                            │
     └── or /strategy_deep (multi-round)                          └── next phase
```

### Fast Path (minor changes)

When `workflow.fast_path_allowed: true` and the change is small (3 files or fewer, no design decisions):

```
/implement ──→ /debug ──→ /review ──→ /save
```

### Quality Gates

| Gate | Rule |
|------|------|
| `/strategy` → `/design` | User must choose a direction first |
| `/design` → `/implement` | User must approve the plan |
| `/implement` → `/save` | Must pass `/debug` + `/review` |
| `/save` completion | Must push before proposing next phase |

---

## External Tools (Optional)

The kit works standalone. These tools add extra capabilities when available:

| Tool | What it adds | Required? |
|------|-------------|-----------|
| [Codex CLI](https://github.com/openai/codex) | Independent code/design review | No |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Large-scale analysis, research | No |
| [GitHub CLI](https://cli.github.com/) | Issue/Milestone management | No |

Enable in `.claude/workflow.yaml`:

```yaml
tools:
  codex: true
  gemini: true
  gh: true
```

---

## Generated Files

After scaffolding, these files are created (existing files are never overwritten):

| File | Purpose |
|------|---------|
| `tasks/current.md` | Active task tracking |
| `tasks/lessons.md` | Session learnings and error patterns |
| `tasks/strategy_context.md` | Strategy forging results (used by `/strategy_deep` → `/design`) |
| `docs/ROADMAP.md` | Project progress overview |
| `docs/DEVLOG.md` | Dev log index |
| `docs/devlog/` | Per-session detailed logs |

---

## Configuration

`.claude/workflow.yaml` is placed during setup. **It works out of the box** — only customize if your project uses different paths.

```yaml
paths:
  tasks: tasks/current.md     # your task file
  lessons: tasks/lessons.md   # your lessons file
  roadmap: docs/ROADMAP.md    # your roadmap
```

---

## Failure Modes

| Scenario | What happens | What to do |
|----------|-------------|------------|
| Claude skips `/review` | Workflow gate prevents `/save` | Run `/review` first |
| Session interrupted mid-implementation | State is lost | Run `/restart` to recover |
| `/strategy_deep` runs too many rounds | Context degrades | Stop at Round 3 unless issues remain critical |
| External tool (Codex/Gemini) unavailable | Falls back to Claude self-analysis | Results are marked `(Claude fallback)` |
| `strategy_context.md` is stale (>24h) | `/design` may use outdated strategy | Re-run `/strategy` or `/strategy_deep` |

---

## Pre-release Verification

When you author or substantially revise a skill / slash command, verify it before bundling.

| File | Purpose |
|---|---|
| [`evaluation/skill-quality-rubric.md`](evaluation/skill-quality-rubric.md) | 7-axis weighted rubric (trigger fit / self-containment / clarity / subagent-schema compliance / exit conditions / golden examples / communication). Pass ≥80, Conditional 70–79, Fail ≤69. 6 auto-fail conditions. |
| [`evaluation/skill-tuning-log.md`](evaluation/skill-tuning-log.md) | Per-skill iteration log paired with `empirical-prompt-tuning`. Records Iter 0 (static integrity check) → Iter N (dispatch-based blind test). |

Procedure:

1. **Iter 0 (static)** — score the skill against the 7-axis rubric without dispatch. Reconcile any frontmatter `description` ↔ body gap before moving on.
2. **Iter N (empirical)** — invoke `empirical-prompt-tuning` to dispatch blank subagents on prepared scenarios; record results in the tuning log.
3. **Convergence** — 2 consecutive iterations with zero new unclear points + metric variation within thresholds, or release at the 80-point line if the skill is non-critical.

The five bundled skills passed Iter 0 at 88–98 points (recorded in [`evaluation/skill-tuning-log.md`](evaluation/skill-tuning-log.md)).

---

## Upgrading

If you installed a previous version and want to add `/strategy_deep`:

1. Copy `commands/strategy_deep.md` to `.claude/commands/`
2. Copy `rules/agent-critics.md` to `.claude/rules/`
3. Replace `commands/strategy.md`, `commands/design.md`, `commands/restart.md` with the updated versions
4. Create `tasks/strategy_context.md` (empty template — see scaffold output)

Or re-run `./scaffold.sh --force /path/to/your/project` to overwrite all files.

---

## Design Philosophy

This kit doesn't aim for full AI autonomy. It standardizes the procedural steps so **humans focus on decisions, not process**.

Every command stops at decision points and waits for your input. Claude handles the mechanical work between those points.

> **Important**: This kit is prompt engineering — it guides Claude's behavior through markdown instructions, not enforced logic. The quality depends on the model following the instructions, which it does reliably but not with mechanical guarantees.

---

## Acknowledgments

- **`empirical-prompt-tuning` skill**: Japanese translation/adaptation of [`empirical-prompt-tuning`](https://github.com/mizchi/skills/tree/main/empirical-prompt-tuning) by [@mizchi](https://github.com/mizchi). Original work © mizchi, MIT-licensed. Full attribution and license text in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md). Note that the upstream version has since added several sections (Failure pattern ledger, Variant exploration, 4-phase trace interpretation, Fix propagation patterns, Environment constraints, Structural review mode) that CEWK has not yet backported.
- **`evaluation/skill-quality-rubric.md` structural template**: borrowed the 5-band + weighted + auto-fail framework from [`docs/evaluation-rubric.md`](https://github.com/RNA4219/manual-bb-test-harness/blob/main/docs/evaluation-rubric.md) in [RNA4219/manual-bb-test-harness](https://github.com/RNA4219/manual-bb-test-harness). The structural skeleton only — categories, weights, and auto-fail conditions are CEWK-specific and rewritten for skill-quality evaluation. We do **not** use manual-bb-test-harness as a runtime test harness for CEWK skills.

---

## License

MIT — see [`LICENSE`](LICENSE). Third-party licenses for bundled adaptations are listed in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md).

---

[日本語版はこちら / Japanese version](README.ja.md)
