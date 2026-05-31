include <params.scad>

module plenum() {
    difference() {
        cylinder(h = plenum_h, d = body_outer_d);

        translate([0, 0, wall])
            cylinder(h = plenum_h, d = body_outer_d - wall * 2);

        translate([0, 0, -1])
            cylinder(h = wall + 2, d = fan_cutout_d);
    }
}

plenum();
