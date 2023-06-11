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
    mov ah, 0x2             ; セクタの読み出し
    mov al, 1               ; 読み込みセクタ数
    mov cx, 0x0002          ; シリンダ番号0, セクタ番号2
    mov dh, 0x00            ; ヘッド番号0
    mov dl, [BOOT.DRIVE]    ; ドライブ番号
    mov bx, BOOT_LOAD + 512 ; 読み込みアドレス
    int 0x13                ; 成功時CF=0, 失敗時CF=1
    jnc .L0
    cdecl puts, .e0         ; 失敗した場合はエラー表示して再起動
    call reboot
.L0:
    jmp stage_2             ; ブートの第二ステージに飛ぶ

.s0     db "Booting...", 0x0A, 0x0D, 0
.e0     db "Error:sector read", 0

ALIGN 2, db 0               ; 0x90の代わりに0x00で埋める。
BOOT:
    .DRIVE: dw 0

%include "./modules/real/puts.s"
%include "./modules/real/itoa.s"
%include "./modules/real/reboot.s"

    times 510 - ($ - $$) db 0x90
    db 0x55, 0xAA

stage_2:
    cdecl puts, .s0 
    jmp $
.s0     db "2nd stage...", 0x0A, 0x0D, 0

    times 1024 * 8 - ($ - $$)   db 0