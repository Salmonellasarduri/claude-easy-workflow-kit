#!/usr/bin/env bash
set -euo pipefail

# claude-easy-workflow-kit scaffold
# Usage: ./scaffold.sh [--force] [project-path]
#        ./scaffold.sh [project-path] [--force]
# Default project-path: current directory

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE=false
PROJECT_DIR=""

# Parse args (flags can appear in any position)
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    -h|--help)
      echo "Usage: $0 [--force] [project-path]"
      echo "  --force        overwrite existing files"
      echo "  project-path   destination directory (default: current dir)"
      exit 0
      ;;
    -*) echo "Unknown flag: $arg" >&2; exit 1 ;;
    *)
      if [[ -n "$PROJECT_DIR" ]]; then
        echo "Error: multiple project paths given ('$PROJECT_DIR' and '$arg')" >&2
        exit 1
      fi
      PROJECT_DIR="$arg"
      ;;
  esac
done

PROJECT_DIR="${PROJECT_DIR:-.}"

# Validate that the path exists (otherwise `cd` would fail with a cryptic message)
if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Error: project path does not exist: $PROJECT_DIR" >&2
  exit 1
fi

# Refuse to scaffold the kit into itself (catches accidental `./scaffold.sh --force` with no path)
if [[ "$(cd "$PROJECT_DIR" && pwd)" == "$SCRIPT_DIR" ]]; then
  echo "Error: refusing to scaffold into the kit's own directory ($SCRIPT_DIR)." >&2
  echo "       Pass an explicit project path: $0 [--force] /path/to/your/project" >&2
  exit 1
fi

echo "=== claude-easy-workflow-kit scaffold ==="
echo "Project: $(cd "$PROJECT_DIR" && pwd)"
echo ""

# --- Helper ---
copy_if_not_exists() {
  local src="$1"
  local dst="$2"
  if [[ -f "$dst" ]] && [[ "$FORCE" != true ]]; then
    echo "  SKIP  $dst (already exists, use --force to overwrite)"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  COPY  $dst"
  fi
}

# --- .claude/commands/ ---
echo "[1/5] Commands..."
for f in "$SCRIPT_DIR"/commands/*.md; do
  name="$(basename "$f")"
  copy_if_not_exists "$f" "$PROJECT_DIR/.claude/commands/$name"
done

# --- .claude/rules/ ---
echo "[2/5] Rules..."
for f in "$SCRIPT_DIR"/rules/*.md; do
  name="$(basename "$f")"
  copy_if_not_exists "$f" "$PROJECT_DIR/.claude/rules/$name"
done

# --- .claude/skills/ ---
echo "[3/5] Skills..."
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name="$(basename "$skill_dir")"
  for f in "$skill_dir"*; do
    [[ -f "$f" ]] || continue
    fname="$(basename "$f")"
    copy_if_not_exists "$f" "$PROJECT_DIR/.claude/skills/$skill_name/$fname"
  done
done

# --- schemas/ + workflow.yaml ---
echo "[4/5] Schemas & config..."
mkdir -p "$PROJECT_DIR/.claude/schemas"
copy_if_not_exists "$SCRIPT_DIR/schemas/handoff.md" "$PROJECT_DIR/.claude/schemas/handoff.md"
copy_if_not_exists "$SCRIPT_DIR/workflow.yaml" "$PROJECT_DIR/.claude/workflow.yaml"

# --- Project scaffolding (tasks/ + docs/) ---
echo "[5/5] Project scaffolding..."

create_if_not_exists() {
  local path="$1"
  local content="$2"
  if [[ -f "$path" ]] && [[ "$FORCE" != true ]]; then
    echo "  SKIP  $path (already exists)"
  else
    mkdir -p "$(dirname "$path")"
    echo "$content" > "$path"
    echo "  CREATE $path"
  fi
}

create_if_not_exists "$PROJECT_DIR/tasks/current.md" "# Current Tasks

> Active sprint tasks go here.

---
"

create_if_not_exists "$PROJECT_DIR/tasks/lessons.md" "# Lessons Learned

> Record corrections and patterns to avoid repeating mistakes.

---
"

create_if_not_exists "$PROJECT_DIR/docs/ROADMAP.md" "# Roadmap

## Completed

| Phase | Description | Status |
|-------|-------------|--------|

## In Progress

## Backlog
"

create_if_not_exists "$PROJECT_DIR/docs/DEVLOG.md" "# Dev Log (Index)

## Recent Sessions

---
"

create_if_not_exists "$PROJECT_DIR/tasks/strategy_context.md" "# Strategy Context

> This file is written by /strategy_deep and consumed by /design.
> Do not edit manually unless you know what you are doing.

status: empty
"

mkdir -p "$PROJECT_DIR/docs/devlog"

echo ""
echo "Done! Your project is ready to use /strategy, /strategy_deep, /design, /implement, /debugging, /reviewing, /save, /restart."
echo ""
echo "Next steps:"
echo "  1. Edit .claude/workflow.yaml to match your project (paths, tools, etc.)"
echo "  2. Run Claude Code and try /strategy to get started"
