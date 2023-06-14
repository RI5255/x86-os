; short KBC_Data_Write(int8_t *data);
KBC_Data_Write:
    push bp 
    mov bp, sp 
    mov cx, 0       ; 最大リトライ回数
.L0:
    in al, 0x64     ; KBCのステータスレジスタを読む
    test al, 0x2    ; 結果が0x2なら書き込み不可(入力バッファのデータをKBCがまだ読み出していない)
    loopnz .L0      ; cx!=0かつ上の結果が0でないなら.L0に飛ぶ
    cmp cx, 0
    jz .L1
    mov al, [bp + 4]
    out 0x60, al 
.L1:
    mov ax, cx      ; cxが0以外であれば書き込みが行われている
    mov sp, bp 
    pop bp
    ret

; short KBC_Data_Read(short *data);
KBC_Data_Read:
    push bp 
    mov bp, sp 
    push di
    mov di, [bp + 4]
    mov cx, 0 
.L0:
    in al, 0x64     ; KBCのステータスレジスタを読む
    test al, 0x1    ; 結果が0x1ならデータがある
    loopz .L0       ; cx!=0かつ上の結果が0なら.L0に飛ぶ
    cmp cx, 0
    jz .L1
    mov ah, 0
    in al, 0x60
    mov [di], ax 
.L1:
    mov ax, cx
    pop di 
    mov sp, bp 
    pop bp 
    ret 

; short KBC_Cmd_Write(int8_t cmd);
KBC_Cmd_Write:
    push bp 
    mov bp, sp 
    mov cx, 0       ; 最大リトライ回数
.L0:
    in al, 0x64     ; KBCのステータスレジスタを読む
    test al, 0x2    ; 結果が0x2なら書き込み不可(入力バッファのデータをKBCがまだ読み出していない)
    loopnz .L0      ; cx!=0かつ上の結果が0でないなら.L0に飛ぶ
    cmp cx, 0
    jz .L1
    mov al, [bp + 4]
    out 0x64, al    ; コマンドはポート0x64に書き込む
.L1:
    mov ax, cx      ; cxが0以外であれば書き込みが行われている
    mov sp, bp 
    pop bp
    ret




