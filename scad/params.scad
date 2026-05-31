// ==========================================
// Coffee Cooler Parameters / コーヒークーラー共通パラメータ
// ==========================================

// --- Global Settings / 全体設定 ---
$fn = 96;           // Rendering resolution / 円や曲面の分割数
wall = 3;           // Standard wall thickness / 標準の壁厚
clearance = 0.4;    // General mechanical clearance / 嵌合や穴用の基本クリアランス

// --- Main Body Sections / 本体の主要寸法 ---
body_outer_d = 165;  // Outer diameter of the main cylindrical body / 本体円筒部の外径
top_ring_h = 20;     // Height of the top ring that holds the sieve / ザル受け上部リングの高さ
plenum_h = 45;       // Height of the air plenum section / ザル下の整流空間の高さ
base_h = 80;         // Height of the base section (housing the fan) / ファンを収めるベース部の高さ

// --- Sieve & Gasket (Top Section) / ザルとガスケット ---
// Parameters for the coffee sieve/filter / コーヒー用うらごしザルの寸法
sieve_ring_outer_d = 156;                 // ザル付属金属リングの外径
sieve_outer_d = sieve_ring_outer_d;       // mock表示用のザル外径。実寸基準はsieve_ring_outer_d
sieve_h = 55;                             // ザル全体の高さ
sieve_ring_seat_d = sieve_ring_outer_d + 0.8;  // top_ring側のザル受けポケット径
sieve_ring_seat_depth = 10;               // ザル受けポケットの深さ
sieve_opening_d = 148;                    // top_ring中央の吸気開口径
sieve_loop_relief_w = 30;                 // 未使用: ザル横リング逃げの幅
sieve_loop_relief_d = 7;                  // 未使用: ザル横リング逃げの奥行き
sieve_loop_relief_h = 12;                 // 未使用: ザル横リング逃げの高さ
sieve_seat_d = sieve_ring_seat_d;         // 互換用: ザル受け径
sieve_lip_h = sieve_ring_seat_depth;      // 互換用: ザル受けリップ高さ

// Gasket parameters (intended for TPU printing) / TPUガスケット寸法
gasket_outer_d = sieve_ring_seat_d - 0.4;  // TPUガスケットの外径
gasket_inner_d = sieve_opening_d + 1.0;    // TPUガスケットの内径
gasket_h = 1.2;                            // TPUガスケットの厚み
gasket_loop_relief_w = sieve_loop_relief_w + 2;  // 未使用: 旧切り欠き用の幅
gasket_loop_relief_d = sieve_loop_relief_d + 1;  // 未使用: 旧切り欠き用の奥行き

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

// --- Ventilation Slots / 側面排気スリット ---
// Air exhaust slots on the base / ベース側面の排気口寸法
vent_slot_w = 34;       // 排気スリットの横幅
vent_slot_h = 9;        // 排気スリットの高さ
vent_row_pitch = vent_slot_h + 6;  // 排気スリットの段間ピッチ
vent_rows = 4;          // 排気スリットの段数
vent_count = 8;         // 円周方向の排気スリット数
vent_center_z = base_h / 2;  // 排気スリット群の中心高さ

// --- Electronics Bay / 電装室 ---
// Internal space for PWM controller and DC barrel jack. / PWMコントローラとDC電源ジャックの収納部
electronics_box_d = 32;  // 電装室の奥行き
electronics_box_w = 80;  // 電装室の幅
electronics_box_h = 45;  // 電装室の高さ
