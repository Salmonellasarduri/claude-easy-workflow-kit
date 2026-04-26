---
name: ux-comm
description: "Use this skill BEFORE reporting a completed code change to the user, proposing a new phase, or giving multi-step instructions. Defines three UX communication rules: every change report must include timing semantics (immediate / restart-required / config change), every acronym/phase-name must be expanded on first mention with a plain-language summary, and multi-step procedures must be delivered as copy-pasteable commands with full paths."
metadata:
  version: 1.0.0
---

# ux-comm — UX コミュニケーション規約

> 非技術者オーナー / 文系ユーザーへの伝達品質を守るための 3 規則。

---

## 1. 変更報告には必ず「反映タイミング」を添える

**コード変更を伝えるときは末尾に反映条件を明示する。**

- Why: ユーザーには「今動いているシステムに効いているのか」が不明で混乱する
- ケース別の定型文:
  - **即時**: 「次の処理から自動で有効になります（再起動不要）」
  - **再起動必要**: 「サービスを再起動すると有効になります」
  - **config ファイル変更**: 「config を書き換えたので、再起動後に有効になります」
  - **runtime ファイル**（JSON/YAML 等）: 「ファイルを更新しました。次のポーリング（数秒以内）で自動反映されます」

## 2. 略称は初出で展開し、平易な説明を先に

**新フェーズ・戦略を提案するときは必ず「一言で〜」の説明を添え、技術詳細の前に「何が変わるか」を非技術者でも理解できる言葉で示す。**

- Why: フェーズ名・略称（P4-1 / ML-B 等）だけでは伝わらない
- フォーマット: `フェーズ名: **一言で**（具体的に何が変わるか）→ 技術詳細`

例:
- 悪い: 「P4-1 を着手します」
- 良い: 「**P4-1: ログイン後の遷移先を 1 画面減らす**（クリック数が 1 回減ります）→ 技術詳細: ...」

## 3. 複数工程の手順はコピペ可能な形で全工程提示

**変更の反映に複数工程が必要な場合、全工程をコピペ可能なコマンド付きで案内する。**

- Why: 開発者にとって自明な手順（ビルド・サービス再起動・キャッシュクリア）もユーザーには順序・コマンド・パスが不明
- 「〜してください」ではなく「**以下を実行してください:** （コマンド）」の形式
- パスは省略せずフル

例（悪い）:
> ビルドしてサービスを再起動してください。

例（良い）:
> 以下を実行してください:
> ```
> cd /path/to/project
> npm run build
> systemctl restart my-service
> ```
> 完了後、ブラウザで再読み込みしてください。
