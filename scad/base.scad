include <params.scad>

// ==========================================
// 他ファイルから統合されたサブモジュール
// ==========================================

// --- ファンマウント関連 (旧 fan_mount.scad) ---

// 120mmファン固定用の4箇所のねじ穴を生成するモジュール
module fan_screw_holes(h = 10) {
    for (x = [-fan_hole_pitch / 2, fan_hole_pitch / 2]) {
        for (y = [-fan_hole_pitch / 2, fan_hole_pitch / 2]) {
            translate([x, y, 0])
                cylinder(h = h, d = fan_screw_d, center = true);
        }
    }
}

// 120mmファンの吸排気用の中心開口部（大穴）を生成するモジュール
module fan_cutout(h = 10) {
    cylinder(h = h, d = fan_cutout_d, center = true);
}

// --- 側面排気スリット関連 (旧 vents.scad) ---

// ベース側面に熱風を逃がすための排気用横スリット群を生成するモジュール
module side_vents(radius = body_outer_d / 2, center_z = vent_center_z) {
    for (i = [0 : vent_count - 1]) {
        // 円周方向にスリットを回転配置
        rotate([0, 0, i * 360 / vent_count])
            translate([radius, 0, center_z])
                for (row = [0 : vent_rows - 1]) {
                    // 各列に複数段のスリットを配置
                    translate([0, 0, (row - (vent_rows - 1) / 2) * vent_row_pitch])
                        cube([wall * 4, vent_slot_w, vent_slot_h], center = true);
                }
    }
}

// --- 電装ボックス固定関連 (旧 electronics_mount.scad) ---

// 電装ボックスを前面からネジ止めするための、ベースシリンダー側のボス（肉盛り部）
module base_screw_bosses() {
    for (y_sign = [-1, 1]) {
        // 電装室開口の左右（Y軸方向）に固定用の肉盛りブロックを配置
        translate([80, y_sign * 44, electronics_box_h / 2])
            cube([16, 8, electronics_box_h], center = true);
    }
}

// 電装ボックス固定用のネジ下穴（M3セルフタップネジ用：直径2.5mm）をボスに通すモジュール
module base_screw_holes() {
    for (y_sign = [-1, 1]) {
        // 前面からX軸方向にネジを通すため、90度回転させて穴をあける
        translate([80, y_sign * 44, electronics_box_h / 2])
            rotate([0, 90, 0])
                cylinder(h = 20, d = 2.5, center = true, $fn=24);
    }
}

// 電装ボックスが入るポケットの「屋根（天井板）」
module electronics_pocket_roof() {
    // 逆さ印刷（倒立印刷）の際にブリッジとしてサポートなしで印刷可能な水平の天井板
    translate([
        body_outer_d / 2 - (electronics_box_d) / 2,
        -1 * ((electronics_box_w + (wall + 1) * 4) / 2),
        // (electronics_box_h + clearance) + wall / 2
        electronics_box_h
    ])
        cube([
            electronics_box_d / 2,
            electronics_box_w + ((wall + 1) * 4),
            wall
        ]);
}

// ==========================================
// ベース筐体の実装
// ==========================================

// ベースシリンダーの内部（排気チャンバー）を中空にするためのくり抜き用円筒
module exhaust_chamber_cutout() {
    // ファンプレートの厚みを残し、底面（Z=0付近）からファンプレート直下までを中空化
    chamber_h = base_h - fan_plate_thickness + 1.2;
    translate([0, 0, -0.6 + chamber_h / 2])
        cylinder(h = chamber_h, d = body_outer_d - wall * 2, center = true);
}

// 上部のファン固定プレートにファン用の穴とネジ用貫通穴をあけるモジュール
module fan_plate_cutouts() {
    // 中央のファン開口
    translate([0, 0, base_h - fan_plate_thickness / 2])
        fan_cutout(fan_plate_thickness + 2);

    // 4隅のネジ穴
    translate([0, 0, base_h - fan_plate_thickness / 2])
        fan_screw_holes(fan_plate_thickness + 2);
}

// ファンの周りの隙間から風が逆流・漏洩するのを防ぐための突起リップ（シール用）
module fan_seal_lip() {
    translate([0, 0, base_h - fan_plate_thickness - fan_seal_lip_h])
        difference() {
            // シールリップ外形
            cylinder(h = fan_seal_lip_h, d = fan_cutout_d + fan_seal_lip_w * 2);
            // 内径側を抜く
            translate([0, 0, -0.1])
                cylinder(h = fan_seal_lip_h + 0.2, d = fan_cutout_d);
        }
}

// 電装ボックスをスライドインさせるためのポケット開口（クリアランス付き）
module electronics_box_cutout() {
    // ボックス外寸に対してクリアランス (clearance=0.4) を加え、スムーズに抜き差しできるようにする
    translate([body_outer_d / 2 - electronics_box_d / 2, 0, (electronics_box_h + clearance) / 2 - 0.5])
        cube([
            electronics_box_d + clearance * 2,
            electronics_box_w + clearance * 2,
            // electronics_box_h + clearance + 1 // 底面をきれいに抜くためにZ方向を少し余分に確保
            electronics_box_h + clearance 
        ], center = true);
}

// ベース下部筐体のメインアセンブリ
module base() {
    union() {
        // --- 外殻（シリンダー本体）の差分処理 ---
        difference() {
            // ベースの外周円筒
            cylinder(h = base_h, d = body_outer_d);

            exhaust_chamber_cutout();   // 内部の排気室中空化
            fan_plate_cutouts();        // ファンプレートの穴あけ
            side_vents();               // 側面排気スリット
            electronics_box_cutout();   // 電装ボックス用開口部（スリット部分が残るのを防止）
        }

        // --- 電装ボックス受け（屋根板 ＆ ネジ止め用ボス）の配置 ---
        difference() {
            union() {
                electronics_pocket_roof();  // ポケットの天井板
                base_screw_bosses();        // 左右のネジ固定用ボス
            }
            electronics_box_cutout();       // ボスと天井板の内面をポケット形状にくり抜く
            base_screw_holes();             // ネジ固定用の下穴をボスにあける
        }

        fan_seal_lip(); // ファンシールの追加
    }
}

// モデルのインスタンス生成
base();
