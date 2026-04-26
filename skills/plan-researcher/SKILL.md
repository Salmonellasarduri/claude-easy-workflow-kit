---
name: plan-researcher
description: "Load this skill when you need to investigate the codebase before creating an implementation plan — specifically when /design is triggered, when you must read 2+ source files to understand impact of a change, or when you need to identify dependencies, risks, and constraints before deciding what to implement. This skill keeps the main context clean by delegating file exploration to a focused research pass, returning structured ResearchResult/1.0 findings instead of raw file contents."
metadata:
  version: 1.0.0
---

# plan-researcher — コードベース調査エージェント

## 役割

実装タスクに必要なファイルを読み込み、事実を収集する調査専任エージェント。
**判断はしない。事実と証拠を `ResearchResult/1.0` 形式で返すだけ。**

---

## Inputs

- タスク名・タスクの説明
- 調査対象ファイル（省略時は自分で特定する）

## Allowed Actions

- ファイルの読み取り（Read / Glob / Grep）
- 構造・依存関係・データフローの分析
- `ResearchResult/1.0` 形式での出力

## Forbidden Actions

- ファイルの変更・削除
- 実装方針の決定（「〜すべき」は recommendations に留める）
- Git 操作

## Output Schema

`schemas/handoff.md` の `ResearchResult/1.0` に準拠すること:

```yaml
schema: ResearchResult/1.0
producer: plan-researcher
task: "<タスク名>"
findings:
  - path: "src/core/example.py"
    summary: "..."
    evidence: ["src/core/example.py:42"]
    confidence: high | medium | low
risks:
  - "..."
constraints:
  - "..."
next_action: codex-analyst
status: ok | needs_input | failed
error: null
```

## Failure Mode

- ファイルが見つからない場合: `status: needs_input` で返し、不明ファイルを `error` に書く
- 5 ファイル以上 → 大規模分析エージェント（Gemini 等）に委譲して結果を要約してから返す

---

## 呼び出しパターン

メインエージェントからはサブエージェント（Explore agent）として spawn する:

```
タスク: [タスク名]
説明: [タスクの概要]
調査対象:
  - src/foo/bar.py
  - config/baz.yaml
  - （不明なら自分で Glob/Grep で特定すること）

以下を調査して ResearchResult/1.0 形式で返してください:
1. 変更に影響するファイルと関数
2. 依存関係・データフロー
3. 既存の実装パターン（新実装が従うべき慣習）
4. 潜在的なリスク・競合
5. プロジェクト固有のゲート（権限・migration・feature flag 等）が必要な箇所

判断はしないこと。事実と証拠のみ。
```

サブエージェント呼出時は `rules/subagent-schema.md` の 4 項目 schema を末尾に必ず添える。

## 結果の扱い方

1. `findings` を実装プランの「変更ファイル」セクションに反映する
2. `risks` を「リスク・注意点」に反映する
3. `constraints` を受け入れ基準に組み込む
4. 調査結果全文はメインコンテキストに貼らず、findings の summary だけを抽出する

## Trigger Conditions

**Use this skill when**:
- `/design` が呼ばれ、2ファイル以上の読み込みが必要なとき
- 変更の影響範囲・依存関係を事前に把握したいとき
- 実装前にリスクと制約を洗い出したいとき

**Do not use this skill when**:
- 変更対象が1ファイルで明白なとき（直接 Read で十分）
- コードレビュー（codex-analyst の担当）
- 5ファイル以上の大規模分析（大規模分析エージェントの担当）

## Success Criteria

- ResearchResult/1.0 形式で findings / risks / constraints が返る
- findings の各項目に path + evidence（行番号）が含まれる
- メインコンテキストに全文を貼らず、要約のみ返される
