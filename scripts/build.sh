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

# ── Upload to SharePoint ─────────────────────────────────────────────────────
SHAREPOINT_DEST="lenderly:Infrastructure/APK FOLDER/version $NEW_VER"
echo ""
echo "▶ Uploading to SharePoint …"
SHARE_LINK=""
if rclone copy "$APK_DEST" "$SHAREPOINT_DEST" --progress; then
  UPLOAD_STATUS="✔ Uploaded to SharePoint"
  echo ""
  echo "▶ Generating shareable link …"
  APK_NAME=$(basename "$APK_DEST")
  LINK_ERR=$(mktemp)
  SHARE_LINK=$(rclone link "$SHAREPOINT_DEST/$APK_NAME" --onedrive-link-scope organization 2>"$LINK_ERR" || echo "")
  if [[ -n "$SHARE_LINK" ]]; then
    echo "  ✔ $SHARE_LINK"
  else
    echo "  ⚠  Could not generate link:"
    cat "$LINK_ERR"
  fi
  rm -f "$LINK_ERR"
else
  UPLOAD_STATUS="⚠  SharePoint upload failed (APK saved locally)"
fi

# ── Send release email (reusable) ───────────────────────────────────────────
_send_release_email() {
  local ver="$1" link="$2"
  local subject="New Update Available: Dialer v${ver}"
  local body
body="Hi Team,

A new update for the Dialer (v${ver}) is now available!

What's New:
- Performance Optimization: Compressed and optimized for a much lighter, faster experience.
- UI Updates: Minor user interface tweaks for smoother navigation.

How to Download & Log In:
1. Download: Please use Outlook to access and click the download link below.
2. Login: Once installed, use your Symphony account credentials to log in to the app.

Please click the link below to download version ${ver} as soon as possible to ensure everything runs smoothly and to avoid any work disruptions.

Download: ${link}

Let us know if you run into any issues!
Email us for support and questions to it@lenderly.ph

Best Regards,
Joshua Mahinay
Full Stack Software Engineer

WhatsApp: +639669426920
Email: jMahinay@lenderly.ph"
  local mailto_url
  mailto_url=$(python3 -c "
import urllib.parse, sys
print('mailto:FieldCollector@lenderly.ph?cc=management@lenderly.ph&subject=' +
      urllib.parse.quote(sys.argv[1]) + '&body=' + urllib.parse.quote(sys.argv[2]))
" "$subject" "$body")
  echo ""
  echo "▶ Opening Outlook with pre-filled email …"
  open "$mailto_url"
  echo "  ✔ Outlook opened — review and hit Send"
}

# ── Prompt to send / redo email ──────────────────────────────────────────────
if [[ -n "$SHARE_LINK" ]]; then
  while true; do
    echo ""
    read -rp "  Send release email? [Y/n] " SEND_EMAIL
    [[ "$SEND_EMAIL" =~ ^[Nn]$ ]] && break
    _send_release_email "$NEW_VER" "$SHARE_LINK"
    echo ""
    read -rp "  Redo / resend email? [y/N] " REDO_EMAIL
    [[ ! "$REDO_EMAIL" =~ ^[Yy]$ ]] && break
  done
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✔  Build complete                                           ║"
echo "╠══════════════════════════════════════════════════════════════╣"
printf "║  Version  : %-49s║\n" "$NEW_VER  (build #$NEW_BUILD)"
printf "║  APK      : %-49s║\n" "$(basename "$APK_DEST")"
printf "║  Upload   : %-49s║\n" "$UPLOAD_STATUS"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
