; int memcmp(char *s1, char *s2, short n);
; cmpsbはdiとsiにある1バイトを比較してDFの値に応じてそれぞれを加減算する。一致したらZF=1になる。
; repe(repeat if equal)はcx-1!=0かつZF==1のときリピートする。

memcmp:
    push bp
    mov bp, sp
    push di 
    push si 
    mov di, [bp + 4]
    mov si, [bp + 6]
    mov cx, [bp + 8]
    cld
    repe cmpsb
    jnz .LF
    mov ax, 0
    jmp .LE

.LF:
    mov ax, -1

.LE:    
    pop si 
    pop di
    mov sp, bp 
    pop bp 
    ret
