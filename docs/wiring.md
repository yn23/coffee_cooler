# Wiring

## Basic Connection

```text
12V DC power source
  -> DC barrel jack socket
  -> PWM controller
  -> 120mm PWM fan
```

## Notes

- 電源アダプタ側が12V出力に対応していることを確認する
- DCジャックは 5.5 x 2.1mm 規格を前提にする
- PWMコントローラ側のON/OFF機能を使用する
- PWMコントローラの仕様を確認し、4ピンPWM制御かDC電圧制御かを記録する
- 電装部は豆、チャフ、微粉の流路から分離する
- メンテナンスのため、ファン周辺の配線には余長を持たせる
