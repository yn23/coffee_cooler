include <params.scad>
use <fan_mount.scad>
use <vents.scad>
use <electronics_mount.scad>

// ファン室の内側をくり抜く切り欠き。
// ここではベース円筒の内部空間だけを取り除く。
module exhaust_chamber_cutout() {
    chamber_h = base_h - fan_plate_thickness + 1.2;
    translate([0, 0, -0.6 + chamber_h / 2])
        cylinder(h = chamber_h, d = body_outer_d - wall * 2, center = true);
}

// ファン取付プレートに開ける開口とネジ穴。
module fan_plate_cutouts() {
    translate([0, 0, base_h - fan_plate_thickness / 2])
        fan_cutout(fan_plate_thickness + 2);

    translate([0, 0, base_h - fan_plate_thickness / 2])
        fan_screw_holes(fan_plate_thickness + 2);
}

// ファン開口まわりのシール用リップ。
module fan_seal_lip() {
    translate([0, 0, base_h - fan_plate_thickness - fan_seal_lip_h])
        difference() {
            cylinder(h = fan_seal_lip_h, d = fan_cutout_d + fan_seal_lip_w * 2);
            translate([0, 0, -0.1])
                cylinder(h = fan_seal_lip_h + 0.2, d = fan_cutout_d);
        }
}

// 電装箱が円柱本体に食い込む部分を先に抜いておく。
// これを入れないと、箱の接続部に円柱の壁が残ってしまう。
module electronics_box_cutout() {
    translate([body_outer_d / 2 - electronics_box_d / 2, 0, electronics_box_h / 2])
        cube([
            // electronics_box_d + clearance * 2,
            // electronics_box_w + clearance * 2,
            // electronics_box_h + clearance * 2
            electronics_box_d,
            electronics_box_w,
            electronics_box_h - 2
        ], center = true);
}

// ベース本体。
// 円柱本体を土台にして、電装箱を張り出しとして追加する。
module base() {
    union() {
        difference() {
            cylinder(h = base_h, d = body_outer_d);

            exhaust_chamber_cutout();
            fan_plate_cutouts();
            side_vents();
            electronics_box_cutout();
        }

        electronics_box();
        fan_seal_lip();
    }
}

base();
