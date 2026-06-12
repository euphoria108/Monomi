# Monomi

macOS のメニューバーに常駐するシステムモニター。

## 機能

| 項目 | メニューバー表示 | 詳細ポップオーバー |
|---|---|---|
| CPU | 使用率スパークライン + % | user/system 履歴チャート、コア別バー、Load Average、上位プロセス |
| メモリ | 使用率ゲージ + % | 履歴チャート、アプリ/Wired/圧縮/スワップ内訳、メモリプレッシャー |
| ネットワーク | ↓↑ 転送レート | 履歴チャート、セッション累計、プライマリ IF、IP アドレス |
| ディスク | R/W レート | ボリューム別使用率バー、I/O レート |
| バッテリー | アイコン + %（搭載機のみ） | 充電状態、残り時間 |
| センサー | CPU 温度 | CPU/GPU 温度、ファン回転数（SMC 読み取り） |

## 必要環境

- macOS 15 以降（開発・確認は macOS 26 / Intel Mac）
- Xcode（Swift 6 ツールチェーン）

> **Note**: センサー（温度・ファン）は SMC 読み取りに依存します。Intel Mac の古典キー
> （`TC0P` 等）に対応済み。Apple Silicon はキー体系が異なるため v2 対応予定です。
> SMC が読めない環境ではセンサー項目は自動的に非表示になります。

## ビルドと実行

```bash
make build   # swift build
make test    # swift test
make run     # 開発実行（メニューバーに表示、Dock 非表示）
make app     # build/Monomi.app を生成（release ビルド + ad-hoc 署名）
make clean
```

`make app` で生成した `Monomi.app` を `/Applications` 等に置いて起動すると常駐アプリとして使えます。

> **Note**: 「ログイン時に起動」（`SMAppService`）は `.app` バンドルから起動した場合のみ
> 有効です。`swift run` では動作しません。
> また App Sandbox は適用していません（SMC の IOKit アクセスに必要なため）。

## 設定

ステータスアイテムのポップオーバー下部の「設定」、または ⌘, から：

- 表示する項目の切り替え（CPU / メモリ / ネットワーク / ディスク / バッテリー / センサー）
- 更新間隔（1 / 2 / 5 秒）
- ログイン時に起動

## アーキテクチャ

```
Sources/
├── CShims/      # libproc・ルーティングソケット・SMCParamStruct を Swift へ公開する C ターゲット
├── MonomiKit/   # メトリクス収集ライブラリ（UI 非依存・テスト対象）
│   ├── Collectors/  # CPU / メモリ / プロセス / ネットワーク / ディスク / バッテリー / センサー
│   ├── SMC/         # AppleSMC クライアントと型駆動デコーダ
│   └── Scheduler/   # MetricsActor（global actor）+ AsyncStream 配信
└── Monomi/      # メニューバーアプリ（NSStatusItem + SwiftUI / Swift Charts）
```

- コレクターはすべて `@MetricsActor` 上で動作し、ブロッキングな C API 呼び出しを UI から隔離
- スナップショットは `Sendable` 構造体として `@MainActor` の `MetricStore` へ配信
- 既知の制限: 上位プロセスは root 権限なしでは自ユーザーのプロセスのみ

## 開発ルール

- デフォルトブランチは `develop`。feature ブランチを切って PR を `develop` へマージ
- `main` への直接コミット禁止
