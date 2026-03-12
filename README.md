# claude-easy-workflow-kit

Claude Code に「開発の進め方」を教えるだけで、計画からコミットまで自動で回るようになるキットです。

難しい設定は不要。コマンドを打って、選択肢を選ぶだけ。
あとは Claude が計画・実装・テスト・レビュー・保存まで面倒を見てくれます。

---

## ひとことで言うと

Claude Code 用の「開発の進め方テンプレート」です。
便利コマンド集というより、考えるところから保存までを整えるためのキットです。

---

## 使い方はこれだけ

導入したら、Claude Code でこう打ってください。

```
/strategy
```

これだけで、プロジェクトの状態を読み取って「次にやるべきこと」を提案してくれます。

やりたいことが決まっているなら、一言添えるだけ。

```
認証機能を追加したい /strategy
```

あとは **選択肢を選ぶか、yes/no を答えるだけ**。
数往復の会話で計画 → 実装 → テスト → レビュー → コミットまで全部終わります。
プログラミングの知識は必要です。でも、進め方に悩む必要はなくなります。

---

## これでできること

このキットでは、次の流れをコマンドで回せます。

```text
戦略を考える → 計画する → 実装する → 確認する → レビューする → 保存する
```

用意しているコマンドは7つです。

| コマンド | 役割 |
|---------|------|
| `/strategy` | 進め方の候補を整理する |
| `/plan` | 実装計画を作る |
| `/implement` | 実装を進める |
| `/debug` | 動作確認やテストをする |
| `/review` | コードレビューをする |
| `/save` | コミットや記録をまとめる |
| `/restart` | 中断した作業を再開しやすくする |

ポイントは、1回きりの便利コマンド集ではなく、**開発の流れ全体を回しやすくする**ことです。

---

## こんな人に向いています

- Claude Code を普段から使っている
- 個人開発や少人数開発で、進め方をある程度そろえたい
- 「実装までは早いけど、レビューや記録が抜けがち」ということがある
- 新しいプロジェクトに最初から流れを入れたい
- 既存プロジェクトにも後付けで導入したい

逆に、Claude Code を使わないプロジェクトには向いていません。

---

## Quick Start

### Unix / macOS / WSL

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

### 手動で入れる場合

`scaffold` を使わず、自分で `.claude/` にコピーしても使えます。

```text
commands/*.md  → .claude/commands/
rules/*.md     → .claude/rules/
schemas/       → .claude/schemas/
workflow.yaml  → .claude/workflow.yaml
```

---

## 最初のおすすめの使い方

まずは標準の流れで1回使ってみるのがおすすめです。

```text
/strategy → /plan → /implement → /debug → /review → /save
```

### 標準フロー

1. `/strategy` で進め方を決める
2. `/plan` で作業内容を固める
3. `/implement` で実装する
4. `/debug` で動作確認する
5. `/review` で見直す
6. `/save` でコミットや記録を残す

### 小さな修正なら短縮版でもOK

```text
/implement → /debug → /review → /save
```

以下のようなケースなら、この短縮版で十分です。

- 変更が小さい
- 進め方に迷いがない
- やることが最初から明確

---

## 導入後に作られるもの

`scaffold` を使うと、必要なファイルを自動で用意します。
すでにあるファイルは上書きせず、ないものだけ作ります。

| ファイル | 用途 |
|---------|------|
| `tasks/current.md` | 今の作業内容をまとめる |
| `tasks/lessons.md` | あとで繰り返さないためのメモを残す |
| `docs/ROADMAP.md` | 全体の進み具合を見る |
| `docs/DEVLOG.md` | 開発ログの入り口 |
| `docs/devlog/` | セッションごとの詳細ログ |

---

## 設定

導入後は `.claude/workflow.yaml` が置かれます。
基本的にはそのまま使えます。必要なところだけ調整してください。

```yaml
paths:
  tasks: my-project/tasks.md     # デフォルト: tasks/current.md
  roadmap: CHANGELOG.md          # デフォルト: docs/ROADMAP.md

tools:
  codex: true    # Codex CLI を使う（デフォルト: false）
  gemini: true   # Gemini CLI を使う（デフォルト: false）
  gh: true       # GitHub CLI を使う（デフォルト: false）
```

たとえば、既存プロジェクトですでにタスク管理ファイルや変更履歴がある場合は、そのパスに合わせて変更できます。

---

## 外部ツール連携

このキットは、外部ツールがなくても動きます。
入っていれば、レビューや調査を少し強化できます。

| ツール | できること | 必須？ |
|--------|------------|--------|
| [Codex CLI](https://github.com/openai/codex) | レビューやプラン確認の補助 | いいえ |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 広めのコード調査や情報整理の補助 | いいえ |
| [GitHub CLI](https://cli.github.com/) | Issue や Milestone の操作補助 | いいえ |

---

## 既存プロジェクトに入れるとき

1. `scaffold.sh` または `scaffold.ps1` を実行する
2. `.claude/workflow.yaml` のパスを、今のプロジェクト構成に合わせる
3. 既存の `tasks/` や `docs/` を使いたい場合は、その場所を設定する
4. `CHANGELOG.md` を進行管理に使いたい場合は `paths.roadmap` を変更する

---

## このキットの考え方

Claude Code を使った開発で起きやすい、こんな悩みを減らすために作っています。

- 実装は進むけど、レビューが抜ける
- 作業を中断すると、再開しづらい
- 毎回やり方がぶれて、ログや記録が散らばる
- 小さな反省が次に活きにくい

そのために、
「考える」「作る」「確認する」「残す」を、無理なく回せる形にしています。

元になったのは [Artificial Personality](https://github.com/Salmonellasarduri/Artificial-Personality) プロジェクトでの70回以上の開発セッションです。

---

## License

MIT
