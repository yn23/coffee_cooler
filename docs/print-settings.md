# Print Settings

## Material

- PETG
- TPU for `gasket_tpu.stl`

## Printer

- Bambu Lab A1 mini
- Build volume: 180 x 180 x 180mm
- 現在の本体外径は178mmのため、一体出力を基本にする
- 造形範囲に対して余裕が小さいため、スライサー上でスカート/ブリム設定に注意する

## Initial Settings

- Layer height: 0.20mm
- Wall line count: 3以上
- Top/bottom layers: 4以上
- Infill: 20%から30%
- Nozzle: 0.4mm想定

## Design Allowances

- 一般的な嵌合クリアランス: 0.3mmから0.5mm
- ネジの通し穴: 呼び径 + 0.3mmから0.6mm
- 熱や荷重がかかるリング部は厚めにする

## Orientation

- `top_ring`: ザル接触面を上にして印刷
- `gasket_tpu`: TPUで低速印刷し、交換式にする
- `plenum`: チャンバー開口を上にして印刷
- `base`: ファン固定面と排気スリットのサポート量を見て向きを決める

## Split Parts

15cm版では分割なしSTLを基本にします。分割STLと分割計測図は通常出力しません。
