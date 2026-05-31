#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAD_DIR="$ROOT_DIR/scad"
STL_DIR="$ROOT_DIR/stl"

if [[ -z "${QT_QPA_PLATFORM:-}" && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  export QT_QPA_PLATFORM=offscreen
fi

mkdir -p "$STL_DIR"

openscad -o "$STL_DIR/top_ring.stl" "$SCAD_DIR/top_ring.scad"
openscad -o "$STL_DIR/gasket_tpu.stl" "$SCAD_DIR/gasket.scad"
openscad -o "$STL_DIR/plenum.stl" "$SCAD_DIR/plenum.scad"
openscad -o "$STL_DIR/electronics_bay.stl" "$SCAD_DIR/electronics_bay.scad"
openscad -o "$STL_DIR/base.stl" "$SCAD_DIR/base.scad"
openscad -o "$STL_DIR/coffee_cooler_assembly.stl" "$SCAD_DIR/coffee_cooler.scad"
openscad -o "$STL_DIR/concept_assembly.stl" "$SCAD_DIR/concept_assembly.scad"

python3 "$ROOT_DIR/scripts/build_measurements.py" \
  --stl-dir "$STL_DIR" \
  --out-dir "$ROOT_DIR/exports/measurements"
