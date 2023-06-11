%include "./include/define.s"
%include "./include/macro.s"

    ORG BOOT_LOAD

entry:
    jmp ipl
    times 90 - ($ - $$) db 0x90     ; BPB(Boot Parameter Block)

; IPL(Initial Program Loader)
ipl:
    cli                             ; 割り込みを禁止
    mov ax, 0x0000
    mov ds, ax
    mov es, ax 
    mov ss, ax
    mov sp, BOOT_LOAD
    sti                             ; 割り込みを有効化
    mov [BOOT + drive.no], dl       ; ブートドライブを保存
    
    cdecl puts, .s0
    
    mov bx, BOOT_SECT - 1           ; 残りのセクタ数
    mov cx, BOOT_LOAD + SECT_SIZE   ; 次のロードアドレス 
    cdecl read_chs, BOOT, bx, cx    
    cmp ax, bx
    jz  .L0
    cdecl puts, .e0                 ; 失敗した場合はエラー表示して再起動
    call reboot
.L0:
    jmp stage_2                     ; ブートの第二ステージに飛ぶ

.s0     db "Booting...", 0x0A, 0x0D, 0
.e0     db "Error:sector read", 0

ALIGN 2, db 0                       ; 0x90の代わりに0x00で埋める。
BOOT:
    istruc drive
        at drive.no,    dw 0        ; ドライブ番号
        at drive.cyln,  dw 0        ; シリンダ
        at drive.head,  dw 0        ; ヘッド
        at drive.sect,  dw 2        ; セクタ　
    iend

%include "./modules/real/puts.s"
%include "./modules/real/itoa.s"
%include "./modules/real/reboot.s"
%include "./modules/real/read_chs.s"

    times 510 - ($ - $$) db 0
    db 0x55, 0xAA

stage_2:
    cdecl puts, .s0 
    jmp $
.s0     db "2nd stage...", 0x0A, 0x0D, 0

    times BOOT_SIZE - ($ - $$)   db 0

