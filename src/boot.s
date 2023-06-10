    BOOT_LOAD   equ 0x7C00
    ORG BOOT_LOAD

%include "./include/macro.s"

entry:
    jmp ipl

    times 90 - ($ - $$) db 0x90 ; BPB(Boot Parameter Block)

; IPL(Initial Program Loader)
ipl:
    cli                     ; 割り込みを禁止
    mov ax, 0x0000
    mov ds, ax
    mov es, ax 
    mov ss, ax
    mov sp, BOOT_LOAD
    sti                     ; 割り込みを有効化
    mov [BOOT.DRIVE], dl    ; ブートドライブを保存
    cdecl puts, .s0       
    
    cdecl itoa, 8086, .s1, 8, 10, 0b0001
    cdecl puts, .s1

    cdecl itoa, 8086, .s1, 8, 10, 0b0011
    cdecl puts, .s1

    cdecl itoa, -8086, .s1, 8, 10, 0b0001
    cdecl puts, .s1

    cdecl itoa, -1, .s1, 8, 10, 0b0001
    cdecl puts, .s1

    cdecl itoa, -1, .s1, 8, 10, 0b0000
    cdecl puts, .s1

    cdecl itoa, -1, .s1, 8, 16, 0b0000
    cdecl puts, .s1

    cdecl itoa, 12, .s1, 8, 2, 0b0100
    cdecl puts, .s1
    jmp $                   ; 無限ループ

.s0     db "Booting...", 0x0A, 0x0D, 0
.s1     db "--------", 0x0A, 0x0D, 0

ALIGN 2, db 0               ; 0x90の代わりに0x00で埋める。
BOOT:
    .DRIVE: dw 0

%include "./modules/real/puts.s"
%include "./modules/real/itoa.s"

    times 510 - ($ - $$) db 0x90
    db 0x55, 0xAA
