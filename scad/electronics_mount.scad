include <params.scad>

// 電子部品を格納する箱（マウント）全体を生成するモジュール
module electronics_box() {
    translate([body_outer_d / 2 - electronics_box_d / 2, 0, electronics_box_h / 2])
        union() {
            // 外箱の直方体から、内部の空洞（キャビティ）をくり抜く
            difference() {
                cube([electronics_box_d, electronics_box_w, electronics_box_h], center = true);
                // 底面と、円筒側の壁だけを消して、反対側の壁は残す。
                translate([-wall / 2, 0, -wall / 2])
                    cube([
                        electronics_box_d + wall,
                        electronics_box_w - wall * 2,
                        electronics_box_h + wall
                    ], center = true);
            }
            electronics_pcb_mount_local();
        }
}

module electronics_pcb_mount_local() {
    // Parameters（各種サイズ設定）
    // test2.scad の構成をベースに、電装室内へ収まる寸法に調整する。
    table_width = 32;      // テーブルの幅 (X軸方向)
    table_depth = electronics_box_w - (wall * 2);      // テーブルの奥行き (Y軸方向)
    table_height = 5.5;    // テーブル全体の高さ (Z軸方向)
    pcb_width = table_width;       // 基盤の幅 (X軸方向)
    pcb_depth = 32;                // 基盤の奥行き (Y軸方向)
    leg_size = 6;                  // 脚の太さ (X, Y軸方向)
    top_thickness = 2;             // 天板の厚み (Z軸方向)
    wall_thickness = 3;            // 壁の厚み
    wall_height = electronics_box_h;              // 壁の高さ (Z軸方向)
    pcb_y_offset = table_depth - pcb_depth;

    // Legs（脚のモジュール定義）
    module leg() {
        cube([leg_size, leg_size, table_height - top_thickness]);
    }

    // test2.scad のレイアウトを、箱の中心に収まるように寄せる。
    // 底面に直接置く。wall 分だけ持ち上げていた高さオフセットを外す。
    translate([-table_width / 2, -table_depth / 2, -electronics_box_h / 2]) {
        // Table Top（天板の描画）
        difference() {
            cube([pcb_width, table_depth, top_thickness]);
        }

        // Position the four legs（4本の脚を四隅に配置）
        translate([0, table_depth - (pcb_width), top_thickness]) leg();
        translate([pcb_width - leg_size, table_depth - (pcb_width), top_thickness]) leg();
        translate([0, table_depth - leg_size, top_thickness]) leg();
        translate([pcb_width - leg_size, table_depth - leg_size, top_thickness]) leg();

        // Left Wall（左の壁）
        translate([table_width, -wall_thickness, 0])
            difference() {
                difference() {
                    hole_depth = 7.6;       // 壁に開ける穴の奥行き (Y軸方向)
                    hole_height = 10.5;      // 壁に開ける穴の高さ (Z軸方向)
                    cube([wall_thickness, table_depth + (wall_thickness * 2), wall_height]);
                    move_depth = 13.4 + wall_thickness; // 穴の位置を壁からどれだけ離すか
                    translate([-0.1, table_depth - move_depth, table_height + 1.0])
                        cube([wall_thickness + 0.2, hole_depth, hole_height]);
                }
                x = 0;
                y = 20;
                z = 14;
                r = 4.6;
                translate([x, y, z])
                    sphere(r);
        }

        // Back Wall（奥の壁）
        translate([-wall_thickness, table_depth, 0])
            cube([table_width + wall_thickness, wall_thickness, wall_height]);

        // Front Wall（手前の壁）
        translate([-wall_thickness, -wall_thickness, 0])
            cube([table_width + wall_thickness, wall_thickness, wall_height]);
    }
}
