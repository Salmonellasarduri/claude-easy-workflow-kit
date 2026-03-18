# claude-easy-workflow-kit

Claude Code で `/strategy` と打つだけで、開発が動き出すワークフローキットです。

あとは Claude が計画・実装・テスト・レビュー・保存まで自動で進めてくれるので、
**あなたがやるのは「選ぶ」と「はい/いいえ」だけ**です。

ある程度の自己デバッグをするので、小規模プロジェクトなら、プログラミングの知識がなくても使えます。

[Artificial Personality](https://github.com/Salmonellasarduri/Artificial-Personality) での 70 回以上の開発セッションから生まれました。

---

## 使い方

Claude Code で `/strategy` と打ちます。やりたいことがあれば一言添えるだけ。

```text
ログイン機能を追加したい /strategy
```

あとはこんな会話になります。

```
Claude: 「A, B, C の3案があります。どれにしますか？」
あなた: 「B」
Claude: （計画を作って提示）「この内容で進めていいですか？」
あなた: 「はい」
Claude: （実装 → テスト → レビューを自動で回す）
Claude: 「レビュー通りました。コミットしていいですか？」
あなた: 「はい」
Claude: （コミット・push・記録まで完了）
```

**あなたが打つコマンドは `/strategy` だけ**。
そこから先は Claude が自動で進めます。あなたは選択肢を選ぶか、はい/いいえを答えるだけです。

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

### 手動で入れる場合

`.claude/` フォルダに以下を配置しても使えます。

```text
commands/*.md  → .claude/commands/
rules/*.md     → .claude/rules/
schemas/       → .claude/schemas/
workflow.yaml  → .claude/workflow.yaml
```

---

## 裏で何が起きているか

知りたい人向けの説明です。普段は意識しなくて大丈夫です。

`/strategy` を起点に、Claude が以下の流れを **自動でつないで** 進めています。

```text
/strategy → /plan → /implement → /debug → /review → /save
```

あなたに聞かれるのは、こういう場面だけです。

| 場面 | 聞かれること |
|------|------------|
| 方針が決まったとき | 「A, B, C どれにしますか？」 |
| 計画ができたとき | 「この計画で進めていいですか？」 |
| レビューで問題があったとき | 「この指摘を修正しますか？」 |
| 保存するとき | 「コミットしていいですか？」 |

それ以外（実装、テスト、レビュー、ドキュメント更新）は Claude が自動で進めます。

---

## 8つのコマンド詳細

普段は `/strategy`（または複雑な判断には `/strategy_deep`）を打つだけです。残りは Claude が自動で呼び出します。

### `/strategy`
**唯一あなたが打つコマンド**。何をどう進めるかを整理する入口です。
Claude がコードベースや状況を見て、進め方の候補を出します。

- **何を解決するか**: 方向性の迷い、プロジェクトの一貫性の欠如
- **限界**: 1回の分析で完結。複雑で重要な判断には `/strategy_deep` を使ってください

### `/strategy_deep`
**多角的反復戦略設計**。複数の視点（Codex、Gemini、または Claude サブエージェント）で繰り返し批評・再構築し、戦略の穴を鍛造的に潰します。

- **何を解決するか**: 複雑な判断のブラインドスポット。1回の `/strategy` では見つからない構造的な弱点を捕まえる
- **何が手に入るか**: 技術とプロダクトの両面からテストされた戦略。発見・解決された課題の記録
- **限界**: トークン消費が大きい（複数ラウンド）。日常的なタスクではなく、アーキテクチャや方向性の重大な判断に使うのが最適。外部ツール（Codex/Gemini）は推奨だが必須ではない

```
/strategy_deep "マイクロサービスに移行すべきか、モノリスを維持すべきか？"
```

**使い分けガイド:**

| 状況 | コマンド |
|------|---------|
| 通常の方向付け、小規模機能 | `/strategy` |
| 複雑なトレードオフ、複数の有力な選択肢 | `/strategy_deep` |
| 重大なアーキテクチャ判断 | `/strategy_deep` |
| バグ修正や小さな変更 | どちらも不要（Fast Path を使う） |

### `/plan`
実装に入る前の作業計画を作るステップ。`/strategy_deep` の鍛造結果がある場合は自動で読み込みます。

### `/implement`
計画に沿ってコードを書くステップ。`/debug` を自動で呼び出します。

### `/debug`
動作確認や不具合の切り分け。受け入れ基準が証明されるまで自動でループします。

### `/review`
コードレビュー。Codex CLI があればそちらにも投げます。なければ自己レビューチェックリストで確認。

### `/save`
コミット・push・記録をまとめるステップ。`/review` 通過後にのみ実行されます。

### `/restart`
中断した作業を再開するコマンドです。
セッションが途切れたときに打つと、どこまで進んでいたかを検出して続きから再開します。
`/strategy_deep` の中断も検出して再開を提案します。

---

## `workflow.yaml` について

導入すると `.claude/workflow.yaml` が置かれます。
**最初は触らなくて大丈夫です。** デフォルトのまま動くようになっています。

```yaml
paths:
  tasks: tasks/current.md
  roadmap: docs/ROADMAP.md
```

---

## 外部ツール連携

このキットは**単体で動きます**。以下はあると便利なオプションです。

| ツール | できること | 必須？ |
|--------|------------|--------|
| [Codex CLI](https://github.com/openai/codex) | レビューや計画確認の補助 | いいえ |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 広めの調査や情報整理の補助 | いいえ |
| [GitHub CLI](https://cli.github.com/) | Issue や Milestone 操作の補助 | いいえ |

まずは Claude Code だけで始めて、必要になったら足してください。

---

## 導入後に作られるもの

セットアップすると、以下のファイル群が用意されます。
既にあるファイルは上書きせず、足りないものだけ作ります。

| ファイル | 用途 |
|---------|------|
| `tasks/current.md` | 今やっている作業の整理 |
| `tasks/lessons.md` | 次回以降に活かす反省・学びの記録 |
| `tasks/strategy_context.md` | 戦略鍛造の結果（`/strategy_deep` → `/plan` の橋渡し） |
| `docs/ROADMAP.md` | 全体の進み具合や今後の見通し |
| `docs/DEVLOG.md` | 開発ログの入口 |
| `docs/devlog/` | セッションごとの詳細ログ |

---

## アップグレード

以前のバージョンから `/strategy_deep` を追加するには:

1. `commands/strategy_deep.md` を `.claude/commands/` にコピー
2. `rules/agent-critics.md` を `.claude/rules/` にコピー
3. `commands/strategy.md`、`commands/plan.md`、`commands/restart.md` を更新版に差し替え
4. `tasks/strategy_context.md` を作成（空テンプレート）

または `./scaffold.sh --force` で全ファイルを上書きしてください。

---

## このキットの考え方

Claude Code は強力ですが、自由度が高いぶん、毎回やり方がぶれたり、
実装の後のテストやレビューが抜けやすくなったりします。

このキットは、それを防ぐために作られています。
目指しているのは、AI に全部丸投げすることではなく、
**人は判断に集中し、手順は選ぶだけにする**ことです。

> **重要**: このキットはプロンプトエンジニアリングです。Claude の振る舞いを Markdown の指示で誘導していますが、機械的な保証ではありません。モデルは指示に高い精度で従いますが、100% の保証はないことをご理解ください。

---

## License

MIT

---

[English version](README.md)
