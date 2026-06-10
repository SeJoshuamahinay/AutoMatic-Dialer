#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# Lenderly Dialer — interactive release build script
#
# Usage:
#   bash scripts/build.sh [env]
#
# Arguments:
#   env  — Target environment: local | dev | prod  (default: prod)
#
# Prompts for bump type (major / minor / bug), then:
#   1. Bumps pubspec.yaml version
#   2. Runs flutter build apk --release
#   3. Copies APK to build/.../lenderly-dialer-vX.Y.Z-YYYYMMDD.apk
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────────────────
ENV="${1:-prod}"
PUBSPEC="pubspec.yaml"
APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
APK_DIR="build/app/outputs/flutter-apk"

# ── Read current version ────────────────────────────────────────────────────────
CURRENT_LINE=$(grep '^version:' "$PUBSPEC")
VERSION_FULL=$(echo "$CURRENT_LINE" | sed 's/version: //')          # e.g. 2.0.0+5
CURRENT=$(echo "$VERSION_FULL" | sed 's/+.*//')                      # e.g. 2.0.0
BUILD_NUM=$(echo "$VERSION_FULL" | sed 's/.*+//')                    # e.g. 5

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Lenderly Dialer — Release Build    ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  Current version : $CURRENT  (build #$BUILD_NUM)"
echo "  Environment     : $ENV"
echo ""

# ── Ask bump type ───────────────────────────────────────────────────────────────
echo "  Bump type?"
echo "    1) major  — breaking change  (e.g. $((MAJOR+1)).0.0)"
echo "    2) minor  — new feature      (e.g. $MAJOR.$((MINOR+1)).0)"
echo "    3) bug    — patch fix        (e.g. $MAJOR.$MINOR.$((PATCH+1)))"
echo ""
read -rp "  Enter 1, 2 or 3: " CHOICE

case "$CHOICE" in
  1) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  2) MINOR=$((MINOR+1)); PATCH=0 ;;
  3) PATCH=$((PATCH+1)) ;;
  *)
    echo "❌  Invalid choice. Aborting."
    exit 1
    ;;
esac

NEW_VER="$MAJOR.$MINOR.$PATCH"
NEW_BUILD=$((BUILD_NUM+1))

echo ""
echo "  New version : $NEW_VER  (build #$NEW_BUILD)"
echo ""
read -rp "  Proceed? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "  Aborted."
  exit 0
fi

# ── Bump pubspec.yaml ────────────────────────────────────────────────────────────
echo ""
echo "▶ Bumping pubspec.yaml …"
sed -i '' "s/^version: .*/version: $NEW_VER+$NEW_BUILD/" "$PUBSPEC"
echo "  ✔ version: $NEW_VER+$NEW_BUILD"

# ── Flutter build ────────────────────────────────────────────────────────────────
echo ""
echo "▶ Building release APK  (ENV=$ENV, APP_VERSION=$NEW_VER) …"
flutter build apk --release \
  --dart-define=ENVIRONMENT="$ENV" \
  --dart-define=APP_VERSION="$NEW_VER"

# ── Rename APK ───────────────────────────────────────────────────────────────────
DATE=$(date +%Y%m%d)
APK_DEST="$APK_DIR/lenderly-dialer-v${NEW_VER}-${DATE}.apk"

cp "$APK_SRC" "$APK_DEST"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✔  Build complete                                           ║"
echo "╠══════════════════════════════════════════════════════════════╣"
printf "║  Version  : %-49s║\n" "$NEW_VER  (build #$NEW_BUILD)"
printf "║  APK      : %-49s║\n" "$(basename "$APK_DEST")"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
