#!/usr/bin/env python3
"""Generate per-STL measurement sheets as SVG files.

The repository keeps the modeled parts in `stl/`. This script mirrors that
layout under `exports/measurements/` and emits a drawing for each STL file.
The drawings are schematic technical sheets based on the OpenSCAD parameters,
which keeps them stable and readable without requiring a CAD runtime.
"""

from __future__ import annotations

import argparse
import ast
import math
import re
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple
from xml.sax.saxutils import escape


ROOT_DIR = Path(__file__).resolve().parents[1]


def fmt_mm(value: float) -> str:
    return f"{value:.2f}"


def fmt_int(value: float) -> str:
    if abs(value - round(value)) < 1e-9:
        return str(int(round(value)))
    return fmt_mm(value)


def safe_eval(expr: str, env: Dict[str, float]) -> float:
    allowed_ops = {
        ast.Add: lambda a, b: a + b,
        ast.Sub: lambda a, b: a - b,
        ast.Mult: lambda a, b: a * b,
        ast.Div: lambda a, b: a / b,
        ast.FloorDiv: lambda a, b: a // b,
        ast.Mod: lambda a, b: a % b,
        ast.Pow: lambda a, b: a**b,
    }

    def _eval(node: ast.AST) -> float:
        if isinstance(node, ast.Expression):
            return _eval(node.body)
        if isinstance(node, ast.Constant):
            if isinstance(node.value, (int, float)):
                return float(node.value)
            raise ValueError(f"Unsupported constant: {node.value!r}")
        if isinstance(node, ast.Name):
            if node.id not in env:
                raise KeyError(node.id)
            return float(env[node.id])
        if isinstance(node, ast.UnaryOp):
            if isinstance(node.op, ast.UAdd):
                return +_eval(node.operand)
            if isinstance(node.op, ast.USub):
                return -_eval(node.operand)
            raise ValueError(f"Unsupported unary op: {ast.dump(node.op)}")
        if isinstance(node, ast.BinOp):
            op_type = type(node.op)
            if op_type not in allowed_ops:
                raise ValueError(f"Unsupported operator: {ast.dump(node.op)}")
            return allowed_ops[op_type](_eval(node.left), _eval(node.right))
        raise ValueError(f"Unsupported expression: {ast.dump(node)}")

    parsed = ast.parse(expr, mode="eval")
    return float(_eval(parsed))


def load_scad_params(path: Path) -> Dict[str, float]:
    params: Dict[str, float] = {}
    assign_re = re.compile(r"^\s*([A-Za-z_]\w*)\s*=\s*(.+?);\s*$")

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.split("//", 1)[0].strip()
        if not line:
            continue
        match = assign_re.match(line)
        if not match:
            continue
        name, expr = match.groups()
        try:
            params[name] = safe_eval(expr, params)
        except Exception:
            # Keep the parser permissive so future non-numeric additions do not
            # break the sheet generator.
            continue
    return params


def load_stl_paths(stl_dir: Path) -> List[Path]:
    return sorted(path for path in stl_dir.glob("*.stl") if path.is_file())


def stl_bounds(path: Path) -> Tuple[float, float, float, float, float, float]:
    data = path.read_bytes()
    if len(data) < 84:
        raise ValueError(f"STL too small: {path}")

    tri_count = struct.unpack_from("<I", data, 80)[0]
    expected = 84 + tri_count * 50
    if expected == len(data):
        floats = struct.iter_unpack("<12fH", data[84:])
        xs: List[float] = []
        ys: List[float] = []
        zs: List[float] = []
        for record in floats:
            coords = record[1:10]
            xs.extend(coords[0::3])
            ys.extend(coords[1::3])
            zs.extend(coords[2::3])
        return min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)

    text = data.decode("utf-8", errors="ignore")
    xs = []
    ys = []
    zs = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("vertex"):
            _, x, y, z = stripped.split()
            xs.append(float(x))
            ys.append(float(y))
            zs.append(float(z))
    if not xs:
        raise ValueError(f"Could not parse STL geometry: {path}")
    return min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)


def svg_header(width: float, height: float, title: str) -> List[str]:
    return [
        '<?xml version="1.0" encoding="UTF-8"?>',
        (
            f'<svg xmlns="http://www.w3.org/2000/svg" '
            f'width="{width:.0f}" height="{height:.0f}" '
            f'viewBox="0 0 {width:.2f} {height:.2f}" '
            f'font-family="Inter, Arial, sans-serif">'
        ),
        "<defs>",
        (
            '<marker id="arrow" markerWidth="8" markerHeight="8" refX="4" '
            'refY="4" orient="auto" markerUnits="strokeWidth">'
            '<path d="M 0 0 L 8 4 L 0 8 z" fill="#2b2b2b"/></marker>'
        ),
        (
            '<pattern id="grid10" width="10" height="10" patternUnits="userSpaceOnUse">'
            '<path d="M 10 0 L 0 0 0 10" fill="none" stroke="#edf2f6" stroke-width="0.6"/>'
            "</pattern>"
        ),
        (
            '<pattern id="grid50" width="50" height="50" patternUnits="userSpaceOnUse">'
            '<rect width="50" height="50" fill="url(#grid10)"/>'
            '<path d="M 50 0 L 0 0 0 50" fill="none" stroke="#dbe3ea" stroke-width="0.8"/>'
            "</pattern>"
        ),
        "</defs>",
        f'<rect x="0" y="0" width="{width:.2f}" height="{height:.2f}" fill="#fbfcfd"/>',
        f'<rect x="0" y="0" width="{width:.2f}" height="{height:.2f}" fill="url(#grid50)"/>',
        (
            f'<text x="24" y="34" font-size="22" fill="#1f2933" font-weight="700">'
            f"{escape(title)}</text>"
        ),
    ]


def svg_footer() -> List[str]:
    return ["</svg>"]


def line(x1: float, y1: float, x2: float, y2: float, stroke: str = "#2b2b2b", width: float = 1.2, dash: str = "") -> str:
    dash_attr = f' stroke-dasharray="{dash}"' if dash else ""
    return (
        f'<line x1="{x1:.2f}" y1="{y1:.2f}" x2="{x2:.2f}" y2="{y2:.2f}" '
        f'stroke="{stroke}" stroke-width="{width:.2f}"{dash_attr}/>'
    )


def circle(cx: float, cy: float, r: float, stroke: str = "#c56b19", width: float = 2.2, fill: str = "none", dash: str = "") -> str:
    dash_attr = f' stroke-dasharray="{dash}"' if dash else ""
    return (
        f'<circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r:.2f}" '
        f'stroke="{stroke}" stroke-width="{width:.2f}" fill="{fill}"{dash_attr}/>'
    )


def rect(x: float, y: float, w: float, h: float, stroke: str = "#c56b19", width: float = 2.2, fill: str = "none", dash: str = "") -> str:
    dash_attr = f' stroke-dasharray="{dash}"' if dash else ""
    return (
        f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" '
        f'stroke="{stroke}" stroke-width="{width:.2f}" fill="{fill}"{dash_attr}/>'
    )


def text(x: float, y: float, value: str, size: float = 14, anchor: str = "middle", rotate: Optional[float] = None, fill: str = "#1f2933", weight: str = "400") -> str:
    rotate_attr = f' transform="rotate({rotate:.2f} {x:.2f} {y:.2f})"' if rotate is not None else ""
    return (
        f'<text x="{x:.2f}" y="{y:.2f}" font-size="{size:.2f}" '
        f'text-anchor="{anchor}" fill="{fill}" font-weight="{weight}"{rotate_attr}>'
        f"{escape(value)}</text>"
    )


def center_marks(cx: float, cy: float, size: float = 6.0, stroke: str = "#7c8794") -> List[str]:
    return [
        line(cx - size, cy, cx + size, cy, stroke=stroke, width=0.9),
        line(cx, cy - size, cx, cy + size, stroke=stroke, width=0.9),
    ]


def dim_h(x1: float, x2: float, y: float, label: str, ext_top: float, text_offset: float = -6.0) -> List[str]:
    return [
        line(x1, ext_top, x1, y, stroke="#7a7a7a", width=0.8),
        line(x2, ext_top, x2, y, stroke="#7a7a7a", width=0.8),
        (
            f'<line x1="{x1:.2f}" y1="{y:.2f}" x2="{x2:.2f}" y2="{y:.2f}" '
            'stroke="#2b2b2b" stroke-width="1.0" marker-start="url(#arrow)" marker-end="url(#arrow)"/>'
        ),
        text((x1 + x2) / 2, y + text_offset, label, size=14),
    ]


def dim_v(x: float, y1: float, y2: float, label: str, ext_left: float, text_offset: float = -6.0, rotate: float = -90.0) -> List[str]:
    return [
        line(ext_left, y1, x, y1, stroke="#7a7a7a", width=0.8),
        line(ext_left, y2, x, y2, stroke="#7a7a7a", width=0.8),
        (
            f'<line x1="{x:.2f}" y1="{y1:.2f}" x2="{x:.2f}" y2="{y2:.2f}" '
            'stroke="#2b2b2b" stroke-width="1.0" marker-start="url(#arrow)" marker-end="url(#arrow)"/>'
        ),
        text(x + text_offset, (y1 + y2) / 2, label, size=14, rotate=rotate),
    ]


def note_box(x: float, y: float, lines: Sequence[str], w: float = 180, h: Optional[float] = None) -> List[str]:
    line_h = 20
    height = h if h is not None else max(42, 16 + len(lines) * line_h)
    items = [rect(x, y, w, height, stroke="#94a3b8", width=1.0, fill="#ffffffcc")]
    for idx, value in enumerate(lines):
        items.append(text(x + 10, y + 26 + idx * line_h, value, size=13, anchor="start"))
    return items


def top_view_sheet(title: str, notes: Sequence[str], width: float = 700, height: float = 500) -> List[str]:
    return svg_header(width, height, title) + note_box(width - 200, 24, notes)


def write_svg(path: Path, lines: Iterable[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def render_top_ring(params: Dict[str, float], title: str) -> List[str]:
    w, h = 700, 500
    cx, cy = 230, 235
    outer_r = params["body_outer_d"] / 2
    opening_r = params["sieve_opening_d"] / 2
    seat_r = params["sieve_ring_seat_d"] / 2
    sheet = top_view_sheet(
        title,
        [
            f"body_outer_d = {fmt_mm(params['body_outer_d'])} mm",
            f"sieve_opening_d = {fmt_mm(params['sieve_opening_d'])} mm",
            f"sieve_ring_seat_d = {fmt_mm(params['sieve_ring_seat_d'])} mm",
            f"top_ring_h = {fmt_mm(params['top_ring_h'])} mm",
        ],
        width=w,
        height=h,
    )
    sheet += center_marks(cx, cy)
    sheet += [circle(cx, cy, outer_r), circle(cx, cy, seat_r, dash="6 4"), circle(cx, cy, opening_r)]
    sheet += dim_h(cx - outer_r, cx + outer_r, 390, f"body_outer_d Ø{fmt_mm(params['body_outer_d'])}", ext_top=cy + outer_r)
    sheet += dim_h(cx - opening_r, cx + opening_r, 120, f"sieve_opening_d Ø{fmt_mm(params['sieve_opening_d'])}", ext_top=cy - opening_r)
    sheet += dim_v(450, cy - seat_r, cy + seat_r, f"sieve_ring_seat_d Ø{fmt_mm(params['sieve_ring_seat_d'])}", ext_left=cx + seat_r)
    sheet += dim_v(545, cy - params["top_ring_h"] / 2, cy + params["top_ring_h"] / 2, f"top_ring_h {fmt_mm(params['top_ring_h'])}", ext_left=500, rotate=-90)
    return sheet + svg_footer()


def fan_hole_positions(params: Dict[str, float]) -> List[Tuple[float, float]]:
    pitch = params["fan_hole_pitch"] / 2
    return [(-pitch, -pitch), (pitch, -pitch), (-pitch, pitch), (pitch, pitch)]


def render_base(params: Dict[str, float], title: str) -> List[str]:
    w, h = 760, 540
    cx, cy = 235, 245
    outer_r = params["body_outer_d"] / 2
    exhaust_r = (params["body_outer_d"] - params["wall"] * 2) / 2
    fan_r = params["fan_cutout_d"] / 2
    box_d = params.get("electronics_box_d", 34.0)
    box_w = params.get("electronics_box_w", 80.0)
    box_x = params["body_outer_d"] / 2 - box_d / 2
    box_y = -box_w / 2
    sheet = top_view_sheet(
        title,
        [
            f"外径 {fmt_mm(params['body_outer_d'])} mm",
            f"ファン開口 {fmt_mm(params['fan_cutout_d'])} mm",
            f"穴ピッチ {fmt_mm(params['fan_hole_pitch'])} mm",
            f"電装箱 {fmt_mm(box_d)} × {fmt_mm(box_w)} mm",
            f"高さ {fmt_mm(params['base_h'])} mm",
        ],
        width=w,
        height=h,
    )
    sheet += center_marks(cx, cy)
    sheet += [circle(cx, cy, outer_r), circle(cx, cy, exhaust_r, dash="6 4"), circle(cx, cy, fan_r)]
    for dx, dy in fan_hole_positions(params):
        sheet.append(circle(cx + dx, cy + dy, params["fan_screw_d"] / 2, stroke="#2b2b2b", width=1.0, fill="none"))
    sheet.append(rect(cx + box_x - 3, cy + box_y, box_d, box_w, stroke="#64748b", width=1.4))
    sheet += dim_h(cx - outer_r, cx + outer_r, 415, f"Ø{fmt_mm(params['body_outer_d'])}", ext_top=cy + outer_r)
    sheet += dim_h(cx - fan_r, cx + fan_r, 90, f"Ø{fmt_mm(params['fan_cutout_d'])}", ext_top=cy - fan_r)
    sheet += dim_h(cx - params["fan_hole_pitch"] / 2, cx + params["fan_hole_pitch"] / 2, 120, f"{fmt_mm(params['fan_hole_pitch'])}", ext_top=cy - params["fan_hole_pitch"] / 2)
    sheet += dim_v(580, cy - params["base_h"] / 2, cy + params["base_h"] / 2, f"{fmt_mm(params['base_h'])}", ext_left=540, rotate=-90)
    return sheet + svg_footer()


def render_assembly(params: Dict[str, float], title: str, include_mock: bool = False) -> List[str]:
    w, h = 620, 560
    x0, y0 = 130, 450
    body_w = params["body_outer_d"]
    base_h = params["base_h"]
    top_ring_h = params["top_ring_h"]
    gap = 2.0

    sheet = svg_header(w, h, title)
    sheet += note_box(412, 24, [
        f"全高 {fmt_mm(base_h + gap + top_ring_h)} mm",
        f"ベース {fmt_mm(base_h)} mm",
        f"トップリング {fmt_mm(top_ring_h)} mm",
    ], w=184)

    sheet.append(rect(40, 40, 260, 420, stroke="#cbd5e1", width=1.0, fill="#ffffff70"))
    sheet.append(rect(40, 40, 260, 420, stroke="#94a3b8", width=1.4, fill="none"))

    base_top = y0 - base_h
    ring_top = base_top - gap - top_ring_h

    # Base block
    sheet.append(rect(x0 - body_w / 2, base_top, body_w, base_h, stroke="#c56b19", width=2.2))
    sheet.append(rect(x0 + body_w / 2, base_top + 20, 26, 38, stroke="#64748b", width=1.6))
    # Top ring
    sheet.append(rect(x0 - body_w / 2, ring_top, body_w, top_ring_h, stroke="#c56b19", width=2.2, fill="#fffaf3"))

    sheet += dim_v(340, ring_top, y0, f"{fmt_mm(base_h + gap + top_ring_h)}", ext_left=305, rotate=-90)
    sheet += dim_v(68, base_top, y0, f"{fmt_mm(base_h)}", ext_left=55, rotate=-90)
    sheet += dim_v(116, ring_top, base_top - gap, f"{fmt_mm(top_ring_h)}", ext_left=103, rotate=-90)
    sheet += text(58, 494, "側面模式図", size=14, anchor="start", weight="700")

    if include_mock:
        sheet.append(text(58, 520, "概念図ではファン・ザル・電装部のモックを重ねる", size=12, anchor="start", fill="#475569"))

    return sheet + svg_footer()


def render_generic(path: Path, params: Dict[str, float]) -> List[str]:
    try:
        xmin, ymin, zmin, xmax, ymax, zmax = stl_bounds(path)
        notes = [
            f"X {fmt_mm(xmax - xmin)} mm",
            f"Y {fmt_mm(ymax - ymin)} mm",
            f"Z {fmt_mm(zmax - zmin)} mm",
        ]
    except Exception:
        notes = ["STL解析に失敗したため簡易シートを出力"]
    sheet = top_view_sheet(path.stem, notes, width=640, height=420)
    sheet += [
        rect(90, 110, 240, 160, stroke="#c56b19", width=2.0),
        text(210, 300, "簡易投影図", size=18, weight="700"),
    ]
    return sheet + svg_footer()


def render_sheet(path: Path, params: Dict[str, float]) -> List[str]:
    stem = path.stem
    if stem == "top_ring":
        return render_top_ring(params, stem)
    if stem == "base":
        return render_base(params, stem)
    if stem == "coffee_cooler_assembly":
        return render_assembly(params, stem, include_mock=False)
    if stem == "concept_assembly":
        return render_assembly(params, stem, include_mock=True)
    return render_generic(path, params)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate SVG measurement sheets for each STL file.")
    parser.add_argument("--stl-dir", type=Path, default=ROOT_DIR / "stl", help="Input STL directory.")
    parser.add_argument("--out-dir", type=Path, default=ROOT_DIR / "exports" / "measurements", help="Output SVG directory.")
    parser.add_argument("--params", type=Path, default=ROOT_DIR / "scad" / "params.scad", help="OpenSCAD parameter file.")
    args = parser.parse_args()

    params = load_scad_params(args.params)
    if not params:
        raise SystemExit(f"Failed to load parameters from {args.params}")

    stl_paths = load_stl_paths(args.stl_dir)
    if not stl_paths:
        raise SystemExit(f"No STL files found under {args.stl_dir}")

    for stl_path in stl_paths:
        rel = stl_path.relative_to(args.stl_dir)
        out_path = args.out_dir / rel.with_suffix(".svg")
        sheet = render_sheet(stl_path, params)
        write_svg(out_path, sheet)

    print(f"Wrote {len(stl_paths)} measurement sheet(s) to {args.out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
