# Skill Quality Rubric

> CEWK の skill / slash command を pre-release で採点するためのルーブリック。
> 構造テンプレートは `manual-bb-test-harness/docs/evaluation-rubric.md` を参考にしている（5-band + weighted + auto-fail）。
> 内容は CEWK 固有の「skill / command として実行者がそのまま使えるか」を測る軸に置き換えてある。

---

## 採点バンド（5 段階）

| 点 | 判定 | 定義 |
|---|------|------|
| **5** | Release-ready | 白紙の subagent が一発で実行できる。曖昧さ・未定義が 0 件 |
| **4** | Minor polish | 軽微な補足で使える。主要観点と exit 判断は妥当 |
| **3** | Needs revision | 骨格はあるが、empirical-prompt-tuning で 2 イテレーション以上の改善が必要 |
| **2** | Risky | 重要観点（trigger / exit / 出力 schema）が抜け、誤動作の危険あり |
| **1** | Not viable | 説明が概念レベルに留まり、実行者が動けない |

---

## 重み付け採点軸

| 軸 | 重み | 何を測るか | 失格条件 |
|---|---|---|---|
| **Trigger 適合性** | 15% | frontmatter `description` が body の能力と一致しているか（Iter 0 静的チェック） | description と body が乖離 |
| **自己完結性** | 20% | バンドル外（INANNA `.claude/` 配下、`memory/`, `tasks/`, `personality/`, `src/core/` 等）への参照がないか | 1 件でも外部参照が残る |
| **明瞭性 / 非曖昧性** | 15% | 実行者の裁量補完を最小化する具体性。動作・順序・閾値が数値・条件で書かれているか | 「適宜」「必要に応じて」のみで判断を委ねている |
| **Subagent schema 準拠** | 15% | subagent dispatch を行う skill の場合、`rules/subagent-schema.md` の 4 項目 schema を末尾に添付しているか | 該当する skill で schema 強制が抜けている |
| **Exit / 収束条件** | 15% | 「いつ止めるか」が定量化されている（連続 N 回 PASS / Δ < x% / 上限 N 回 / etc.） | 終了条件が「十分になったら」レベル |
| **Golden example** | 10% | 実行例（input → output の対応 1 件以上）が含まれているか | 例が 0 件、または抽象的な擬似コードのみ |
| **コミュニケーション** | 10% | 非技術者オーナーへ伝達する skill の場合、`ux-comm` の 3 規則に準拠しているか / 開発者向け skill では用語が統一されているか | 用語ゆれ・反映タイミング非明示 |

合計 100 点満点。

---

## Pass 閾値

| 帯 | 点数 | アクション |
|---|---|---|
| **Pass** | ≥ 80 | リリース対象に含める |
| **Conditional Pass** | 70–79 | empirical-prompt-tuning で 1 ラウンド回し、80 点到達を確認してからリリース |
| **Fail** | ≤ 69 | リリース見送り or 大幅改訂が必要 |

---

## 自動失格条件（6 件）

以下のいずれかに該当した時点で **総合 Fail**。点数計算より優先する。

1. **INANNA 固有パスへの参照が残存**（`memory/project_*.md`, `tasks/current.md`, `personality/`, `src/core/`, `.claude/skills/references/schemas.md` 等） — CEWK は self-contained kit である前提に違反
2. **frontmatter `description` と body の能力に乖離**（Iter 0 静的チェック失敗） — そもそも適切な発火条件で呼ばれない
3. **Exit / 収束条件が未定義**（無限ループ可能性） — 「使い終わるタイミング」が分からない skill は本番で必ず詰まる
4. **Subagent dispatch を伴うのに schema 強制がない** — 4 項目 schema を末尾に添付するルールが抜けると、メイン context への生出力流入が起きる
5. **不可逆操作（git push / API 呼出 / ファイル削除）にドライランや確認 gate がない** — `coding-core.md` の安全基準違反
6. **Golden example または擬似ペアが 0 件** — 抽象論のみの skill は実行者が解釈分岐で必ず詰まる

---

## 採点手順

各 skill / command につき以下を実施:

1. **Iter 0 静的チェック**（dispatch 不要） — frontmatter description vs body の整合
2. **自動失格 6 項目をスキャン** — 1 件でも該当すれば即 Fail として記録、点数計算は省略可
3. **7 軸の点数付け**（5 段階 × 重み） — 軸ごとに `evaluation/skill-tuning-log.md` の Iter 0 行に根拠を 1 行記載
4. **合計算出 → 閾値判定**
5. **Conditional Pass の場合のみ** `empirical-prompt-tuning` skill を呼び出して反復改善

---

## 採点の注意

- 採点は skill / command 文書の**実際の文面**に基づく（書き手の意図ではなく、実行者が読み取れる範囲）
- 判断に迷った場合は低い側に倒す（保守的に採点）
- 自動失格は「総合判定」を Fail にするが、採点ログは残す（次回改善の材料にする）
- 同じ skill を異なる時点で複数回採点してよい（empirical-prompt-tuning の反復で点数が上がっていく前提）

---

## 参考

- 構造テンプレートの出典: `https://github.com/RNA4219/manual-bb-test-harness/blob/main/docs/evaluation-rubric.md`
  （5-band + weighted + auto-fail のフレーム枠のみを参考にし、評価対象のドメイン・カテゴリ・失格条件は CEWK 固有に置き換えている）
- 反復改善の手法: `skills/empirical-prompt-tuning/SKILL.md`
- Subagent 出力 schema: `rules/subagent-schema.md`
- コーディング・安全基準: `rules/coding-core.md`
- スコープ逸脱検知: `rules/scope-guard.md`
