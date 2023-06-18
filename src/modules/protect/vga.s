
; vga_set_read_plane(plane)
; plane: プレーンを選択。輝度=3, R=2, G=1, B=0 
; プレーンの内容を読み出したいときに使う

vga_set_read_plane:
    push ebp 
    mov ebp, esp 

    mov ah, [ebp + 8]
    and ah, 0x3
    mov al, 0x4          ; 読み込みプレーン選択レジスタ
    mov dx, 0x3ce        ; グラフィックスコントローラのポートアドレス
    out dx, ax

    mov esp, ebp 
    pop ebp 
    ret

; vga_set_write_plane(plane)
; plane: プレーンを選択。輝度=B3, R=B2, G=B1, B=B0 
; プレーンに書き込みたいときに使う

vga_set_write_plane:
    push ebp 
    mov ebp, esp

    mov ah, [ebp + 8]
    and ah, 0xf
    mov al, 0x2         ; 書き込みプレーン選択レジスタ
    mov dx, 0x3c4       ; シーケンサのポートアドレス
    out dx, ax

    mov esp, ebp 
    pop ebp 
    ret

; vram_font_copy(font, vram, plane, color)
; font: フォントのアドレス
; vram: VRAMのアドレス
; plane: 出力プレーン
; color: 描画色(前景色背景色それぞれ1byte)
; 文字と前景色、背景色が渡されたとき、ひとつのカラーパレットにデータを書き込む

vram_font_copy:
    push ebp 
    mov ebp, esp

    push ebx 
    push edi 
    push esi 

    mov esi, [ebp + 8]              ; フォントアドレス
    mov edi, [ebp + 12]             ; VRAMのアドレス 
    movzx eax, byte [ebp + 16]      ; 出力プレーン 
    movzx ebx, word [ebp + 20]      ; 描画色(bh=背景色, bl=前景色)
    
    test bh, al                     ; 出力プレーン&背景色
    setz dh
    dec dh                          ; 出力プレーンと背景色が一致していた場合は0xff。していない場合は0x00

    test bl, al                     ; 出力プレーン&前景色 
    setz dl 
    dec dl                          ; 出力プレーンと前景色が一致していた場合は0xff。していない場合は0x00

    cld 
    mov ecx, 16                     ; フォントデータは16バイト
.L0:
    lodsb                           ; al = *esi++ (1byte読み込む)
    mov ah, al
    not ah                          ; フォントデータをbit反転したもの

    and al, dl                      ; 前景色のデータ

    test ebx, 0x0010
    jz  .L1
    and ah, [edi]                   ; 背景色(透過モードだった場合)
    jmp .L2
.L1:
    and ah, dh                      ; 背景色(透過モードでなかった場合)
.L2:
    or al, ah                       ; al = 前景色|背景色

    mov [edi], al
    add edi, 80
    loop .L0

    pop esi 
    pop edi 
    pop ebx 

    mov esp, ebp 
    pop ebp 
    ret

; vram_bit_copy(bit, vram , plane, color)
; bit:  bit pattern(1byte)
; vram: VRAMのアドレス 
; flag: 出力プレーン
; color: 表示色(この関数では前景色のみ指定する)

vram_bit_copy:
    push ebp 
    mov ebp, esp

    push ebx 
    push edi 
    push esi

    mov edi, [ebp + 12]         ; VRAMのアドレス 
    movzx eax, byte [ebp + 16]  ; プレーンの選択
    movzx ebx, word [ebp + 20]  ; 表示色

    test bl, al
    setz bl                     ; 表示色と出力プレーンが違ったら1
    dec bl                      ; 表示色と出力プレーンが同じなら0xff違ったら0x00

    mov al, [ebp + 8]           ; bit pattern
    mov ah, al 
    not ah                      ; 背景用のbit pattern

    and ah, [edi]               ; 背景用のbit pattern
    and al, bl                  ; 前景用のbit pattern
    or al, ah                   ; 書き込むbit pattern

    mov [edi], al

    pop esi 
    pop edi 
    pop ebx

    mov esp, ebp 
    pop ebp 
    ret








