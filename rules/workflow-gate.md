# ワークフローゲートルール

このプロジェクトでは、品質を保つためにコマンド間のゲート（通過条件）を設けている。

---

## Full Workflow（標準フロー）

```
/strategy → /plan → /implement → /debug → /review → /save
```

| ゲート | 条件 |
|--------|------|
| `/strategy` → `/plan` | **ユーザーが方向性を選択するまで進まない**。選択を推測・捏造しない |
| `/plan` → `/implement` | **ユーザーがプランを承認するまで実装しない** |
| `/implement` → `/save` | `/debug` で受け入れ基準を証明し、`/review` を通過してから `/save` |
| `/review` → `/save` | verdict が `lgtm` でなければ `/save` に進まない |
| `/save` 完了後 | push 後にサマリを表示。次フェーズはユーザーが明示的に指示するまで待つ |

---

## Fast Path（小修正・緊急修正用）

`workflow.yaml` の `workflow.fast_path_allowed: true` のとき、以下の条件を**すべて満たす**場合に限り `/strategy` と `/plan` をスキップできる:

1. 変更が **3ファイル以下** に収まる
2. 設計判断が不要（既存パターンの適用・バグ修正・typo 修正など）
3. ユーザーが具体的な修正内容を指示している

Fast Path でも `/debug` → `/review` → `/save` のゲートは**省略不可**。

```
Fast Path: /implement → /debug → /review → /save
```

---

## 絶対ルール

- **ユーザーの決定を捏造しない** — `/strategy` の結果を推測して `/plan` に進まない
- **レビューなしで保存しない** — `/review` を飛ばして `/save` しない
- **push まで完走してフェーズ完了** — コードが動いても push されるまでは「完了」ではない
- **次フェーズの提案は push 後** — 「次は〜しますか？」は push 完了後に初めて言う
