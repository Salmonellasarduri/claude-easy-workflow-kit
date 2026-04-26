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

（empirical-prompt-tuning の実行ごとに、上のテンプレートをコピーして下に積む）

<!-- 例:

### plan-researcher

| Iter | 日付 | Trigger 15 | 自己完結 20 | 明瞭性 15 | Subagent 15 | Exit 15 | Golden 10 | Comm 10 | 合計 | 帯 | 自動失格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0  | 2026-04-26 | 13/15 | 20/20 | 12/15 | 15/15 | 11/15 | 7/10 | 8/10 | 86 | Pass | none |

#### Iter 0 メモ
- description vs body 整合: OK
- 自動失格スキャン: 該当なし
- Exit 条件: 「ResearchResult/1.0 を返したら終了」と明示済 (-)
- Golden: 構造例のみ、具体的な調査結果サンプルは未掲載 (-)

-->
