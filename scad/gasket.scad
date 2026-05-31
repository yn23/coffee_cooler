include <params.scad>

module gasket() {
    difference() {
        cylinder(h = gasket_h, d = gasket_outer_d);

        translate([0, 0, -0.1])
            cylinder(h = gasket_h + 0.2, d = gasket_inner_d);

    }
}

gasket();
