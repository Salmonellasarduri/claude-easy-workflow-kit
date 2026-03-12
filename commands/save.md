# /save — コミット・push・ドキュメント更新

## 目的

セッションの変更をドキュメントに記録し、リポジトリを最新状態に保つ。

## 原則

- **変更したセクションだけを更新する。触っていない部分は変えない。**
- **`/review` が LGTM になっていない状態で `/save` を実行しない。**

---

## 実行手順

### 0. 前提確認

```bash
git status
git diff --stat
```

ファイル変更がない場合はスキップ。`/review` 未実施なら先に実行する。

### 1. ドキュメント更新

`rules/doc-update-guide.md` のチェックリストに従ってドキュメントを更新する。

**大規模な変更**: general-purpose サブエージェントに委譲
（`rules/doc-update-guide.md` の委譲テンプレート参照）

**小規模な変更**: 直接更新
- タスクファイルの完了タスクに `[x]` を付ける
- 開発ログに1行サマリーを追加する

### 2. 特定ファイルのみステージング

```bash
# git add . は使わない — 変更したファイルだけを明示的に指定
git add src/xxx.py tasks/current.md docs/DEVLOG.md
```

### 3. コミット

`workflow.yaml` の `git.commit_style` に従う。

**conventional（デフォルト）**:
```bash
git commit -m "$(cat <<'EOF'
feat(scope): 変更内容の要約

なぜこの変更が必要だったか

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

| プレフィックス | 用途 |
|---|---|
| `feat:` | 新機能 |
| `fix:` | バグ修正 |
| `docs:` | ドキュメントのみ |
| `refactor:` | 振る舞い変更なしのリファクタ |
| `chore:` | 設定・ツール類 |

**freeform**: 自由形式（プレフィックス不要）

### 4. push & サマリ表示

```bash
git push
```

push 完了後にサマリを表示する:

```
## /save 完了

- コミット: [git log -1 --oneline]
- 変更ファイル: [git diff --stat HEAD~1]
- 次のアクション: [次フェーズ提案 / なし]
```

### 5. GitHub 連携（オプショナル）

`workflow.yaml` の `tools.gh: true` の場合のみ実行:

```bash
# 完了フェーズがあれば Issue/Milestone をクローズ
gh issue close <number>
gh milestone close <number>
```

---

## 注意

- `git add .` や `git add -A` は使わない（意図しないファイルの混入を防ぐ）
- `.env`, credentials, 大きなバイナリは staging しない
- push 後に「次は〜しますか？」を提案してよい（push 前は禁止）
