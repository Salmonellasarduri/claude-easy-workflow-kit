# スキル間ハンドオフ契約スキーマ v1.0

コマンド間のデータ受け渡し形式を定義する。
各コマンドはこのスキーマに従って出力し、受け取り側もこの形式を前提とする。

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

## PlanArtifact — /plan の最終出力

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
