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
%include "./modules/real/kbc.s"
%include "./modules/real/lba_chs.s"
%include "./modules/real/read_lba.s"

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

    ; 次のステージにジャンプ
.L0:
    jmp stage_4

    ; データ
.s0 db "3rd stage...", 0x0A, 0x0D, 0
.s1:    db " Font Address="
.p1:    db "XXXX:"
.p2:    db "XXXX", 0xA, 0xD, 0
        db 0xA, 0xD, 0
.s2     db " ACPI data="
.p3     db "ZZZZ"
.p4     db "ZZZZ", 0x0A, 0x0D, 0

stage_4:
    cdecl puts, .s0
    cli                         ; 割り込み無効化
    cdecl KBC_Cmd_Write, 0xad   ; キーボード無効化
    cdecl KBC_Cmd_Write, 0xd0   ; 出力ポート読み出しコマンドを発行
    cdecl KBC_Data_Read, .key   ; 読み出し結果をバッファに保存
    mov bl, [.key]
    or bl, 0x2
    cdecl KBC_Cmd_Write, 0xd1   ; 出力ポート書き込みコマンドを発行
    cdecl KBC_Data_Write, bx    ; A20 Gateを有効化
    cdecl KBC_Cmd_Write, 0xae   ; キーボード有効化
    sti                         ; 割り込みを有効化
    cdecl puts, .s1

    ; LEDの点灯制御
    cdecl puts, .s2
    mov bx, 0                   ; LEDの点灯状態を管理する
.L0:
    mov ah, 0
    int 0x16                    ; キーコードの取得
    cmp al, '1'                 ; alにはアスキーコードが入る
    jb  .L3                     ; '1'より小さければ終了
    cmp al, '3'         
    ja .L3                      ; '3'より大きければ終了

    mov cl, al                  ; ascii codeは'1'(0x31)~'3'(0x33)まで
    dec cl  
    and cl, 0x3                 ; '1' -> 0, '2' -> 1, '3' -> 2
    mov ax, 1
    shl ax, cl                  ; フラグを立てる
    xor bx, ax  

    ; LED点灯コマンドを送信
    cli
    cdecl KBC_Cmd_Write, 0xad   ; キーボードを無効化
    cdecl KBC_Data_Read, 0xed   ; LEDコマンドをキーボードに送信
    cdecl KBC_Data_Read, .key   ; 応答をバッファに保存
    cmp [.key], byte 0xfa       ; キーボードがコマンドに対応している場合は0xfaが返る
    jne .L1                     ; 対応してい無い場合はメッセージを出力して終了
    cdecl KBC_Data_Write, bx    ; LEDの表示パターンを書き込む
    jmp .L2

.L1:    
    cdecl itoa, word [.key], .e1, 2, 16, 0b0100
    cdecl puts, .e0

.L2:
    cdecl KBC_Cmd_Write, 0xae   ; キーボード有効化
    sti
    jmp .L0

.L3:
    cdecl puts, .s3
    ; 次のステージにジャンプ
    jmp stage_5

    ; データ
.s0:	db	"4th stage...", 0x0A, 0x0D, 0
.s1:	db	" A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2:	db	" Keyboard LED Test...", 0
.s3:	db	" (done)", 0x0A, 0x0D, 0
.e0:	db	"["
.e1:	db	"ZZ]", 0

.key:	dw	0

stage_5:
    cdecl puts, .s0 

    ; ブートローダの後ろにkernelをロード
    cdecl read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
    cmp ax, KERNEL_SECT         ; 読み込んだセクタ数がkernelのサイズを一致しているか確認
    jz .L0
    cdecl puts, .e0
    call reboot

.L0:
    ; 次のステージにジャンプ
    jmp stage_6

.s0		db	"5th stage...", 0x0A, 0x0D, 0
.e0		db	" Failure load kernel...", 0x0A, 0x0D, 0

stage_6:
    cdecl puts, .s0

.L0:
    mov ah, 0x00
    int 0x16                    ; キー入力を待つ
    cmp al, ' '                 
    jne .L0                     ; SPACEが入力されるまで繰り返す

    mov ax, 0x0012              ; グラフィックスモード(640x480)
    int 0x10                    ; ビデオモードの切り替え
    
    ; 処理の終了
    jmp $ 

.s0		db	"6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
		db	" [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0
    
    ; padding
    times BOOT_SIZE - ($ - $$) db 0


