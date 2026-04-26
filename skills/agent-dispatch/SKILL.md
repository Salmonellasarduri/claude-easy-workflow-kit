---
name: agent-dispatch
description: "Use this skill when deciding which sub-agent (Codex / Gemini / Agent tool) to dispatch for a task, when the task matches patterns like cross-cutting codebase investigation, external spec research, algorithm verification, or pre-commit review. Defines role division, mandatory invocation timings (/design pre-presentation, /save pre-commit, algorithm correctness checks), and output summarization rules. Load this at the start of /design, /review, or whenever agent dispatch judgment is needed."
metadata:
  version: 1.0.0
---

# agent-dispatch — エージェント役割分担

> 出力 schema は `rules/subagent-schema.md` を参照（常時 auto-load）。

## 基本原則

**「単一モデルで完結させない。複数視点 → より良い解法。」**

---

## Claude Code（メインエージェント）

**責任範囲**: 実装・設計判断・git 操作・オーケストレーション・結果統合

- すべてのワークフローコマンドを直接実行する
- Codex / Gemini の呼び出しと結果の統合を担う
- 最終的な判断・コードの編集はすべてここで行う

---

## Codex CLI（GPT-4/o1 系）— コード分析

**責任範囲**: コードレビュー・アルゴリズム検証・設計批評・代替案提案

**必ず起動すべきタイミング**:
- `/design` → ユーザーに提示する前
- `/save` → コミット前 (`git diff HEAD`)
- 設計の多択状況（複数アーキテクチャ案の比較）
- アルゴリズムの正しさ検証
- バグの原因分析（ログ + diff を渡す）
- 自分の実装に自信がないとき

**呼び出し方**:
```bash
codex exec "（質問・依頼）"
# コードレビュー: diff は一時ファイル経由で stdin に渡す（sandbox が Windows でシェル不可のため）
# 詳細は commands/review.md を参照
```

**フォールバック**: 認証エラー/タイムアウト → 自己解決。ユーザーへの報告不要。

---

## Gemini CLI（1M トークンコンテキスト）— 大規模分析・調査

**責任範囲**: コードベース全体分析・Web 調査・画像分析・多角的アイデア出し

**必ず起動すべきタイミング**:
- 設計・機能のアイデア出し → 第三の視点を加える
- 5 ファイル以上を読む必要があるとき → コンテキスト爆発を防ぐ
- ライブラリ・仕様・外部サービスの調査（外部 API 仕様、SDK 仕様など）
- スクリーンショット・画像分析
- 市場調査・競合分析

**呼び出し方**:
```bash
gemini -p "（依頼）"
find src -name "*.py" | xargs cat | gemini -p "このコードベースを分析して..."
gemini -p "（分析依頼）" < screenshot.png
```

**フォールバック**: レートリミット超過 → Read/Glob/Grep で自己解決。

---

## 役割マトリックス

| タスク | Claude | Codex | Gemini |
|--------|--------|-------|--------|
| コード実装 | ◎ | - | - |
| 設計レビュー | ○ | ◎ | ○ |
| コミット前レビュー | ○ | ◎ | - |
| バグ原因分析 | ○ | ◎ | ○ |
| コードベース全体把握 | △ | △ | ◎ |
| Web 調査・外部仕様 | △ | - | ◎ |
| アイデア多様化 | ○ | ○ | ◎ |
| git 操作 | ◎ | - | - |
| ドキュメント更新 | ◎ | - | - |

---

## 大きな出力の扱い

Codex / Gemini から大きな出力が返ってきた場合:
1. **要約してからメインコンテキストに返す**
2. 全文をそのまま貼り付けない
3. 重要な判断・警告・推奨だけを抽出する
4. サブエージェント呼出時は `rules/subagent-schema.md` の 4 項目 schema を末尾に必ず添える
