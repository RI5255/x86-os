; void putc(char c);

putc:
    push bp 
    mov bp, sp
    push bx             ; bxはcallee saved register
    mov ah, 0x0E        ; int 0x10(ah=0x0E)はテレタイプ式の文字列出力。
    mov al, [bp + 4]    ; 文字コード
    mov bh, 0           ; ページ番号
    mov bl, 0           ; 文字色(グラフィックスモードの時のみ有効)
    int 0x10
    pop bx
    mov sp, bp 
    pop bp
    ret