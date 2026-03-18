# claude-easy-workflow-kit

A workflow automation kit for Claude Code. Type `/strategy` and Claude handles planning, implementation, testing, review, and saving — you just choose options and say yes or no.

Built from 70+ real development sessions on [Artificial Personality](https://github.com/Salmonellasarduri/Artificial-Personality).

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
/strategy → /plan → /implement → /debug → /review → /save
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

### `/plan`

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

## Workflow

### Full Workflow (default)

```
/strategy ──→ /plan ──→ /implement ──→ /debug ──→ /review ──→ /save
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
| `/strategy` → `/plan` | User must choose a direction first |
| `/plan` → `/implement` | User must approve the plan |
| `/implement` → `/save` | Must pass `/debug` + `/review` |
| `/save` completion | Must push before proposing next phase |

---

## External Tools (Optional)

The kit works standalone. These tools add extra capabilities when available:

| Tool | What it adds | Required? |
|------|-------------|-----------|
| [Codex CLI](https://github.com/openai/codex) | Independent code/plan review | No |
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
| `tasks/strategy_context.md` | Strategy forging results (used by `/strategy_deep` → `/plan`) |
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
| `strategy_context.md` is stale (>24h) | `/plan` may use outdated strategy | Re-run `/strategy` or `/strategy_deep` |

---

## Upgrading

If you installed a previous version and want to add `/strategy_deep`:

1. Copy `commands/strategy_deep.md` to `.claude/commands/`
2. Copy `rules/agent-critics.md` to `.claude/rules/`
3. Replace `commands/strategy.md`, `commands/plan.md`, `commands/restart.md` with the updated versions
4. Create `tasks/strategy_context.md` (empty template — see scaffold output)

Or re-run `./scaffold.sh --force /path/to/your/project` to overwrite all files.

---

## Design Philosophy

This kit doesn't aim for full AI autonomy. It standardizes the procedural steps so **humans focus on decisions, not process**.

Every command stops at decision points and waits for your input. Claude handles the mechanical work between those points.

> **Important**: This kit is prompt engineering — it guides Claude's behavior through markdown instructions, not enforced logic. The quality depends on the model following the instructions, which it does reliably but not with mechanical guarantees.

---

## License

MIT

---

[日本語版はこちら / Japanese version](README.ja.md)
