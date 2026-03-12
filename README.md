# claude-easy-workflow-kit

Claude Code の `/command` 機能を使った、実戦検証済みの開発ワークフローキット。

**7つのコマンド**で「戦略 → 計画 → 実装 → テスト → レビュー → 保存 → 復旧」の全サイクルをカバーする。

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

### 手動コピー

`scaffold` を使わず、中身を自分の `.claude/` にコピーしてもOK:

```
commands/*.md  → .claude/commands/
rules/*.md     → .claude/rules/
schemas/       → .claude/schemas/
workflow.yaml  → .claude/workflow.yaml
```

---

## コマンド一覧

| コマンド | 説明 | いつ使う |
|---------|------|---------|
| `/strategy` | 現状を分析し、3つの方向性を提示 | 新しいフェーズを始めるとき |
| `/plan` | 実装タスクを設計し、受け入れ基準を設定 | 実装に入る前 |
| `/implement` | 承認済みプランに沿って実装・テストループ | コードを書くとき |
| `/debug` | テストデータ投入 → 検証 → クリーンアップ | 動作確認するとき |
| `/review` | コードレビュー（Codex or 自己チェック） | 実装完了後、保存前 |
| `/save` | コミット・push・ドキュメント更新 | レビュー通過後 |
| `/restart` | 中断からの自動復旧 | セッション再開時 |

---

## ワークフロー

### Full Workflow（標準）

```
/strategy → /plan → /implement → /debug → /review → /save
```

1. `/strategy` で方向性を決める（ユーザーが選択）
2. `/plan` で具体的な実装計画を立てる（ユーザーが承認）
3. `/implement` で実装し、`/debug` でテストする
4. `/review` でコードレビューを通す
5. `/save` でコミット・push

### Fast Path（小修正・緊急修正）

```
/implement → /debug → /review → /save
```

以下をすべて満たす場合のみ:
- 変更が 3ファイル以下
- 設計判断が不要
- ユーザーが具体的な修正内容を指示している

---

## 設定（workflow.yaml）

scaffold 後、`.claude/workflow.yaml` がプロジェクトに配置される。
デフォルト値はそのまま使える（Convention-over-Configuration）。

既存プロジェクトに合わない部分だけオーバーライドする:

```yaml
paths:
  tasks: my-project/tasks.md     # デフォルト: tasks/current.md
  roadmap: CHANGELOG.md          # デフォルト: docs/ROADMAP.md

tools:
  codex: true    # Codex CLI を使う（デフォルト: false）
  gemini: true   # Gemini CLI を使う（デフォルト: false）
  gh: true       # GitHub CLI を使う（デフォルト: false）
```

---

## ファイル規約（デフォルト）

scaffold は以下のファイルを自動作成する（既存があればスキップ）:

| ファイル | 用途 |
|---------|------|
| `tasks/current.md` | アクティブタスク（/plan, /implement, /restart が参照） |
| `tasks/lessons.md` | 自己改善ログ（修正指摘を記録して同じミスを防ぐ） |
| `docs/ROADMAP.md` | フェーズ進捗（/strategy, /save が参照） |
| `docs/DEVLOG.md` | 開発ログインデックス（/save が更新） |
| `docs/devlog/` | 月別セッション詳細 |

---

## 外部ツール連携（オプショナル）

すべてのコマンドは外部ツールなしで動作する。ツールがある場合はより高品質な結果が得られる。

| ツール | 用途 | なくても動く？ |
|--------|------|--------------|
| [Codex CLI](https://github.com/openai/codex) | コードレビュー・プランレビュー・バグ分析 | はい（自己レビューにフォールバック） |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 大規模コードベース分析・Web調査 | はい（Explore サブエージェントで代替） |
| [GitHub CLI](https://cli.github.com/) | Issue/Milestone 管理 | はい（GitHub 連携をスキップ） |

---

## 向いているプロジェクト

- Claude Code を日常的に使っている開発プロジェクト
- 1人〜少人数のチームで、ワークフローを型化したい
- 新規プロジェクトの立ち上げ時
- 既存プロジェクトにワークフローを後付けしたい

## 向いていないプロジェクト

- Claude Code を使わないプロジェクト
- 既に CI/CD で品質ゲートが十分に整備されている大規模チーム
- コマンドの日本語が読めないチーム（英語版は今後対応予定）

---

## 既存プロジェクトへの導入

1. `scaffold.sh` を実行する（既存ファイルは上書きしない）
2. `.claude/workflow.yaml` のパスを既存構造に合わせて編集する
3. `tasks/` や `docs/` が既にある場合、`workflow.yaml` のパスをそちらに向ける
4. 既存の CHANGELOG.md を ROADMAP 代わりに使うなら `paths.roadmap: CHANGELOG.md`

---

## 設計思想

このキットは [Artificial Personality](https://github.com/Salmonellasarduri/Artificial-Personality) プロジェクトの74セッション・30+フェーズの実戦から生まれた。

核となる原則:
- **ゲートで品質を守る** — レビューなしに保存しない、承認なしに実装しない
- **AIツールに依存しない** — Codex/Gemini はあれば使うが、なくても動く
- **成果物の型を統一する** — ReviewResult/PlanArtifact でコマンド間のハンドオフを明確に
- **自己改善を仕組みにする** — lessons.md で同じミスを繰り返さない

---

## License

MIT
