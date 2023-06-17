    %include "./include/define.s"
    %include "./include/macro.s"

    ORG KERNEL_LOAD 
[BITS 32]
kernel:
    ; フォントアドレスを取得
    mov esi, BOOT_LOAD + SECT_SIZE
    movzx eax, word [esi]               ; セグメント
    shl eax, 4
    movzx ebx, word [esi + 2]           ; オフセット　
    add eax, ebx
    mov [FONT_ADDR], eax                ; フォントのアドレスを保存

    ; 8bitの横線
    mov ah, 0x7                         ; RGB 
    mov al, 0x02                        ; 書き込みプレーン選択レジスタ
    mov dx, 0x03c4                      ; シーケンサ制御ポート
    out dx, ax
    mov [0xA_0000], byte 0xff 
    mov ah, 0x4                         ; R
    out dx, ax         
    mov [0xA_0000 + 1], byte 0xff 
    mov ah, 0x2                         ; G 
    out dx, ax         
    mov [0xA_0000 + 2], byte 0xff 
    mov ah, 0x1                         ; B
    out dx, ax         
    mov [0xA_0000 + 3], byte 0xff 

    ; 画面を横切る横線
    mov ah, 0x2                         ; G 
    out dx, ax 
    lea edi, [0xA_0000 + 80]
    mov ecx, 80 
    mov al, 0xff 
    rep stosb                           ; while(--ecx) *edi = al

    ; 8 dotの短形
    mov edi, 1
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000] ; VRAMアドレス
    mov		[edi + (80 * 0)], word 0xFF
    mov		[edi + (80 * 1)], word 0xFF
    mov		[edi + (80 * 2)], word 0xFF
    mov		[edi + (80 * 3)], word 0xFF
    mov		[edi + (80 * 4)], word 0xFF
    mov		[edi + (80 * 5)], word 0xFF
    mov		[edi + (80 * 6)], word 0xFF
    mov		[edi + (80 * 7)], word 0xFF

    ; fontを表示
    mov esi, 'A'
    shl esi, 4                          ; 文字データは16バイト
    add esi, [FONT_ADDR]

    mov edi, 2 
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000]

    mov ecx, 16                         ; 文字の高さ

.L0:
    movsb                               ; *edi++ = *esi++ (1byteずつコピーする)
    add edi, 80 - 1
    loop .L0 

    ; 処理の終わり
    jmp $

ALIGN 4, db 0
FONT_ADDR:  dd 0

    ; padding
    times KERNEL_SIZE - ($ -$$) db 0
    