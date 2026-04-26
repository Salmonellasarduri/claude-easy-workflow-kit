# コーディング規約 — Core

> プロジェクト横断の普遍規約。作業範囲ガードは `.claude/rules/scope-guard.md`、サブエージェント出力 schema は `.claude/rules/subagent-schema.md` を参照。

---

## エラーハンドリング

1. **外部 API・ネットワークエラーは自動リトライしない**
   - 自動リトライは多重実行・スパム・誤操作リスクがある
   - リトライが必要な場合は明示的なリトライポリシー（最大回数・バックオフ・冪等性確認）を設計する

2. **不可逆操作には必ずドライランモードを先に実装する**
   ```python
   # ドライランが先、本番操作はその後
   def publish(content: str, dry_run: bool = True) -> dict: ...
   ```

3. **すべての副作用ある操作をログに残す**
   ```
   {
     "timestamp": "...",
     "action": "...",
     "params": {...},
     "result": "success|failure|dry_run"
   }
   ```

4. **購入・投稿・課金・送信など高コストな操作は明示的な確認フラグを要求する**

5. **外部 API のレートリミットを尊重する**

---

## テスタビリティ

6. **新規コードでは `from x import CONST` ではなく `import x; x.CONST` を使う**
   - monkeypatch でモジュール属性を差し替えるとき、`from` import は import 時に値を束縛するため差し替えが効かない
   - 既存コードは本体変更時にのみ修正（一括改修しない）
   ```python
   # NG: monkeypatch が効かない
   from src.core.config import ACTIVE_PATH

   # OK: monkeypatch.setattr(config_mod, "ACTIVE_PATH", ...) が効く
   import src.core.config as config_mod
   config_mod.ACTIVE_PATH
   ```

7. **副作用関数は依存を引数で受ける（Dependency Injection）**
   - グローバル状態への依存はテスト時の差し替えコストを増やす
   - 時刻・乱数・I/O・ネットワークは引数化して mock 可能にする

8. **テスト失敗時に期待値を書き換える前に、コード側がバグである可能性を常に検討する**
   - 書き換えるなら「なぜ前の期待値が誤りか」を 1 行で根拠付ける
   - 詳細は `.claude/rules/scope-guard.md` 項目 4 を参照
