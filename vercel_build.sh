#!/usr/bin/env bash
set -euo pipefail

# Versions
FLUTTER_CHANNEL="stable"
FLUTTER_VERSION="3.24.3"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLUTTER_DIR="$ROOT_DIR/flutter"
export PATH="$FLUTTER_DIR/bin:$PATH"
export CI=true
export PUB_CACHE="$ROOT_DIR/.pub-cache"

echo "[vercel] Using Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "[vercel] Downloading Flutter SDK..."
  curl -L "https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz" -o /tmp/flutter.tar.xz
  tar -C "$ROOT_DIR" -xJf /tmp/flutter.tar.xz
  # Allow git operations inside the Flutter SDK path under Vercel root
  git config --global --add safe.directory "$FLUTTER_DIR" || true
fi

flutter --version || true
flutter config --no-analytics || true
flutter config --enable-web
dart --disable-analytics || true

echo "[vercel] Cleaning pub cache and lockfile..."
rm -f pubspec.lock || true
rm -rf .dart_tool/pub || true
echo "[vercel] Pub get..."
flutter pub get

echo "[vercel] Generating localizations (gen-l10n)..."
flutter gen-l10n

# Debug: show intl constraint and resolved version
echo "[vercel] pubspec intl constraint:"
grep -nE '^[[:space:]]*intl:' pubspec.yaml || true
echo "[vercel] Resolved intl version in dependency tree:"
flutter pub deps | grep -E '\bintl\b' || true

# Dart defines from Vercel env
DEFINE_BACKEND="--dart-define=BACKEND_BASE_URL=${BACKEND_BASE_URL:-}"
DEFINE_SUPA_URL="--dart-define=SUPABASE_URL=${SUPABASE_URL:-}"
DEFINE_SUPA_KEY="--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}"

echo "[vercel] Building Flutter web..."
flutter build web --release --web-renderer canvaskit \
  $DEFINE_BACKEND $DEFINE_SUPA_URL $DEFINE_SUPA_KEY

echo "[vercel] Build complete: $(pwd)/build/web"
