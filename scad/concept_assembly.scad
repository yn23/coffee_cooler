include <params.scad>
use <base.scad>
use <plenum.scad>
use <top_ring.scad>
use <mock_parts.scad>

base();

translate([0, 0, base_h + 2])
    plenum();

translate([0, 0, base_h + plenum_h + 4])
    top_ring();

translate([0, 0, base_h + plenum_h + top_ring_h + 6])
    mock_sieve();

// The real fan mounts under the top fan plate, inside the exhaust chamber.
translate([0, 0, base_h - fan_plate_thickness - fan_thickness])
    mock_fan();

mock_electronics();
