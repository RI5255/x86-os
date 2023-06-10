; memcmp(char *s1, char *s2, short n);
; cmpsbはdiとsiにある1バイトを比較してDFの値に応じてそれぞれを加減算する。一致したらZF=1になる。
; repe(repeat if equal)はcx-1!=0か、ZF!=0のときリピートする。

memcmp:
    cld
    repe cmpsb
    jnz .L0
    mov ax, 1
    ret

.L0:
    mov ax, -1
    ret
