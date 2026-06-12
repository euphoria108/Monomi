#!/bin/bash
# build/Monomi.app を組み立てて ad-hoc 署名する。
# App Sandbox は適用しない（SMC の IOKit アクセスに必要）。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/Monomi.app"

swift build -c release --package-path "$ROOT"
BIN="$(swift build -c release --package-path "$ROOT" --show-bin-path)/Monomi"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Monomi"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"

codesign --force --sign - "$APP"
echo "Built: $APP"
