entry:
    jmp ipl

    times 90 - ($ - $$) db 0x90 ; BPB(Boot Parameter Block)

; IPL(Initial Program Loader)
    BOOT_LOAD   equ 0x7C00
    ORG BOOT_LOAD
ipl:
    cli                     ; 割り込みを禁止
    mov ax, 0x0000
    mov ds, ax
    mov es, ax 
    mov ss, ax
    mov sp, BOOT_LOAD
    sti                     ; 割り込みを有効化
    mov [BOOT.DRIVE], dl    ; ブートドライブを保存
    mov ah, 0x0E            ; int 0x10(ah=0x0E)はテレタイプ式の文字列出力。
    mov al, 'A'             ; 出力文字
    mov bh, 0               ; ページ番号
    mov bl, 0               ; 文字色(グラフィックスモードの時のみ有効)
    int 0x10
    jmp $                   ; 無限ループ

ALIGN 2, db 0               ; 0x90の代わりに0x00で埋める。
BOOT:
    .DRIVE: dw 0

    times 510 - ($ - $$) db 0x90
    db 0x55, 0xAA


