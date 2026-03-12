# claude-easy-workflow-kit scaffold (PowerShell)
# Usage: .\scaffold.ps1 [-ProjectPath <path>] [-Force]

param(
    [string]$ProjectPath = ".",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectPath = Resolve-Path $ProjectPath -ErrorAction SilentlyContinue
if (-not $ProjectPath) { $ProjectPath = "." }

Write-Host "=== claude-easy-workflow-kit scaffold ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectPath"
Write-Host ""

function Copy-IfNotExists {
    param([string]$Src, [string]$Dst)
    if ((Test-Path $Dst) -and (-not $Force)) {
        Write-Host "  SKIP  $Dst (already exists, use -Force to overwrite)" -ForegroundColor Yellow
    } else {
        $dir = Split-Path -Parent $Dst
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item $Src $Dst -Force
        Write-Host "  COPY  $Dst" -ForegroundColor Green
    }
}

function Create-IfNotExists {
    param([string]$Path, [string]$Content)
    if ((Test-Path $Path) -and (-not $Force)) {
        Write-Host "  SKIP  $Path (already exists)" -ForegroundColor Yellow
    } else {
        $dir = Split-Path -Parent $Path
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $Path -Value $Content -Encoding UTF8
        Write-Host "  CREATE $Path" -ForegroundColor Green
    }
}

# --- .claude/commands/ ---
Write-Host "[1/4] Commands..."
Get-ChildItem "$ScriptDir\commands\*.md" | ForEach-Object {
    Copy-IfNotExists $_.FullName "$ProjectPath\.claude\commands\$($_.Name)"
}

# --- .claude/rules/ ---
Write-Host "[2/4] Rules..."
Get-ChildItem "$ScriptDir\rules\*.md" | ForEach-Object {
    Copy-IfNotExists $_.FullName "$ProjectPath\.claude\rules\$($_.Name)"
}

# --- schemas/ + workflow.yaml ---
Write-Host "[3/4] Schemas & config..."
Copy-IfNotExists "$ScriptDir\schemas\handoff.md" "$ProjectPath\.claude\schemas\handoff.md"
Copy-IfNotExists "$ScriptDir\workflow.yaml" "$ProjectPath\.claude\workflow.yaml"

# --- Project scaffolding ---
Write-Host "[4/4] Project scaffolding..."

Create-IfNotExists "$ProjectPath\tasks\current.md" @"
# Current Tasks

> Active sprint tasks go here.

---
"@

Create-IfNotExists "$ProjectPath\tasks\lessons.md" @"
# Lessons Learned

> Record corrections and patterns to avoid repeating mistakes.

---
"@

Create-IfNotExists "$ProjectPath\docs\ROADMAP.md" @"
# Roadmap

## Completed

| Phase | Description | Status |
|-------|-------------|--------|

## In Progress

## Backlog
"@

Create-IfNotExists "$ProjectPath\docs\DEVLOG.md" @"
# Dev Log (Index)

## Recent Sessions

---
"@

$devlogDir = "$ProjectPath\docs\devlog"
if (-not (Test-Path $devlogDir)) { New-Item -ItemType Directory -Path $devlogDir -Force | Out-Null }

Write-Host ""
Write-Host "Done! Your project is ready to use /strategy, /plan, /implement, /debug, /review, /save, /restart." -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit .claude/workflow.yaml to match your project (paths, tools, etc.)"
Write-Host "  2. Run Claude Code and try /strategy to get started"
