# /reviewing — コードレビュー

> 注: 旧名 `/review` は Claude Code 同梱 built-in command と衝突するため `/reviewing` にリネーム済み。

## 目的

コード変更またはプラン文面をレビューし、`ReviewResult/1.0`（`schemas/handoff.md` 参照）形式で品質を判定する。

## 前提条件

**コードレビュー（A）を実行する前に `/debugging` が完了していること。**
テストデータの残滓（`.bak` ファイル・`_test_` エントリ）がないことを確認する。

---

## 実行手順

### A: コードレビュー（実装後）

#### Preferred Path（Codex がある場合）

`.claude/skills/codex-analyst/SKILL.md` の呼び出しパターンに従う。
**前提読込（必須）**: レビュー開始前に `.claude/rules/scope-guard.md` を読み込み、共通原則・例外テンプレート・5 禁止項目を確認すること（観点 6 のスコープ外検知で使う）。

```bash
# 未追跡ファイルは安全のためソースコード拡張子に限定し、サイズ上限を設ける
# (秘密情報・バイナリ・大きいログ等が外部 CLI に流出するのを防ぐ)
MAX_BYTES=102400  # 100KB / file
ALLOWED_EXT='\.(py|js|jsx|ts|tsx|go|rs|java|rb|php|cs|swift|kt|scala|c|cc|cpp|h|hpp|sh|ps1|md|yaml|yml|json|toml|sql)$'

{
  cat <<'PROMPT'
以下の差分を ReviewResult/1.0 形式でレビューしてください（シェルコマンドは実行不要）。
観点:
1. バグ・論理エラー
2. セキュリティ問題（認証情報の扱い・入力バリデーション）
3. エラーハンドリング（特に不可逆な操作）
4. 設計・コーディング規約への準拠
5. より良い実装案
6. **スコープ外変更の検知**（`.claude/rules/scope-guard.md` 参照）— 以下 4 ステップで確認:
   1. 指示対象ファイル/シンボルを依頼文から列挙
   2. diff の変更ファイル一覧と照合
   3. rename / format-only / test expectation change / revert を個別確認
   4. 共通例外テンプレート 4 条件を満たさない逸脱があれば issue として明示報告

出力形式:
schema: ReviewResult/1.0
producer: codex-analyst
verdict: lgtm | needs_fix | blocker
issues: [...]
recommendations: [...]
status: ok

<<BEGIN_DIFF>>
PROMPT
  git diff HEAD
  echo ""
  echo "=== 未追跡の新規ファイル (許可拡張子のみ / ${MAX_BYTES}B 以下) ==="
  git ls-files --others --exclude-standard | grep -E "$ALLOWED_EXT" | while IFS= read -r f; do
    if [[ -f "$f" ]] && [[ $(wc -c < "$f") -le $MAX_BYTES ]]; then
      echo "--- $f ---"
      cat "$f"
    else
      echo "--- $f (skipped: too large or not a regular file) ---"
    fi
  done
  echo "<<END_DIFF>>"
} | codex exec -
```

#### Fallback Path（Codex なし）

自分自身でチェックリストを確認する:

- [ ] バグ・論理エラーがないか
- [ ] セキュリティ問題がないか（認証情報のハードコード、入力のサニタイズ漏れ）
- [ ] 不可逆操作にドライランが実装されているか
- [ ] エラーハンドリングが適切か
- [ ] コーディング規約に準拠しているか
- [ ] ログが適切に記録されているか

チェック結果を ReviewResult/1.0 形式で出力する（verdict を自分で判定）。

---

### B: プランレビュー（/design から呼ばれる場合）

#### Preferred Path

```bash
codex exec "以下の実装プランを ReviewResult/1.0 形式でレビューしてください。
問題点・代替案・リスクを指摘してください:

[プランの内容]"
```

#### Fallback Path

自己レビューチェックリスト:
- [ ] 変更ファイルが漏れなく列挙されているか
- [ ] 受け入れ基準が具体的で検証可能か
- [ ] リスクが洗い出されているか
- [ ] 実装ステップの順序が妥当か

---

## 結果の評価

| verdict | 次のアクション |
|---------|---------------|
| **lgtm** | コードレビューなら `/save` へ、プランレビューなら承認提示へ |
| **needs_fix** | 指摘を修正。ロジック修正なら `/debugging` 再実行後に再レビュー。スタイル修正ならそのまま再レビュー |
| **blocker** | 実装を止めてユーザーに相談 |
