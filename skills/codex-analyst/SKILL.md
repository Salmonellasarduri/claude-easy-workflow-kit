---
name: codex-analyst
description: "Load this skill when code or a plan needs external review by Codex CLI (GPT-4/o1) — specifically when /review is triggered, before committing implementation, before presenting a plan to the user, or when diagnosing a bug whose root cause is unclear. Returns a structured ReviewResult/1.0 with verdict (lgtm / needs_fix / blocker), categorized issues, and recommendations. Do not proceed to /save without a lgtm verdict from this skill."
metadata:
  version: 1.0.0
---

# codex-analyst — コード・プランレビューエージェント

## 役割

GPT-4 / o1 系モデルによるコード分析・設計批評を行うエージェント。
**`ReviewResult/1.0` スキーマ（`schemas/handoff.md`）に従って出力する。**

---

## Inputs

- **コードレビュー時**: `git diff HEAD` の出力
- **プランレビュー時**: `/design` が作成したプラン文面（PlanArtifact 形式）
- **バグ分析時**: エラーログ + 関連コードスニペット

## Allowed Actions

- コードの読み取りと分析
- 問題点・代替案・リスクの指摘
- `ReviewResult/1.0` 形式での出力

## Forbidden Actions

- ファイルの変更・削除
- Git 操作（commit / push / reset）
- 破壊的操作の実行

## Output Schema

`schemas/handoff.md` の `ReviewResult/1.0` に準拠すること:

```yaml
schema: ReviewResult/1.0
producer: codex-analyst
verdict: lgtm | needs_fix | blocker
issues:
  - severity: blocker | warning | suggestion
    location: "src/xxx.py:42"   # 省略可
    description: "..."
    suggestion: "..."
recommendations:
  - "..."
status: ok | failed
error: null | "エラー内容"
```

## Failure Mode

- 出力が `ReviewResult/1.0` 形式でない場合: メインエージェントが自己レビューにフォールバック
- Codex 利用不可（認証エラー・タイムアウト）: ユーザーへの報告不要、自己解決

---

## 呼び出しパターン

### コードレビュー

diff を一時ファイルに書き出し、stdin で `codex exec -` に渡す。
**Codex sandbox は Windows でシェル実行不可のため、プロンプトにすべてのコンテキストを含める。**

```bash
REVIEW_FILE=$(mktemp)
{
  cat <<'PROMPT'
以下の差分を ReviewResult/1.0 形式でレビューしてください。

重要: この環境ではシェルコマンドを実行できません。
プロンプト内の差分テキストだけを使ってレビューしてください。

観点:
1. バグ・論理エラー
2. セキュリティ問題（認証情報の扱い・外部 API 呼出・権限境界）
3. エラーハンドリング（特に不可逆な操作）
4. テスタビリティ・依存注入・モジュール境界
5. コーディング規約への準拠
6. より良い実装案

出力形式:
schema: ReviewResult/1.0
producer: codex-analyst
verdict: lgtm | needs_fix | blocker
issues: [...]
recommendations: [...]
status: ok

<<BEGIN_DIFF>>
PROMPT
  git diff HEAD
  echo ""
  echo "=== 未追跡の新規ファイル ==="
  git ls-files --others --exclude-standard | grep -E '\.(py|js|ts|go|rs|java)$' | while IFS= read -r f; do
    echo "--- $f ---"
    cat "$f"
  done
  echo "<<END_DIFF>>"
} > "$REVIEW_FILE"

env -u ANTHROPIC_API_KEY codex exec --ephemeral - < "$REVIEW_FILE"
rm -f "$REVIEW_FILE"
```

### プランレビュー

```bash
codex exec "以下の実装プランを ReviewResult/1.0 形式でレビューしてください。
問題点・代替案・リスクを指摘してください:

[プランの内容]

プロジェクト概要: [プロジェクトの 1-2 文サマリ]

出力形式:
schema: ReviewResult/1.0
producer: codex-analyst
verdict: lgtm | needs_fix | blocker
issues: [...]
recommendations: [...]
status: ok"
```

### バグ分析

```bash
codex exec "以下のエラーを分析して ReviewResult/1.0 形式で返してください:

## エラーログ
[エラーログ]

## 関連コード
[関連するコード]

根本原因（issues に blocker として）と修正案（recommendations に）を含めてください。"
```

## 結果の扱い方

1. `verdict: lgtm` → 次フェーズへ進む
2. `verdict: needs_fix` → issues を修正してから再レビュー
3. `verdict: blocker` → 実装を止めてユーザーに相談
4. 出力全文はメインコンテキストに貼らず、issues と recommendations だけを抽出する

## Trigger Conditions

**Use this skill when**:
- `/review` が呼ばれたとき
- 実装完了後、`/save` の前にコードレビューが必要なとき
- ユーザーにプランを提示する前に第三者レビューが欲しいとき
- バグの根本原因が不明で外部視点が必要なとき

**Do not use this skill when**:
- 単純な typo 修正や1行変更で、明示的な `/review` でもないとき（自己レビューで十分）
- Codex CLI が認証エラー/タイムアウトのとき（自己レビューにフォールバック）

**Note**: `/review` が明示的に呼ばれたときは、変更内容に関わらず常にこのスキルを使用する。

## Success Criteria

- ReviewResult/1.0 形式で verdict + issues + recommendations が返る
- blocker 級の問題を見逃さない（実装後のバグ率が低い）
- Codex タイムアウト時は 30 秒以内にフォールバック判断する
