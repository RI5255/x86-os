; memcpy(char *dst, char *src, short n);
; rep命令はcx-1==0になるまで命令を繰り返す。。
; movsb命令はsiからdiへ1byteコピーしてDFの値に応じてそれぞれを加減算する。

memcpy:
    cld
    rep movsb
    ret
