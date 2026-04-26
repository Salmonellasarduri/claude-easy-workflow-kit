# Claude Easy Workflow Kit

🇯🇵 **日本語で読みたい方はこちら → [README.ja.md](README.ja.md)**  
Japanese guide available here.

**A Claude Code workflow kit for vibe coding without losing the thread.**

Type `/strategy`, choose a direction, approve the plan, and let Claude move through implementation, verification, review, and saving with clear checkpoints.

For bigger decisions, use `/strategy_deep`: a multi-perspective strategy loop that stress-tests architecture, product fit, hidden dependencies, and concept drift before you start coding.

This kit was shaped through **1,600+ real Claude Code development sessions** on **Artificial Personality**, a **190K-line / 1,167-file / 900+ commit** autonomous Discord personality-agent project. The main use case is simple: keep a large vibe-coded codebase from quietly drifting, breaking across file boundaries, or losing its original concept.

---

## What this does

Most AI coding sessions fail in the same places:

- you start coding before deciding the direction
- the plan is vague
- tests are skipped
- review is skipped
- commits contain accidental unrelated changes
- the project slowly drifts away from the original concept

Claude Easy Workflow Kit turns that into a repeatable loop.

```text
/strategy
  → choose A / B / C
  → approve plan
  → Claude implements
  → Claude verifies acceptance criteria
  → Claude reviews
  → you approve save
  → commit / push / devlog update
```

You stay responsible for decisions. Claude handles the procedure.

---

## Why `/strategy_deep` matters

`/strategy` is for ordinary work.

`/strategy_deep` is for decisions where a normal vibe-coding flow is likely to miss something:

- architecture changes
- large refactors
- feature direction changes
- product-concept alignment
- “this feels right, but might break the whole structure” moments

It runs an iterative strategy-forging loop:

```text
theme
  → Claude drafts a strategy
  → technical critic finds implementation / architecture risks
  → product critic finds UX / value / concept-drift risks
  → Claude rebuilds the strategy
  → repeat until you finalize
```

Use it when the cost of a wrong direction is higher than the cost of thinking one more round.

Example:

```text
/strategy_deep "Should we split the memory system into multiple services or keep it in the monolith?"
```

The output is not just “one answer.” It gives you:

- issues found by each perspective
- critical / major / minor risk counts
- what changed across rounds
- three final options
- a recommendation with remaining risks

This is the part of the kit that helps keep a large AI-assisted codebase coherent.

---

## Quick start

### macOS / Linux / WSL

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

Then open your project in Claude Code and run:

```text
/strategy
```

---

## Installation check

After scaffolding, your target project should contain:

```text
.claude/
  commands/
  skills/
  rules/
  schemas/
  workflow.yaml

tasks/
  current.md
  lessons.md
  strategy_context.md

docs/
  ROADMAP.md
  DEVLOG.md
  devlog/
```

If `.claude/skills/` is missing, the workflow commands may still appear, but the richer skill-based behavior will not be available.

---

## 30-second example

```text
You:
Add login functionality /strategy

Claude:
I see three directions.

A: minimal email/password login
B: OAuth-first login
C: temporary invite-code login

Recommendation: B, because...

You:
B

Claude:
Here is the implementation plan.
It will change these files, add these tests, and prove these acceptance criteria.
Proceed?

You:
yes

Claude:
Implements → debugs → reviews

Claude:
Review passed. Save this?

You:
yes

Claude:
Commits, pushes, and updates the devlog.
```

---

## The normal workflow

```text
/strategy → /design → /implement → /debugging → /reviewing → /save
```

| Step | What happens | Human checkpoint |
|---|---|---|
| `/strategy` | Reads the current project state and proposes 3 directions | Choose A / B / C |
| `/design` | Builds an implementation plan and acceptance criteria | Approve the plan |
| `/implement` | Writes code according to the approved plan | Usually none |
| `/debugging` | Proves the acceptance criteria with tests or scripts | Only if blocked |
| `/reviewing` | Reviews the diff before saving | Fix if needed |
| `/save` | Updates docs, commits, pushes | Approve before VCS write |

`/save` always requires explicit approval because it can commit and push.

---

## Fast path for small changes

If the change is small and concrete, the kit can skip strategy and design.

Fast path is allowed only when all of these are true:

1. the change affects **3 files or fewer**
2. no design decision is needed
3. the user gave a specific instruction

```text
/implement → /debugging → /reviewing → /save
```

Even on the fast path, debug and review are not skipped.

---

## Command guide

You usually only type `/strategy`.

| Command | Use it when | Output |
|---|---|---|
| `/strategy` | You want Claude to choose the next direction with you | 3 options + recommendation |
| `/strategy_deep` | The decision is high-stakes or structurally complex | Multi-round critique + final options |
| `/design` | You already know the direction and want a plan | Implementation plan + acceptance criteria |
| `/implement` | You have an approved plan | Code changes + verification loop |
| `/debugging` | You need to prove behavior or isolate bugs | Test/proof loop |
| `/reviewing` | You need a pre-save review | `lgtm`, `needs_fix`, or `blocker` |
| `/save` | Work is reviewed and ready to record | Commit / push / devlog update |
| `/restart` | A Claude Code session was interrupted | Recovery from the last known state |

---

## Bundled skills

The kit includes focused skills that support the workflow.

| Skill | Purpose |
|---|---|
| `plan-researcher` | Finds relevant files, dependencies, risks, and constraints before implementation |
| `codex-analyst` | Sends code or plans to Codex CLI for independent review when available |
| `agent-dispatch` | Defines when to use Claude, Codex, Gemini, or subagents |
| `ux-comm` | Keeps reports understandable: timing, plain language, copy-pasteable steps |
| `empirical-prompt-tuning` | Tests and improves skills / slash commands with blank-agent iterations |

These are optional in the sense that the workflow can fall back to Claude-only behavior, but they are part of the intended kit.

---

## Optional external tools

The kit works with Claude Code alone.

External tools add extra review and analysis capacity.

| Tool | Adds | Required |
|---|---|---|
| Codex CLI | Independent code and plan review | No |
| Gemini CLI | Large-context research and broad analysis | No |
| GitHub CLI | Issue and milestone operations | No |

Enable them in `.claude/workflow.yaml`:

```yaml
tools:
  codex: true
  gemini: true
  gh: true
```

If a tool is unavailable, the workflow falls back to Claude self-analysis.

---

## Configuration

The default config works out of the box.

```yaml
paths:
  tasks: tasks/current.md
  lessons: tasks/lessons.md
  roadmap: docs/ROADMAP.md
  devlog_dir: docs/devlog/
  devlog_index: docs/DEVLOG.md

workflow:
  fast_path_allowed: true
  auto_continue: true

git:
  commit_style: conventional
  show_summary: true
```

Only edit this when your project uses different paths or you want to disable auto-continuation.

---

## Generated files

| File | Purpose |
|---|---|
| `tasks/current.md` | Active task list and implementation plan |
| `tasks/lessons.md` | Repeated mistakes and project lessons |
| `tasks/strategy_context.md` | Output from `/strategy_deep`, consumed by `/design` |
| `docs/ROADMAP.md` | Project progress overview |
| `docs/DEVLOG.md` | Development log index |
| `docs/devlog/` | Per-session detailed logs |

Existing files are not overwritten unless you use the force option.

---

## Safety model

This kit is intentionally not “full autonomy.”

It uses gates:

- Claude does not choose the strategic direction for you
- Claude does not implement until you approve the plan
- Claude does not save until debug and review pass
- Claude does not commit or push without explicit approval
- Claude should not stage everything with `git add .`

Important: this is prompt engineering, not a mechanical guarantee. It improves consistency by giving Claude a stable playbook, but you should still review meaningful changes.

---

## Troubleshooting

### `/strategy` works, but later steps are not found

Check that project commands and skills were installed:

```bash
ls .claude/commands
ls .claude/skills
```

### Claude seems to skip review

Run:

```text
/reviewing
```

Then save only after the verdict is `lgtm`.

### A session was interrupted

Run:

```text
/restart
```

It checks git status, task state, and any interrupted `/strategy_deep` context.

### External tools fail

Set them to `false` in `.claude/workflow.yaml`:

```yaml
tools:
  codex: false
  gemini: false
  gh: false
```

The workflow will use Claude-only fallback behavior.

---

## Who this is for

This is especially useful if:

- you are vibe coding but want less chaos
- your project has grown beyond “one file and vibes”
- you want AI to keep records of what it changed
- you want review and verification to happen every time
- you need a way to keep concept, implementation, and roadmap aligned

It is not ideal if:

- you only want one-off code snippets
- you do not use Claude Code
- you want a deterministic build system or CI replacement
- you want the AI to make all product decisions without you

---

## Acknowledgments

- `empirical-prompt-tuning` is a Japanese translation/adaptation of `empirical-prompt-tuning` by @mizchi.
- The evaluation rubric structure was inspired by the 5-band / weighted / auto-fail framework from `manual-bb-test-harness`, rewritten for CEWK skill evaluation.

See `THIRD_PARTY_LICENSES.md` for details.

---

## License

MIT — see `LICENSE`.

[日本語版はこちら / Japanese version](README.ja.md)
