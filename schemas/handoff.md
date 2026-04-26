# スキル間ハンドオフ契約スキーマ v1.0

コマンド間のデータ受け渡し形式を定義する。
各コマンドはこのスキーマに従って出力し、受け取り側もこの形式を前提とする。

---

## ResearchResult — plan-researcher / 調査系サブエージェントの出力

```yaml
schema: ResearchResult/1.0
producer: plan-researcher
task: "<タスク名>"
findings:
  - path: "src/core/example.py"             # 関連ファイルパス（省略可）
    summary: "処理は handle() に集中。..."
    evidence: ["src/core/example.py:42", "config.yaml:10"]
    confidence: high                          # high / medium / low
risks:
  - "config.yaml の decay タイミングが nightly job と競合する可能性"
constraints:
  - "外部 API 呼出は dry_run フラグでゲート"
next_action: codex-analyst
status: ok                                    # ok / needs_input / failed
error: null
```

### フィールドの役割

| フィールド | 必須 | 内容 |
|------------|------|------|
| `findings` | yes | 関連ファイル・関数の事実収集（判断は含めない） |
| `risks` | no | 想定される潜在リスク |
| `constraints` | no | 実装時に守るべき制約 |
| `next_action` | no | 次に呼ぶべきサブエージェント / コマンド |
| `status` | yes | `ok` / `needs_input`（追加情報待ち）/ `failed` |

---

## ReviewResult — /review の出力

```yaml
schema: ReviewResult/1.0
verdict: lgtm | needs_fix | blocker
issues:
  - severity: blocker | warning | suggestion
    location: "src/xxx.py:42"          # 省略可
    description: "問題の説明"
    suggestion: "修正案"
recommendations:
  - "改善提案"
status: ok | failed
error: null | "エラー内容"
```

### verdict の意味

| verdict | 意味 | 次のアクション |
|---------|------|---------------|
| `lgtm` | 問題なし | `/save` またはプラン承認へ進む |
| `needs_fix` | 修正が必要 | issues を修正して再レビュー |
| `blocker` | 重大な問題 | 実装を止めてユーザーに相談 |

---

## PlanArtifact — /design の最終出力

`tasks/current.md`（または `workflow.yaml` の `paths.tasks`）に書く形式:

```markdown
## 実装プラン: <タスク名>

### 変更ファイル
- `src/xxx.py` — <変更内容>

### 実装ステップ
1. ...
2. ...

### 受け入れ基準
- [ ] ...

### リスク・注意点
- ...
```

---

## 設計原則

- **調査と判断を分離**: 調査は事実収集。判断はメインエージェントが行う
- **構造化出力優先**: 自然文ではなく YAML/Markdown で返す
- **Git 操作はメインのみ**: サブエージェントは commit / push しない
- **成果物の型は AI 有無に依存しない**: Codex があってもなくても同じスキーマで出力する
