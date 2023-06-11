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
%include "./modules/real/reboot.s"
%include "./modules/real/read_chs.s"

    times 510 - ($ - $$) db 0
    db 0x55, 0xAA

%include "./modules/real/itoa.s"
%include "./modules/real/get_drive_param.s"

stage_2:
        cdecl puts, .s0

        ; ドライブ情報を取得
        cdecl get_drive_param, BOOT
        cmp ax, 0
        jne .L0
        cdecl puts, .e0
        call reboot
.L0:    
        ; ドライブ情報を表示
        mov ax, [BOOT + drive.no]
        cdecl itoa, ax, .p1, 2, 16, 0b0100
        mov ax, [BOOT + drive.cyln]
        cdecl itoa, ax, .p2, 4, 16, 0b0100
        mov ax, [BOOT + drive.head]
        cdecl itoa, ax, .p3, 2, 16, 0b0100
        mov ax, [BOOT + drive.sect]
        cdecl itoa, ax, .p4, 2, 16, 0b0100
        cdecl puts, .s1
        
        ; 処理の終わり
        jmp $

        ; データ
.s0     db "2nd stage...", 0x0A, 0x0D, 0
.s1     db " Drive:0x"
.p1     db "  , C:0x"
.p2     db "    , H:0x"
.p3     db "  , S:0x"
.p4     db "  ", 0x0A, 0x0D, 0
.e0     db "Can't get drive parameter.", 0

        ; padding
        times BOOT_SIZE - ($ - $$) db 0


