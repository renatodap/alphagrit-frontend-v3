#!/usr/bin/env bash
set -euo pipefail

# Versions
FLUTTER_CHANNEL="stable"
FLUTTER_VERSION="3.24.3"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLUTTER_DIR="$ROOT_DIR/.flutter"
export PATH="$FLUTTER_DIR/bin:$PATH"

echo "[vercel] Using Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)"

if ! command -v flutter >/dev/null 2>&1; then
  mkdir -p "$FLUTTER_DIR"
  echo "[vercel] Downloading Flutter SDK..."
  curl -L "https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz" -o /tmp/flutter.tar.xz
  tar -C "$ROOT_DIR" -xJf /tmp/flutter.tar.xz
  mv "$ROOT_DIR/flutter" "$FLUTTER_DIR"
fi

flutter --version
flutter config --enable-web

echo "[vercel] Pub get..."
flutter pub get

# Dart defines from Vercel env
DEFINE_BACKEND="--dart-define=BACKEND_BASE_URL=${BACKEND_BASE_URL:-}"
DEFINE_SUPA_URL="--dart-define=SUPABASE_URL=${SUPABASE_URL:-}"
DEFINE_SUPA_KEY="--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}"

echo "[vercel] Building Flutter web..."
flutter build web --release --web-renderer canvaskit \
  $DEFINE_BACKEND $DEFINE_SUPA_URL $DEFINE_SUPA_KEY

echo "[vercel] Build complete → $(pwd)/build/web"

