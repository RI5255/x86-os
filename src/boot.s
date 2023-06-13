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

; リアルモード時に取得した情報
FONT:
.seg:   dw 0
.off:   dw 0
ACPI_DATA:
.addr:  dd 0
.len:   dd 0

%include "./modules/real/itoa.s"
%include "./modules/real/get_drive_param.s"
%include "./modules/real/get_font_addr.s"
%include "./modules/real/get_mem_info.s"

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
    
    ; 次のステージにジャンプ
    jmp stage_3

        ; データ
.s0     db "2nd stage...", 0x0A, 0x0D, 0
.s1     db " Drive:0x"
.p1     db "  , C:0x"
.p2     db "    , H:0x"
.p3     db "  , S:0x"
.p4     db "  ", 0x0A, 0x0D, 0
.e0     db "Can't get drive parameter.", 0

stage_3:
    cdecl puts, .s0 

    ; BIOSのフォントデータを取得する
    cdecl get_font_addr, FONT

    ; フォントアドレスを表示
    cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
    cdecl itoa, word [FONT.off], .p2, 4, 16, 0b0100
    cdecl puts, .s1 

    ; メモリマップの取得と表示
    cdecl get_mem_info
    mov eax, [ACPI_DATA.addr]
    cmp eax, 0
    je .L0 
    cdecl itoa, ax, .p4, 4, 16, 0b0100
    shr eax, 16
    cdecl itoa, ax, .p3, 4, 16, 0b0100
    cdecl puts, .s2 

    ; 処理の終わり
.L0:
    jmp $

    ; データ
.s0 db "3rd stage...", 0x0A, 0x0D, 0
.s1:    db " Font Address="
.p1:    db "XXXX:"
.p2:    db "XXXX", 0xA, 0xD, 0
        db 0xA, 0xD, 0
.s2     db " ACPI data="
.p3     db "ZZZZ"
.p4     db "ZZZZ", 0x0A, 0x0D, 0

    ; padding
    times BOOT_SIZE - ($ - $$) db 0


