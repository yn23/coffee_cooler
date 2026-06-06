#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAD_DIR="$ROOT_DIR/scad"
STL_DIR="$ROOT_DIR/stl"

if [[ -z "${QT_QPA_PLATFORM:-}" && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  export QT_QPA_PLATFORM=offscreen
fi

mkdir -p "$STL_DIR"

echo "Building top_ring.stl..."
openscad -o "$STL_DIR/top_ring.stl" "$SCAD_DIR/top_ring.scad"

echo "Building base.stl..."
openscad -o "$STL_DIR/base.stl" "$SCAD_DIR/base.scad"

echo "Building electronics_bay.stl..."
openscad -o "$STL_DIR/electronics_bay.stl" "$SCAD_DIR/electronics_bay.scad"

python3 "$ROOT_DIR/scripts/build_measurements.py" \
  --stl-dir "$STL_DIR" \
  --out-dir "$ROOT_DIR/exports/measurements"
