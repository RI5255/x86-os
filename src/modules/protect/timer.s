int_en_timer0:
    ; 制御ワードを設定
    outp 0x43, 0b_00_11_010_0

    ; カウンタを設定
    outp 0x40, 0x9c
    outp 0x40, 0x2e 

    ret