#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# Lenderly Dialer — debug run script
#   Prompts for environment and device, then runs the app.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PUBSPEC="pubspec.yaml"
VERSION_FULL=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
CURRENT=$(echo "$VERSION_FULL" | sed 's/+.*//')

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Lenderly Dialer — Debug Run        ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Pick environment ──────────────────────────────────────────────────────────
echo "Select environment:"
echo "  1) dev    (dev.lenderly.ph)"
echo "  2) prod   (production)"
echo "  3) local  (local backend)"
read -r -p "Choice [1]: " env_choice
env_choice="${env_choice:-1}"

case "$env_choice" in
  1|"") ENV="dev" ;;
  2)    ENV="prod" ;;
  3)    ENV="local" ;;
  *)    echo "Invalid choice"; exit 1 ;;
esac

echo ""
echo "  App version : $CURRENT"
echo "  Environment : $ENV"
echo ""

# ── Pick device ──────────────────────────────────────────────────────────────
echo "Select device:"
echo "  1) iOS Simulator  (iPhone 16 Pro)"
echo "  2) Android Emulator (Pixel 6 API 34)"
echo "  3) Physical device / other"
read -r -p "Choice [1]: " device_choice
device_choice="${device_choice:-1}"

case "$device_choice" in
  1)
    DEVICE="iPhone 16 Pro"
    echo ""
    echo "  Booting iOS simulator..."
    xcrun simctl boot "$DEVICE" 2>/dev/null || true
    open -a Simulator 2>/dev/null || true
    echo "  Waiting for simulator..."
    sleep 4
    ;;
  2)
    DEVICE="Pixel_6_API_34"
    echo ""
    echo "  Launching Android emulator..."
    flutter emulators --launch "$DEVICE" 2>/dev/null || true
    echo "  Waiting for emulator..."
    sleep 6
    ;;
  3)
    echo ""
    echo "  Available devices:"
    DEVICES=$(flutter devices 2>/dev/null | tail -n +2 || true)
    if [ -z "$DEVICES" ]; then
      echo "    No devices found."
      DEVICE=""
    else
      IFS=$'\n' read -r -d '' -a DEVICE_LIST <<< "$DEVICES" || true
      for i in "${!DEVICE_LIST[@]}"; do
        echo "    $((i+1))) ${DEVICE_LIST[$i]}"
      done
      echo ""
      read -r -p "  Select device [1]: " dev_num
      dev_num="${dev_num:-1}"
      if [[ "$dev_num" =~ ^[0-9]+$ ]] && (( dev_num >= 1 && dev_num <= ${#DEVICE_LIST[@]} )); then
        DEVICE=$(echo "${DEVICE_LIST[$((dev_num-1))]}" | awk -F' • ' '{print $2}' | xargs)
      else
        echo "  Invalid selection."
        DEVICE=""
      fi
    fi
    ;;
  *)
    echo "Invalid choice"; exit 1 ;;
esac

echo ""
echo "  Running with:"
echo "    --dart-define=ENVIRONMENT=$ENV"
echo "    --dart-define=APP_VERSION=$CURRENT"
echo ""

if [ -n "${DEVICE:-}" ]; then
  flutter run \
    --dart-define=ENVIRONMENT="$ENV" \
    --dart-define=APP_VERSION="$CURRENT" \
    -d "$DEVICE"
else
  flutter run \
    --dart-define=ENVIRONMENT="$ENV" \
    --dart-define=APP_VERSION="$CURRENT"
fi
