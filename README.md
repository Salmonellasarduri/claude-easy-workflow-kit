# claude-easy-workflow-kit

Claude Code での開発を、会話ベースで進めやすくするキットです。

タスク整理、実装、テスト、レビュー、コミットまで、
難しい設定なしで順番に進められます。

プログラミングに詳しくなくても大丈夫。
コマンドを打って、出てきた選択肢を選ぶだけで使えます。

---

## こんな人に向いています

- Claude Code を使っている（使い始めたばかりでもOK）
- 「何から手をつけていいかわからない」ことがある
- 実装は進むけど、レビューや記録が抜けがち
- 個人開発や少人数で、進め方をそろえたい

逆に、Claude Code を使わないプロジェクトには向いていません。

---

## まずはこれだけ

導入したら、Claude Code で次を入力してください。

```
/strategy
```

何をすればいいか分からない状態でも、プロジェクトを読み取って次の一歩を提案してくれます。

やりたいことがあるなら、一言添えるだけ。

```
認証機能を追加したい /strategy
```

あとは **選択肢を選ぶか、yes/no を答えるだけ**。
数往復の会話で計画 → 実装 → テスト → レビュー → コミットまで全部終わります。

レビューも Claude が自分でやるし、Codex CLI があればそっちにも投げてくれます。
あなたがやるのは「方向性を選ぶ」と「結果を確認する」だけです。

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

自分で `.claude/` フォルダにコピーしても使えます。

```text
commands/*.md  → .claude/commands/
rules/*.md     → .claude/rules/
schemas/       → .claude/schemas/
workflow.yaml  → .claude/workflow.yaml
```

---

## できること

このキットは、開発の流れをコマンドで順番に進められるようにします。

```text
戦略を考える → 計画する → 実装する → 確認する → レビューする → 保存する
```

| コマンド | 役割 |
|---------|------|
| `/strategy` | 進め方の候補を整理する |
| `/plan` | 実装計画を作る |
| `/implement` | 実装を進める |
| `/debug` | 動作確認やテストをする |
| `/review` | コードレビューをする |
| `/save` | コミットや記録をまとめる |
| `/restart` | 中断した作業を再開しやすくする |

便利コマンド集ではなく、**開発の流れ全体を回しやすくする**のがポイントです。

---

## 標準の流れ

まずはこの順番で1回使ってみるのがおすすめです。

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

変更が小さくて、やることが明確なら、この短縮版で十分です。

---

## 導入後に作られるもの

導入すると、必要なファイルを自動で用意します。
すでにあるファイルは上書きせず、ないものだけ作ります。

| ファイル | 用途 |
|---------|------|
| `tasks/current.md` | 今の作業内容をまとめる |
| `tasks/lessons.md` | あとで繰り返さないためのメモを残す |
| `docs/ROADMAP.md` | 全体の進み具合を見る |
| `docs/DEVLOG.md` | 開発ログの入り口 |
| `docs/devlog/` | セッションごとの詳細ログ |

---

## 設定（触らなくてもOK）

導入後に `.claude/workflow.yaml` が置かれます。
**基本的にはそのまま使えます**。

既存プロジェクトでファイルの場所が違う場合だけ、合わせて変更してください。

```yaml
paths:
  tasks: my-project/tasks.md     # デフォルト: tasks/current.md
  roadmap: CHANGELOG.md          # デフォルト: docs/ROADMAP.md
```

---

## 外部ツール連携（なくてもOK）

このキットは、外部ツールがなくても動きます。
入っていれば、レビューや調査をさらに強化できます。

| ツール | できること | 必須？ |
|--------|------------|--------|
| [Codex CLI](https://github.com/openai/codex) | レビューやプラン確認の補助 | いいえ |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 広めのコード調査や情報整理の補助 | いいえ |
| [GitHub CLI](https://cli.github.com/) | Issue や Milestone の操作補助 | いいえ |

使いたい場合は `.claude/workflow.yaml` で有効にできます。

```yaml
tools:
  codex: true
  gemini: true
  gh: true
```

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
