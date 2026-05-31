include <params.scad>

module side_vents(radius = body_outer_d / 2, center_z = vent_center_z) {
    for (i = [0 : vent_count - 1]) {
        rotate([0, 0, i * 360 / vent_count])
            translate([radius, 0, center_z])
                for (row = [0 : vent_rows - 1]) {
                    translate([0, 0, (row - (vent_rows - 1) / 2) * vent_row_pitch])
                        cube([wall * 4, vent_slot_w, vent_slot_h], center = true);
                }
    }
}
