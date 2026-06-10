#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# Lenderly Dialer — debug run script
#
# Usage:
#   bash scripts/run.sh [env]
#
# Arguments:
#   env  — Target environment: local | dev | prod  (default: local)
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ENV="${1:-local}"
PUBSPEC="pubspec.yaml"

# ── Read current version ──────────────────────────────────────────────────────
VERSION_FULL=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
CURRENT=$(echo "$VERSION_FULL" | sed 's/+.*//')

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Lenderly Dialer — Debug Run        ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  App version : $CURRENT"
echo "  Environment : $ENV"
echo ""
echo "  Running with:"
echo "    --dart-define=ENVIRONMENT=$ENV"
echo "    --dart-define=APP_VERSION=$CURRENT"
echo ""

flutter run \
  --dart-define=ENVIRONMENT="$ENV" \
  --dart-define=APP_VERSION="$CURRENT"
