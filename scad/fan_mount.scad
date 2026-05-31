include <params.scad>

module fan_screw_holes(h = 10) {
    for (x = [-fan_hole_pitch / 2, fan_hole_pitch / 2]) {
        for (y = [-fan_hole_pitch / 2, fan_hole_pitch / 2]) {
            translate([x, y, 0])
                cylinder(h = h, d = fan_screw_d, center = true);
        }
    }
}

module fan_cutout(h = 10) {
    cylinder(h = h, d = fan_cutout_d, center = true);
}
