#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${COFFEE_COOLER_GDRIVE_DIR:?Error: COFFEE_COOLER_GDRIVE_DIR is not set}"

mkdir -p "$DEST_DIR"

rsync -av \
  --exclude '.git/' \
  --exclude '.DS_Store' \
  --exclude 'Thumbs.db' \
  "$ROOT_DIR/" \
  "$DEST_DIR/"

echo "Synced to: $DEST_DIR"
