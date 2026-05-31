# Coffee Cooler

焙煎したコーヒー豆を短時間で冷却するための、3Dプリント製コーヒークーラー設計プロジェクトです。

## Goal

- 15cmステンレスうらごしを豆受けとして使う
- 120mm PWMファンで下吸引する
- DC電源ジャックから12V給電する
- PWMコントローラで風量調整する
- 側面排気と整流空間で空気を均一に流す
- PETGで印刷しやすく、分解掃除しやすい構造にする
- OpenSCADで設計し、STL化しやすい構成にする

## Project Structure

```text
coffee_cooler/
├── specific.md
├── README.md
├── docs/
│   ├── design.md
│   ├── parts.md
│   ├── wiring.md
│   └── print-settings.md
├── measurements/
│   └── sieve_15cm.md
├── scad/
│   ├── coffee_cooler.scad
│   ├── params.scad
│   ├── top_ring.scad
│   ├── gasket.scad
│   ├── plenum.scad
│   ├── base.scad
│   ├── fan_mount.scad
│   ├── vents.scad
│   ├── electronics_mount.scad
│   ├── mock_parts.scad
│   ├── concept_assembly.scad
│   └── print_split.scad
├── stl/
│   └── .gitkeep
├── exports/
│   ├── measurements/
│   └── images/
│       └── .gitkeep
└── scripts/
    ├── build_measurements.py
    └── build_stl.sh
```

## Design Direction

本体は一体型ではなく、次の3分割を基本にします。

- `top_ring`: 15cmうらごしを固定する上部リング
- `gasket`: ザル付属リングとtop_ringの間に置くTPU製ガスケット
- `plenum`: ザル直下の整流チャンバー
- `base`: 120mmファン、側面排気、電装部を持つ下部筐体
- `concept_assembly`: ザル、ファン、基板、PWMノブ類の仮形状を重ねた確認用モデル
- `print_split`: 大径化や試験用の4分割出力モデル

15cmザルと120mmファンの構成では、A1 miniで分割なし出力を基本にします。

## Main Parts

| Part | Purpose |
| ---- | ------- |
| パール金属 EEスイーツ ステンレス製 うらごし 15cm D-4730 | 豆受け |
| beyourchoi PWMコントローラ | ファン速度調整、電源ON/OFF |
| DC電源ジャック ソケット 5.5mm x 2.1mm | 12V給電 |
| 120mm PWMファン | 冷却ファン |
| 3Dプリント本体 | 部品固定、整流、排気 |

詳細は [specific.md](specific.md) と [docs/parts.md](docs/parts.md) を参照します。

## Build Flow

1. [measurements/sieve_15cm.md](measurements/sieve_15cm.md) にザルの実測値を記録する
2. [scad/params.scad](scad/params.scad) の寸法を調整する
3. [scad/top_ring.scad](scad/top_ring.scad) でザル固定リングを試作する
4. [scad/base.scad](scad/base.scad) でファン固定穴と排気口を検証する
5. [scad/plenum.scad](scad/plenum.scad) で整流空間を調整する
6. [scad/coffee_cooler.scad](scad/coffee_cooler.scad) で全体の干渉を確認する
7. `scripts/build_stl.sh` でSTLを書き出す
8. `scripts/build_measurements.py` でSTLごとの計測図SVGを書き出す

## STL Export

OpenSCAD CLIが使える環境では、以下でSTLを書き出します。

画面あり:

```bash
./scripts/build_stl.sh
```

画面なし:

```bash
QT_QPA_PLATFORM=offscreen ./scripts/build_stl.sh
```

出力先は `stl/` です。

## Measurement Sheets

`stl/` 直下にある各STLから、対応する計測図SVGを `exports/measurements/` に出力します。

```bash
python3 ./scripts/build_measurements.py
```

出力例:

```text
exports/measurements/top_ring.svg
exports/measurements/base.svg
```

## Google Drive Sync

WindowsのBambu Studioで開きやすいように、Google Drive配下へ同期できます。

画面あり:

```bash
./scripts/sync_to_gdrive.sh
```

画面なし:

```bash
QT_QPA_PLATFORM=offscreen ./scripts/sync_to_gdrive.sh
```

同期先の既定値:

```text
- Google Driveのパス例: `~/GoogleDrive/10.project/coffee_cooler` (環境に合わせて設定)
```

別の同期先を使う場合:

```bash
COFFEE_COOLER_GDRIVE_DIR=/path/to/coffee_cooler ./scripts/sync_to_gdrive.sh
```

そのまま貼って使える例:

```bash
COFFEE_COOLER_GDRIVE_DIR="/path/to/your/gdrive/coffee_cooler" ./scripts/sync_to_gdrive.sh
```

## Notes

- PETG想定のため、熱い豆が樹脂に直接触れる面積を減らす設計にします。
- 15cmザルは外径163mm、高さ55mmを初期値にしています。底面メッシュ径、縁形状は追加で実測します。
- DC電源アダプタが12V出力に対応していることを確認します。
- 電装室は豆、チャフ、微粉の流路から分離します。
