#!/bin/bash

# 変換対象のSCADファイルリスト
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SCAD_FILES=(
  "$ROOT_DIR/scad/electronics_bay.scad"
  "$ROOT_DIR/scad/electronics_mount.scad"
)

for file in "${SCAD_FILES[@]}"; do
  if [ -f "$file" ]; then
    filename="${file%.*}"
    echo "Converting $file to ${filename}.stl ..."
    openscad -o "${filename}.stl" "$file"
  else
    echo "Error: File not found - $file"
  fi
done

echo "All conversions finished."