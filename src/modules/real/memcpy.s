; void memcpy(char *dst, char *src, short n);
; rep命令はcx-1==0になるまで命令を繰り返す。。
; movsb命令はsiからdiへ1byteコピーしてDFの値に応じてそれぞれを加減算する。

memcpy:
    push bp 
    mov bp, sp
    mov di, [bp + 4]
    mov si, [bp + 6]
    mov cx, [bp + 8]
    cld
    rep movsb
    mov sp, bp
    pop bp
    ret
