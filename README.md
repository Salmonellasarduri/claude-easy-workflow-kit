# claude-easy-workflow-kit

Claude Code で `/strategy` と打つだけで、開発が動き出すワークフローキットです。

あとは Claude が計画・実装・テスト・レビュー・保存まで自動で進めてくれるので、
**あなたがやるのは「選ぶ」と「はい/いいえ」だけ**です。

ある程度の自己デバッグをするので、小規模プロジェクトなら、プログラミングの知識がなくても使えます。

---

## 使い方

Claude Code で `/strategy` と打ちます。やりたいことがあれば一言添えるだけ。

```text
ログイン機能を追加したい /strategy
```

あとはこんな会話になります。

```
Claude: 「A, B, C の3案があります。どれにしますか？」
あなた: 「B」
Claude: （計画を作って提示）「この内容で進めていいですか？」
あなた: 「はい」
Claude: （実装 → テスト → レビューを自動で回す）
Claude: 「レビュー通りました。コミットしていいですか？」
あなた: 「はい」
Claude: （コミット・push・記録まで完了）
```

**あなたが打つコマンドは `/strategy` だけ**。
そこから先は Claude が自動で進めます。あなたは選択肢を選ぶか、はい/いいえを答えるだけです。

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

`.claude/` フォルダに以下を配置しても使えます。

```text
commands/*.md  → .claude/commands/
rules/*.md     → .claude/rules/
schemas/       → .claude/schemas/
workflow.yaml  → .claude/workflow.yaml
```

---

## 裏で何が起きているか

知りたい人向けの説明です。普段は意識しなくて大丈夫です。

`/strategy` を起点に、Claude が以下の流れを **自動でつないで** 進めています。

```text
/strategy → /plan → /implement → /debug → /review → /save
```

あなたに聞かれるのは、こういう場面だけです。

| 場面 | 聞かれること |
|------|------------|
| 方針が決まったとき | 「A, B, C どれにしますか？」 |
| 計画ができたとき | 「この計画で進めていいですか？」 |
| レビューで問題があったとき | 「この指摘を修正しますか？」 |
| 保存するとき | 「コミットしていいですか？」 |

それ以外（実装、テスト、レビュー、ドキュメント更新）は Claude が自動で進めます。

---

## 7つのコマンド詳細

普段はこれらを意識する必要はありません。Claude が自動で呼び出すので、知らなくても使えます。

### `/strategy`
**唯一あなたが打つコマンド**。何をどう進めるかを整理する入口です。
Claude がコードベースや状況を見て、進め方の候補を出します。

### `/plan`
実装に入る前の作業計画を作るステップ。Claude が自動で呼び出します。

### `/implement`
計画に沿ってコードを書くステップ。Claude が自動で呼び出します。

### `/debug`
動作確認や不具合の切り分け。問題がなくなるまで自動でループします。

### `/review`
コードレビュー。Claude が自分で見直し、Codex CLI があればそちらにも投げます。

### `/save`
コミット・push・記録をまとめるステップ。「コミットしていいですか？」と確認してから実行します。

### `/restart`
中断した作業を再開するコマンドです。
セッションが途切れたときに打つと、どこまで進んでいたかを検出して続きから再開します。
`/strategy` と並んで、あなたが直接打つことがあるコマンドです。

---

## 導入後に作られるもの

セットアップすると、以下のファイル群が用意されます。
既にあるファイルは上書きせず、足りないものだけ作ります。

| ファイル | 用途 |
|---------|------|
| `tasks/current.md` | 今やっている作業の整理 |
| `tasks/lessons.md` | 次回以降に活かす反省・学びの記録 |
| `docs/ROADMAP.md` | 全体の進み具合や今後の見通し |
| `docs/DEVLOG.md` | 開発ログの入口 |
| `docs/devlog/` | セッションごとの詳細ログ |

---

## `workflow.yaml` について

導入すると `.claude/workflow.yaml` が置かれます。
**最初は触らなくて大丈夫です。**

デフォルトのまま動くようになっていて、既存プロジェクトの構成に合わせたいときだけ調整してください。

```yaml
paths:
  tasks: my-project/tasks.md
  roadmap: CHANGELOG.md
```

---

## 外部ツール連携

このキットは**単体で動きます**。以下はあると便利なオプションです。

| ツール | できること | 必須？ |
|--------|------------|--------|
| [Codex CLI](https://github.com/openai/codex) | レビューや計画確認の補助 | いいえ |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 広めの調査や情報整理の補助 | いいえ |
| [GitHub CLI](https://cli.github.com/) | Issue や Milestone 操作の補助 | いいえ |

まずは Claude Code だけで始めて、必要になったら足してください。

---

## このキットの考え方

Claude Code は強力ですが、自由度が高いぶん、毎回やり方がぶれたり、
実装の後のテストやレビューが抜けやすくなったりします。

このキットは、それを防ぐために作られています。
目指しているのは、AI に全部丸投げすることではなく、
**人は判断に集中し、手順は選ぶだけにする**ことです。

ベースになっているのは、
[Artificial Personality](https://github.com/Salmonellasarduri/Artificial-Personality) での 70 回以上の開発セッションです。
実際に回して分かった「詰まりやすい点」を、誰でも使える形にまとめています。

---

## License

MIT
