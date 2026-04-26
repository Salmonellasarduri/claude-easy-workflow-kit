# ワークフローゲートルール

このプロジェクトでは、品質を保つためにコマンド間のゲート（通過条件）を設けている。

---

## Full Workflow（標準フロー）

```
/strategy → /design → /implement → /debugging → /reviewing → /save
```

| ゲート | 条件 |
|--------|------|
| `/strategy` → `/design` | **ユーザーが A/B/C を自分の言葉で選ぶまで進まない**。選択後、`auto_continue: true` なら `/design` に自動続行する |
| `/design` → `/implement` | **ユーザーがプランを承認するまで実装しない**。承認後、`auto_continue: true` なら `/implement` に自動続行する |
| `/implement` → `/save` | `/debugging` で受け入れ基準を証明し、`/reviewing` を通過してから完了サマリーを表示。**ユーザーが承認してから `/save`** |
| `/reviewing` → `/save` | verdict が `lgtm` でなければ `/save` に進まない |
| `/save` 完了後 | サマリを表示。次フェーズはユーザーが明示的に指示するまで待つ |

---

## Auto-Continue（自動続行）

`workflow.yaml` の `workflow.auto_continue: true`（デフォルト）の場合、ユーザーの決定後に次のコマンドへ自動で進む。

**自動続行するもの:**
- `/strategy` の選択 → `/design`（ユーザーが A/B/C を選んだ後）
- `/design` の承認 → `/implement`（ユーザーが「はい」と言った後）
- `/implement` → `/debugging` → `/reviewing`（すべて自動）

**自動続行しないもの（必ずユーザーの明示的な承認が必要）:**
- `/save`（コミット・push は VCS 操作のため）

**`auto_continue: false` の場合:**
- すべてのコマンド間でユーザーの明示的な呼び出しを待つ（従来の動作）

---

## Fast Path（小修正・緊急修正用）

`workflow.yaml` の `workflow.fast_path_allowed: true` のとき、以下の条件を**すべて満たす**場合に限り `/strategy` と `/design` をスキップできる:

1. 変更が **3ファイル以下** に収まる
2. 設計判断が不要（既存パターンの適用・バグ修正・typo 修正など）
3. ユーザーが具体的な修正内容を指示している

Fast Path でも `/debugging` → `/reviewing` → `/save` のゲートは**省略不可**。

```
Fast Path: /implement → /debugging → /reviewing → /save
```

---

## 絶対ルール

- **ユーザーの決定を捏造しない** — `/strategy` の結果を推測して `/design` に進まない
- **レビューなしで保存しない** — `/reviewing` を飛ばして `/save` しない
- **push まで完走してフェーズ完了** — コードが動いても push されるまでは「完了」ではない（git がない環境ではドキュメント更新で完了）
- **次フェーズの提案は完了後** — 「次は〜しますか？」は `/save` 完了後に初めて言う
- **自動続行はユーザーの明示的な決定の「後」にのみ発動する** — 決定を推測・捏造して先に進むことは絶対に禁止
