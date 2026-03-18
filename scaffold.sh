#!/usr/bin/env bash
set -euo pipefail

# claude-easy-workflow-kit scaffold
# Usage: ./scaffold.sh [project-path]
# Default: current directory

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE=false

# Parse flags
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    -*) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

# Remove flags from PROJECT_DIR
if [[ "$PROJECT_DIR" == --* ]]; then
  PROJECT_DIR="."
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
echo "[1/4] Commands..."
for f in "$SCRIPT_DIR"/commands/*.md; do
  name="$(basename "$f")"
  copy_if_not_exists "$f" "$PROJECT_DIR/.claude/commands/$name"
done

# --- .claude/rules/ ---
echo "[2/4] Rules..."
for f in "$SCRIPT_DIR"/rules/*.md; do
  name="$(basename "$f")"
  copy_if_not_exists "$f" "$PROJECT_DIR/.claude/rules/$name"
done

# --- schemas/ + workflow.yaml ---
echo "[3/4] Schemas & config..."
mkdir -p "$PROJECT_DIR/.claude/schemas"
copy_if_not_exists "$SCRIPT_DIR/schemas/handoff.md" "$PROJECT_DIR/.claude/schemas/handoff.md"
copy_if_not_exists "$SCRIPT_DIR/workflow.yaml" "$PROJECT_DIR/.claude/workflow.yaml"

# --- Project scaffolding (tasks/ + docs/) ---
echo "[4/4] Project scaffolding..."

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

> This file is written by /strategy_deep and consumed by /plan.
> Do not edit manually unless you know what you are doing.

status: empty
"

mkdir -p "$PROJECT_DIR/docs/devlog"

echo ""
echo "Done! Your project is ready to use /strategy, /strategy_deep, /plan, /implement, /debug, /review, /save, /restart."
echo ""
echo "Next steps:"
echo "  1. Edit .claude/workflow.yaml to match your project (paths, tools, etc.)"
echo "  2. Run Claude Code and try /strategy to get started"
