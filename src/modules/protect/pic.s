init_pic:
    ; マスタPICの設定
    outp 0x20, 0x11     ; ICW1
    outp 0x21, 0x20     ; ICW2
    outp 0x21, 0x04     ; ICW3
    outp 0x21, 0x01     ; ICW4
    outp 0x21, 0xff     ; OCW1

    ; スレーブPICの設定
    outp 0xa0, 0x11     ; ICW1
    outp 0xa1, 0x28     ; ICW2
    outp 0xa1, 0x02     ; ICW3
    outp 0xa1, 0x01     ; ICW4
    outp 0xa1, 0xff     ; OCW1 

    ret