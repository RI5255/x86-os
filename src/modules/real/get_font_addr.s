; void get_font_addr(uint32_t *addr);
; bhにフォントタイプを設定してint 0x10(ax=0x1130)でフォントアドレスを取得することができる。
; es:bpにフォントのアドレス、

get_font_addr:
    push bp 
    mov bp, sp 
    push bx
    push bp
    mov di, [bp + 4]
    mov ax, 0x1130
    mov bh, 0x6         ; フォントタイプ(8x16 font)
    int 0x10
    mov [di], es        ; セグメント
    mov [di + 2], bp    ; オフセット
    pop bp
    pop bx
    mov sp, bp 
    pop bp 
    ret