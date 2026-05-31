include <params.scad>
use <base.scad>
use <plenum.scad>
use <top_ring.scad>

base();

translate([0, 0, base_h + 2])
    plenum();

translate([0, 0, base_h + plenum_h + 4])
    top_ring();
