// ==========================================
// Coffee Cooler Parameters / コーヒークーラー共通パラメータ
// ==========================================

// --- Global Settings / 全体設定 ---
$fn = 96;           // Rendering resolution / 円や曲面の分割数
wall = 3;           // Standard wall thickness / 標準の壁厚
clearance = 0.4;    // General mechanical clearance / 嵌合や穴用の基本クリアランス

// --- Main Body Sections / 本体の主要寸法 ---
body_outer_d = 176;  // Outer diameter of the main cylindrical body / 本体円筒部の外径
top_ring_h = 35;     // Height of the top ring that holds the sieve / ザル受け上部リングの高さ
base_h = 80;         // Height of the base section (housing the fan) / ファンを収めるベース部の高さ

// --- Sieve (Top Section) / ザル受け ---
// Parameters for the coffee sieve/filter / コーヒー用うらごしザルの寸法
sieve_ring_outer_d = 156;                 // ザル付属金属リングの外径
sieve_ring_seat_d = sieve_ring_outer_d + 0.8;  // top_ring側のザル受けポケット径
sieve_ring_seat_depth = 20;               // ザル受けポケットの深さ
sieve_opening_d = 148;                    // top_ring中央の吸気開口径

// --- Fan & Mount / 120mmファンと固定部 ---
// Standard 120mm fan parameters / 一般的な120mm PCファン寸法
fan_size = 120;              // ファン外形サイズ
fan_clearance = 1.0;         // ファン外形まわりの逃げ
fan_cutout_d = 113;          // ファン開口径
fan_hole_pitch = 105;        // ファン固定穴ピッチ
fan_screw_d = 4.5;           // ファン固定ネジの通し穴径
fan_thickness = 25;          // ファン厚み
fan_plate_thickness = 4;     // ファン取付プレートの厚み
fan_seal_lip_h = 2;          // ファン開口まわりのシールリップ高さ
fan_seal_lip_w = 7;          // ファン開口まわりのシールリップ幅

// --- Ventilation Holes / 側面排気丸穴 ---
// Air exhaust holes on the base / ベース側面の排気穴寸法
vent_hole_d = 10;       // Diameter of circular exhaust holes / 排気丸穴の直径
vent_row_pitch = vent_hole_d + 8;  // Row pitch of exhaust holes / 排気丸穴の段間ピッチ
vent_rows = 4;          // Number of rows / 排気丸穴の段数
vent_count = 8;         // Number of columns around circumference / 円周方向の排気列数
vent_center_z = base_h / 2;  // Center height of exhaust holes / 排気丸穴群の中心高さ

// --- Electronics Bay / 電装室 ---
// Internal space for PWM controller and DC barrel jack. / PWMコントローラとDC電源ジャックの収納部
electronics_box_d = 32;  // 電装室の奥行き
electronics_box_w = 80;  // 電装室の幅
electronics_box_h = 45;  // 電装室の高さ
