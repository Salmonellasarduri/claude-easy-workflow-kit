# Claude Easy Workflow Kit

**vibe coding を「流れで書く」だけで終わらせず、破綻しにくい開発フローにするための Claude Code 用ワークフローキットです。**

`/strategy` と打つと、Claude が現在の状況を読み、進め方を 3 案に整理します。あなたは方針を選び、計画を承認するだけ。その後は Claude が実装、検証、レビュー、保存までをチェックポイント付きで進めます。

大きな判断には `/strategy_deep` を使います。これは単なる深掘りではなく、技術・プロダクト・コンセプトずれの観点から戦略を何ラウンドも叩き直すためのコマンドです。

このキットは、自律型 Discord 人格エージェント **Artificial Personality** の開発で育ちました。規模は **19 万行 / 1,167 ファイル / 900+ コミット**、Claude Code での実開発セッションは **1,600 回以上**です。目的ははっきりしています。大きくなった vibe-coded codebase が、ファイル間のつながりを壊したり、元のコンセプトから静かにずれたりするのを防ぐことです。

---

## 何をしてくれるのか

AI コーディングでよく崩れるのは、だいたい同じ場所です。

- 方針を決める前に実装を始める
- 計画が曖昧なまま進む
- テストや動作確認が抜ける
- レビューが抜ける
- コミットに関係ない変更が混ざる
- プロジェクトが少しずつ本来のコンセプトからずれる

Claude Easy Workflow Kit は、それを次の流れに固定します。

```text
/strategy
  → A / B / C から方針を選ぶ
  → 実装計画を承認する
  → Claude が実装する
  → 受け入れ基準を検証する
  → レビューする
  → 保存を承認する
  → commit / push / devlog 更新
```

人間は判断に集中します。手順は Claude に持たせます。

---

## `/strategy_deep` が重要な理由

`/strategy` は日常の作業用です。

`/strategy_deep` は、普通に進めるとあとで構造的に苦しくなりそうな判断に使います。

- アーキテクチャ変更
- 大きめのリファクタ
- 機能の方向転換
- プロダクト価値の整理
- 「今は良さそうだが、全体構造を壊すかもしれない」判断

流れはこうです。

```text
テーマを決める
  → Claude が戦略案を作る
  → 技術批評役が実装・設計上の穴を見る
  → プロダクト批評役が UX・価値・コンセプトずれを見る
  → Claude が戦略を作り直す
  → 必要なら繰り返す
```

たとえばこう使います。

```text
/strategy_deep "記憶システムを複数サービスに分けるべきか、モノリスのまま保つべきか？"
```

出てくるのは単なる「答え」ではありません。

- 各視点が見つけた問題
- critical / major / minor のリスク数
- ラウンドごとに何が改善されたか
- 最終的な 3 案
- 推奨案と残るリスク

19 万行規模のコードを vibe し続けるとき、ここがかなり効きます。コード間のつながり、設計上の破綻、コンセプトからのずれを、実装前に見つけにいくための仕組みです。

---

## Quick Start

### macOS / Linux / WSL

```bash
git clone https://github.com/Salmonellasarduri/claude-easy-workflow-kit.git
cd claude-easy-workflow-kit
./scaffold.sh /path/to/your/project
```

### Windows PowerShell

```powershell
git clone https://github.com/Salmonellasarduri/claude-easy-workflow-kit.git
cd claude-easy-workflow-kit
.\scaffold.ps1 -ProjectPath C:\path\to\your\project
```

その後、対象プロジェクトを Claude Code で開きます。

```text
/strategy
```

---

## 導入後の確認

scaffold 後、対象プロジェクトには次の構成が入っているはずです。

```text
.claude/
  commands/
  skills/
  rules/
  schemas/
  workflow.yaml

tasks/
  current.md
  lessons.md
  strategy_context.md

docs/
  ROADMAP.md
  DEVLOG.md
  devlog/
```

`.claude/skills/` がない場合、コマンドは見えても skill 前提の動きが弱くなります。

---

## 30 秒の使用例

```text
あなた:
ログイン機能を追加したい /strategy

Claude:
3 つの方向性があります。

A: 最小構成のメール/パスワードログイン
B: OAuth 前提のログイン
C: 招待コード式の一時ログイン

おすすめは B です。理由は...

あなた:
B

Claude:
実装計画を作りました。
変更ファイル、テスト方法、受け入れ基準は以下です。
この内容で進めていいですか？

あなた:
はい

Claude:
実装 → デバッグ → レビュー

Claude:
レビューが通りました。保存しますか？

あなた:
はい

Claude:
commit、push、devlog 更新まで完了します。
```

---

## 通常フロー

```text
/strategy → /design → /implement → /debugging → /reviewing → /save
```

| ステップ | 何が起きるか | 人間の判断 |
|---|---|---|
| `/strategy` | 現状を読み、3 つの方向性を出す | A / B / C を選ぶ |
| `/design` | 実装計画と受け入れ基準を作る | 計画を承認する |
| `/implement` | 承認済みの計画に沿ってコードを書く | 基本なし |
| `/debugging` | テストやスクリプトで受け入れ基準を証明する | 詰まったときだけ |
| `/reviewing` | 保存前に差分をレビューする | 必要なら修正 |
| `/save` | ドキュメント更新、commit、push | VCS 操作前に承認 |

`/save` は commit / push を含むため、常に明示的な承認が必要です。

---

## 小さな修正の Fast Path

小さくて具体的な変更なら、`/strategy` と `/design` を省略できます。

Fast Path は次の条件をすべて満たす場合だけです。

1. 変更が **3 ファイル以下**
2. 設計判断が不要
3. ユーザーが具体的な修正内容を指示している

```text
/implement → /debugging → /reviewing → /save
```

Fast Path でも、`/debugging` と `/reviewing` は省略しません。

---

## コマンド一覧

普段は `/strategy` だけで十分です。

| コマンド | 使う場面 | 出力 |
|---|---|---|
| `/strategy` | 次に何をするか Claude と決めたい | 3 案 + 推奨 |
| `/strategy_deep` | 重要な設計判断・方向性判断をしたい | 複数視点の批評 + 最終 3 案 |
| `/design` | 方向性は決まっていて、実装計画がほしい | 実装計画 + 受け入れ基準 |
| `/implement` | 承認済みの計画を実装したい | コード変更 + 検証ループ |
| `/debugging` | 動作証明や原因切り分けをしたい | テスト / 証明ループ |
| `/reviewing` | 保存前にレビューしたい | `lgtm` / `needs_fix` / `blocker` |
| `/save` | レビュー済みの作業を保存したい | commit / push / devlog 更新 |
| `/restart` | セッションが途切れた | 中断地点から復旧 |

---

## 同梱 skill

このキットには、ワークフローを支える skill が入っています。

| Skill | 用途 |
|---|---|
| `plan-researcher` | 実装前に関連ファイル、依存関係、リスク、制約を調べる |
| `codex-analyst` | Codex CLI がある場合、コードや計画を外部レビューする |
| `agent-dispatch` | Claude / Codex / Gemini / subagent の役割分担を決める |
| `ux-comm` | 反映タイミング、平易な説明、コピペ可能な手順を守る |
| `empirical-prompt-tuning` | skill / slash command を白紙 agent で検証して改善する |

外部ツールがなくても Claude 単体でフォールバックできます。ただし、これらの skill はこのキットの想定動作の一部です。

---

## 外部ツール連携

Claude Code だけでも動きます。

外部ツールを足すと、レビューや大規模調査が強くなります。

| ツール | できること | 必須？ |
|---|---|---|
| Codex CLI | コード・計画の外部レビュー | いいえ |
| Gemini CLI | 広い範囲の調査・分析 | いいえ |
| GitHub CLI | Issue / Milestone 操作 | いいえ |

`.claude/workflow.yaml` で有効化します。

```yaml
tools:
  codex: true
  gemini: true
  gh: true
```

使えない場合は Claude の自己分析にフォールバックします。

---

## 設定

デフォルトのまま使えます。

```yaml
paths:
  tasks: tasks/current.md
  lessons: tasks/lessons.md
  roadmap: docs/ROADMAP.md
  devlog_dir: docs/devlog/
  devlog_index: docs/DEVLOG.md

workflow:
  fast_path_allowed: true
  auto_continue: true

git:
  commit_style: conventional
  show_summary: true
```

パスを変えたいときや、自動続行を切りたいときだけ編集してください。

---

## 作成されるファイル

| ファイル | 用途 |
|---|---|
| `tasks/current.md` | 現在のタスクと実装計画 |
| `tasks/lessons.md` | 繰り返したくないミスや学び |
| `tasks/strategy_context.md` | `/strategy_deep` の結果。`/design` が読む |
| `docs/ROADMAP.md` | 全体進捗 |
| `docs/DEVLOG.md` | 開発ログの索引 |
| `docs/devlog/` | セッションごとの詳細ログ |

既存ファイルは、force 指定をしない限り上書きしません。

---

## 安全設計

このキットは「完全自律」を目指していません。

判断ゲートがあります。

- Claude は戦略方向を勝手に決めない
- 計画を承認するまで実装しない
- debug と review を通るまで保存しない
- commit / push 前には必ず確認する
- `git add .` で雑に全部入れない

重要: これはプロンプトエンジニアリングです。Claude の振る舞いを安定させるための手順書であり、機械的な保証ではありません。意味のある変更は必ず確認してください。

---

## トラブルシュート

### `/strategy` は動くが、後続ステップが見つからない

導入されているか確認します。

```bash
ls .claude/commands
ls .claude/skills
```

### Claude が review を飛ばしているように見える

手動で実行します。

```text
/reviewing
```

`verdict: lgtm` になってから保存してください。

### セッションが中断された

```text
/restart
```

git status、タスク状態、`/strategy_deep` の中断状態を見て復旧します。

### 外部ツールが失敗する

`.claude/workflow.yaml` で無効化します。

```yaml
tools:
  codex: false
  gemini: false
  gh: false
```

Claude 単体のフォールバックで動きます。

---

## 向いている人

向いています。

- vibe coding はしたいが、破綻は減らしたい
- プロジェクトが「1 ファイルと勢い」では済まなくなってきた
- AI に作業記録を残してほしい
- テストとレビューを毎回通したい
- コンセプト、実装、ロードマップのずれを抑えたい

向いていません。

- 一回限りのコード片だけ欲しい
- Claude Code を使っていない
- CI やビルドシステムの代替が欲しい
- AI にプロダクト判断まで全部任せたい

---

## Acknowledgments

- `empirical-prompt-tuning` は @mizchi 氏の `empirical-prompt-tuning` の日本語訳・派生版です。
- 評価ルーブリックの構造は `manual-bb-test-harness` の 5-band / weighted / auto-fail 形式を参考にし、CEWK 用に書き直しています。

詳細は `THIRD_PARTY_LICENSES.md` を参照してください。

---

## License

MIT — `LICENSE` を参照してください。

[English version](README.md)
