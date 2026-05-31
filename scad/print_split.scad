include <params.scad>
use <base.scad>
use <plenum.scad>
use <top_ring.scad>

part = "top_ring";
quadrant = "ne";

module selected_part() {
    if (part == "top_ring") {
        top_ring();
    } else if (part == "plenum") {
        plenum();
    } else if (part == "base") {
        base();
    }
}

module quadrant_clip(q = "ne") {
    clip_h = base_h + plenum_h + top_ring_h + 20;
    clip_xy = body_outer_d + electronics_box_d + 20;
    x = q == "ne" || q == "se" ? clip_xy / 2 : -clip_xy / 2;
    y = q == "ne" || q == "nw" ? clip_xy / 2 : -clip_xy / 2;

    translate([x, y, clip_h / 2])
        cube([clip_xy, clip_xy, clip_h], center = true);
}

intersection() {
    selected_part();
    quadrant_clip(quadrant);
}
