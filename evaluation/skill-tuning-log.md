# Skill Tuning Log（テンプレート）

> `evaluation/skill-quality-rubric.md` の採点 + `skills/empirical-prompt-tuning/SKILL.md` の反復記録を残す台帳。
> 1 skill / command につき 1 セクション。Iter 0（静的）→ Iter N（dispatch ベース）の順に下に積む。

---

## 使い方

1. 採点対象の skill / command ごとにセクションを増やす（コピー元: 下の「テンプレートセクション」）
2. **Iter 0** は frontmatter description vs body の整合チェックのみ（dispatch 不要、静的）
3. **Iter 1+** は `empirical-prompt-tuning` skill を呼び、新規 subagent でシナリオ実行 → 採点
4. 各イテレーションで以下を記録:
   - 軸ごとの点（5 段階 × 重み = 加算）
   - 自動失格判定（該当があれば Fail で打ち切り、改善後再採点）
   - 合計点 + 帯（Pass / Conditional Pass / Fail）
   - 不明瞭点・裁量補完（次イテレーション改善の材料）
5. 連続 2 イテレーションで Pass + 不明瞭点ゼロ + 主要メトリクス変動が閾値以下 → 収束、リリース対象に登録

---

## テンプレートセクション（コピーして使う）

```
### {{skill or command name}}

| Iter | 日付 | Trigger 15 | 自己完結 20 | 明瞭性 15 | Subagent 15 | Exit 15 | Golden 10 | Comm 10 | 合計 | 帯 | 自動失格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0  | YYYY-MM-DD | x/15 | x/20 | x/15 | x/15 | x/15 | x/10 | x/10 | xx | Pass/CP/Fail | none / item N |

#### Iter 0 メモ
- description vs body 整合: OK / NG（NG 内容）
- 自動失格スキャン: 該当なし / 該当あり（項目）

#### Iter N（dispatch ベースで追加）
- 実行 subagent: <id or short label>
- シナリオ: <scenario name>
- 不明瞭点（新出）:
  - <point 1>
- 裁量補完（新出）:
  - <補完内容>
- 修正方針: <next minimum diff>

#### 収束判定
- 連続 X 回 Pass、不明瞭点ゼロ X 回 / 上限 4 イテレーション
- 状態: 収束 / 継続 / 打ち切り
```

---

## 既存採点履歴

### plan-researcher

| Iter | 日付 | Trigger 15 | 自己完結 20 | 明瞭性 15 | Subagent 15 | Exit 15 | Golden 10 | Comm 10 | 合計 | 帯 | 自動失格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 2026-04-26 | 14/15 | 20/20 | 12/15 | 15/15 | 13/15 | 7/10 | 9/10 | 90 | Pass | none |

#### Iter 0 メモ
- description vs body 整合: OK
- 自動失格スキャン: 該当なし
- 主な減点: 「不明なら自分で Glob/Grep で特定」の手順が抽象的 (明瞭性 -3) / 構造例のみで具体的な「タスク → ResearchResult」ペアなし (Golden -3)

---

### codex-analyst

| Iter | 日付 | Trigger 15 | 自己完結 20 | 明瞭性 15 | Subagent 15 | Exit 15 | Golden 10 | Comm 10 | 合計 | 帯 | 自動失格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 2026-04-26 | 14/15 | 20/20 | 13/15 | 15/15 | 14/15 | 8/10 | 9/10 | 93 | Pass | none |

#### Iter 0 メモ
- description vs body 整合: OK
- 自動失格スキャン: 該当なし
- 主な減点: ReviewResult 構造例 + 3 つの bash 呼出例ありだが、具体的な「diff → ReviewResult」サンプルなし (Golden -2)
- 補足: 「[プロジェクトの 1-2 文サマリ]」placeholder 化済で self-contained

---

### agent-dispatch

| Iter | 日付 | Trigger 15 | 自己完結 20 | 明瞭性 15 | Subagent 15 | Exit 15 | Golden 10 | Comm 10 | 合計 | 帯 | 自動失格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 2026-04-26 | 14/15 | 20/20 | 12/15 | 15/15 | 10/15 | 8/10 | 9/10 | 88 | Pass | none |

#### Iter 0 メモ
- description vs body 整合: OK
- 自動失格スキャン: 該当なし（loop ではないため Exit 未定義は失格対象外）
- 主な減点: 方針 skill のため Exit / 収束条件が薄い (Exit -5)

---

### ux-comm

| Iter | 日付 | Trigger 15 | 自己完結 20 | 明瞭性 15 | Subagent 15 | Exit 15 | Golden 10 | Comm 10 | 合計 | 帯 | 自動失格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 2026-04-26 | 14/15 | 20/20 | 14/15 | 15/15 | 10/15 | 9/10 | 10/10 | 92 | Pass | none |

#### Iter 0 メモ
- description vs body 整合: OK
- 自動失格スキャン: 該当なし
- 主な減点: 方針 skill のため Exit (-5) / Subagent 軸は「該当外として満点扱い」
- 補足: ux-comm 自身の規約（反映タイミング・略称展開・コピペ可能手順）に準拠

---

### empirical-prompt-tuning

| Iter | 日付 | Trigger 15 | 自己完結 20 | 明瞭性 15 | Subagent 15 | Exit 15 | Golden 10 | Comm 10 | 合計 | 帯 | 自動失格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 2026-04-26 | 15/15 | 20/20 | 15/15 | 15/15 | 15/15 | 8/10 | 10/10 | 98 | Pass | none |

#### Iter 0 メモ
- description vs body 整合: 完全一致
- 自動失格スキャン: 該当なし
- 主な減点: 提示フォーマット例はあるが、完全な「Iter 1 → Iter 2」の連続サンプルはなし (Golden -2)
- 補足: 収束基準が定量化（連続 2 回 / +3pt 以下 / ±10% / ±15%）で他 skill のリファレンス役

---

## サマリ（2026-04-26 Iter 0 一括採点）

- 全 5 件 Pass（88–98 点）
- INANNA 固有パスへの残存参照: 0 件
- 自動失格 6 項目: 全項目クリア
- 共通の弱点: Golden example の具体的な「input → output」ペア不足（次回反復で改善余地）
