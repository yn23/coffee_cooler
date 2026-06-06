include <params.scad>

// ==========================================
// 電装ボックス（別部品モデル）の定義
// ==========================================

// --- 電装ボックスの外殻モジュール ---
module electronics_box() {
    // ベースシリンダーの半径位置（X方向）および高さ方向（Z方向）へ配置を合わせるための並進
    translate([body_outer_d / 2 - electronics_box_d / 2, 0, electronics_box_h / 2])
        union() {
            // ボックスの外殻の差分（中空の箱を作成）
            difference() {
                // ボックス外枠
                cube([electronics_box_d, electronics_box_w, electronics_box_h], center = true);
                
                // 内部空間のくり抜き（壁厚を残す）
                translate([-wall / 2, 0, -wall / 2])
                    cube([
                        electronics_box_d + wall,
                        electronics_box_w - wall * 2,
                        electronics_box_h + wall
                    ], center = true);
            }
            // 内部のPCB（制御基板）固定用マウントと前面パネル
            electronics_pcb_mount_local();
        }
}

// --- ボックス内部の基板マウントおよび前面操作パネルモジュール ---
module electronics_pcb_mount_local() {
    table_width = 32;                               // マウント台の幅
    table_depth = electronics_box_w - (wall * 2);   // マウント台の奥行き（内寸に合わせる）
    table_height = 5.5;                             // 基板脚の高さ
    pcb_width = table_width;                        // 基板の幅
    pcb_depth = 32;                                 // 基板の奥行き（32mm四方を想定）
    leg_size = 6;                                   // 固定用の脚（支柱）のサイズ
    top_thickness = 2;                              // マウントプレートの厚み
    wall_thickness = 3;                             // 外壁の厚み
    wall_height = electronics_box_h;                // 外壁の高さ（ボックス本体と共通）

    // 基板受けのスペーサー脚モジュール
    module leg() {
        cube([leg_size, leg_size, table_height - top_thickness]);
    }

    // ローカル座標の原点をボックス底面の左手前隅へ移動
    translate([-table_width / 2, -table_depth / 2, -electronics_box_h / 2]) {
        // 基板を載せるベースプレート
        difference() {
            cube([pcb_width, table_depth, top_thickness]);
        }

        // 基板固定用の4隅の脚を配置
        translate([0, table_depth - (pcb_width), top_thickness]) leg();
        translate([pcb_width - leg_size, table_depth - (pcb_width), top_thickness]) leg();
        translate([0, table_depth - leg_size, top_thickness]) leg();
        translate([pcb_width - leg_size, table_depth - leg_size, top_thickness]) leg();

        // 前面操作パネル（コントロールノブやDCジャックの端子部）と、ベースネジ止め用の耳
        translate([table_width, -wall_thickness, 0])
            difference() {
                difference() {
                    hole_depth = 7.6;
                    hole_height = 10.5;
                    
                    // 前面プレート。左右に8mmずつ（合計16mm）幅を拡張してベースへの固定用「耳（フランジ）」を作る
                    translate([0, -8, 0])
                        cube([wall_thickness, table_depth + (wall_thickness * 2) + 16, wall_height]);
                    
                    // PWMコントローラー等の配線・接続用の角穴
                    move_depth = 13.4 + wall_thickness;
                    translate([-0.1, table_depth - move_depth, table_height + 1.0])
                        cube([wall_thickness + 0.2, hole_depth, hole_height]);
                }
                // DCジャック取り付け用の球体カットアウト
                x = 0;
                y = 20;
                z = 14;
                r = 4.6;
                translate([x, y, z])
                    sphere(r);
                
                // 左右の耳に設けるネジ通し穴（M3ネジ用：直径3.2mm）
                // 座標は前面プレート ([table_width, -wall_thickness, 0]) からの相対座標
                for (y_val = [-4, 84]) {
                    translate([-0.1, y_val, wall_height / 2])
                        rotate([0, 90, 0])
                            cylinder(h = wall_thickness + 0.2, d = 3.2, $fn=24);
                }
        }

        // 側面の補強/位置決め壁（奥側）
        translate([-wall_thickness, table_depth, 0])
            cube([table_width + wall_thickness, wall_thickness, wall_height]);

        // 側面の補強/位置決め壁（手前側）
        translate([-wall_thickness, -wall_thickness, 0])
            cube([table_width + wall_thickness, wall_thickness, wall_height]);
    }
}

// モデルのインスタンス生成
electronics_box();
