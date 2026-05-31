include <params.scad>

module mock_sieve() {
    color("silver")
        difference() {
            union() {
                translate([0, 0, sieve_h / 2])
                    cylinder(h = sieve_h, d1 = sieve_outer_d - 46, d2 = sieve_outer_d - 8);
                translate([0, 0, sieve_h])
                    torus_like(d = sieve_outer_d, tube_d = 4);
            }

            translate([0, 0, sieve_h / 2 - 1])
                cylinder(h = sieve_h + 4, d1 = sieve_outer_d - 56, d2 = sieve_outer_d - 18);
        }

    color("gray")
        translate([0, 0, 4])
            cylinder(h = 1, d = sieve_outer_d - 46);
}

module mock_fan() {
    color("black")
        translate([0, 0, fan_thickness / 2])
            difference() {
                rounded_square_fan_body(fan_size, fan_thickness, 8);
                cylinder(h = fan_thickness + 2, d = fan_cutout_d - 8, center = true);
                fan_screw_hole_markers(fan_thickness + 2);
            }

    color("dimgray")
        translate([0, 0, fan_thickness / 2])
            cylinder(h = fan_thickness + 1, d = 42, center = true);

    color("gray")
        for (i = [0 : 6]) {
            rotate([0, 0, i * 360 / 7])
                translate([32, 0, fan_thickness / 2])
                    cube([48, 11, 2], center = true);
        }
}

module mock_electronics() {
    board_x = body_outer_d / 2 + 8;
    // Mock-only constants. Keep this module independent from parameter churn
    // so preview builds do not emit undefined-variable warnings.
    pwm_knob_z_mock = 22;
    pwm_board_w_mock = 32;
    pwm_board_h_mock = 20;
    dc_jack_z_mock = 38;
    dc_jack_body_d_mock = 14;

    color("forestgreen")
        translate([board_x, 0, pwm_knob_z_mock])
            cube([2, pwm_board_w_mock, pwm_board_h_mock], center = true);

    color("saddlebrown")
        translate([board_x + 2, 0, dc_jack_z_mock])
            rotate([0, 90, 0])
                cylinder(h = 10, d = dc_jack_body_d_mock, center = true);

    color("black")
        translate([board_x + 4, 0, pwm_knob_z_mock])
            rotate([0, 90, 0])
                cylinder(h = 10, d = 18, center = true);

}

module torus_like(d, tube_d) {
    rotate_extrude(convexity = 10)
        translate([d / 2 - tube_d / 2, 0, 0])
            circle(d = tube_d);
}

module rounded_square_fan_body(size, h, corner_r) {
    linear_extrude(height = h, center = true)
        hull() {
            for (x = [-size / 2 + corner_r, size / 2 - corner_r]) {
                for (y = [-size / 2 + corner_r, size / 2 - corner_r]) {
                    translate([x, y])
                        circle(r = corner_r);
                }
            }
        }
}

module fan_screw_hole_markers(h) {
    for (x = [-fan_hole_pitch / 2, fan_hole_pitch / 2]) {
        for (y = [-fan_hole_pitch / 2, fan_hole_pitch / 2]) {
            translate([x, y, 0])
                cylinder(h = h, d = fan_screw_d, center = true);
        }
    }
}
