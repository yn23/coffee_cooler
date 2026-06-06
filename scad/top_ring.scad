include <params.scad>

module top_ring() {
    difference() {
        cylinder(h = top_ring_h, d = body_outer_d);

        // Main airflow opening. The metal sieve ring sits on the remaining ledge.
        translate([0, 0, -1])
            cylinder(h = top_ring_h + 2, d = sieve_opening_d);

        // Shallow upper pocket for the sieve's attached metal outer ring.
        translate([0, 0, top_ring_h - sieve_ring_seat_depth])
            cylinder(h = sieve_ring_seat_depth + 1, d = sieve_ring_seat_d);

        // Shallow upper pocket for the sieve's attached metal outer ring.
        translate([0, 0, 0])
            cylinder(h = 5, d = sieve_ring_seat_d);
    }
}

top_ring();
