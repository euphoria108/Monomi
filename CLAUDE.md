# CLAUDE.md

このファイルは、このリポジトリのコードで作業するときに Claude Code (claude.ai/code) に指針を提供します。

## プロジェクト概要

**Monomi** は macOS のメニューバーに常駐するシステムモニター（iStat Menus ライク）。
CPU・メモリ・ネットワーク・ディスク・バッテリー・センサー（SMC 経由の温度/ファン）を監視する。

## 技術スタック

- Swift 6（strict concurrency）+ SwiftUI、SwiftPM のみ（xcodeproj なし）
- メニューバー: `NSStatusItem` + `NSHostingView`（MenuBarExtra はカラー描画不可のため不採用）
- App Sandbox 非適用（SMC の IOKit アクセスに必要）

## ビルド・テスト

```bash
make build   # swift build
make test    # swift test
make run     # 開発実行
make app     # build/Monomi.app 生成（ad-hoc 署名）
```

## アーキテクチャの要点

- `Sources/CShims/`: libproc・net/route.h・SMCParamStruct（80 byte レイアウト保証）を Swift へ公開
- `Sources/MonomiKit/`: コレクターライブラリ。全コレクターは `@MetricsActor`（global actor）上で動作し、`Sendable` スナップショットを `AsyncStream<MetricEvent>` で配信
- `Sources/Monomi/`: アプリ本体。`MetricStore`（@MainActor @Observable）が stream を消費
- SMC のキー値は **必ず GetKeyInfo で報告された型でデコードする**（機種によりファンキーが fpe2/flt と異なる）
- カウンタ差分は負になったら 0 にクランプ（スリープ復帰対策）

## GitHub 開発ルール

- **デフォルトブランチは `develop`**: 開発の起点は `develop` ブランチ
- **feature ブランチ運用**: 作業は `develop` から feature ブランチを作成して行う
- **PR のマージ先は `develop`**: feature ブランチの PR は `develop` にマージする
- **main への直接コミット禁止**: `main` ブランチに直接コミットしない
