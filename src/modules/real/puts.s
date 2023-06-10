; void puts(char *s)
; lodsb命令はsiレジスタで指定されたアドレスから1bye読んでalにセットし、DFに応じてsiを加減算する。

puts:
    push bp 
    mov bp, sp 
    push bx
    mov si, [bp + 4]
    mov ah, 0x0E        ; int 0x10(ah=0x0E)はテレタイプ式の文字列出力。
    mov bh, 0           ; ページ番号
    mov bl, 0           ; 文字色(グラフィックスモードの時のみ有効)
    cld                 ; DF=0

.loop:
    lodsb              ; al = *si++
    cmp al, 0
    je .end
    int 0x10
    jmp .loop

.end:
    pop bx 
    mov sp, bp 
    pop bp 
    ret
