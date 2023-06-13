; void get_mem_info(void);
; int 0x15(ah=0xeb20)でメモリマップを取得できる。
; es:diに書き込み先バッファのアドレス,ecxにバッファサイズ、ebxにインデックスを指定する。axは0xe820, edxは0x5344150("SMAP")固定
; ecxに書き込みバイト数、ebxにインデックスがセットされる。eaxは"SMAP"になる。
; BIOSが対応していない場合はeaxが"SMAP"になることは無いのでこれで判断できる。
; 一気に全てのメモリ情報を読み出せるわけではなく一つずつ。最後のメモリ領域の場合はebxが0になる。それ以外の場合は次のインデックスになる。

get_mem_info:
    push ebx 
    push di

    cdecl puts, .s0

    mov bp, 0                   ; 読み込んだ行数
    mov ebx, 0
    mov es, bx
.L0:
    mov eax, 0xe820
    mov ecx, E820_RECORD_SIZE
    mov edx, 'PAMS'
    mov di, .b0                 ; esは0初期化されているので.b0に読み込む。
    int 0x15 
    
    cmp eax, 'PAMS'
    je .L1
    jmp .L6                     ; BIOSが未対応なら終了
.L1:
    jnc .L2                     ; CF=0なら成功
    jmp .L6                     ; 失敗したら終了
.L2:
    cdecl put_mem_info, di      ; 1レコード分の情報を表示
    
    ; ACPIテーブル用のメモリ領域だった場合の処理
    mov eax, [di + 16]          ; メモリタイプ
    cmp eax, 3
    jne .L4
    mov eax, [di]
    mov [ACPI_DATA.addr], eax
    mov eax, [di + 8]
    mov [ACPI_DATA.len], eax
.L4:
    cmp ebx, 0
    ;je .L6
    jz .L5
    inc bp
    cmp bp, 0x8
    jne .L5 
    cdecl puts, .s2             ; 中断メッセージを表示
    mov ah, 0x10 
    int 0x16
    cdecl puts, .s3 
.L5:
    cmp ebx, 0
    jne .L0                     ; まだレコードがあれば読み込む

.L6:
    cdecl puts, .s1 
    
    pop di
    pop ebx
    ret

    ; データ
ALIGN 4, db 0
.b0:    times E820_RECORD_SIZE db 0

.s0:	db " E820 Memory Map:", 0x0A, 0x0D
	    db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:    db " <more...>", 0
.s3:    db 0x0D, "          ", 0x0D, 0

; void put_mem_info(int16_t *ent);
put_mem_info:
    push bp 
    mov bp, sp 

    push bx
    push si 

    mov si, [bp + 4]

    ; base(始めと終わりでそれぞれ4byte)
    cdecl itoa, word [si + 6], .p2, 4, 16, 0b0100
    cdecl itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 2], .p3, 4, 16, 0b0100
    cdecl itoa, word [si], .p3 + 4, 4, 16, 0b0100

    ; size(始めと終わりでそれぞれ4byte)
    cdecl itoa, word [si + 14], .p4, 4, 16, 0b0100
    cdecl itoa, word [si + 12], .p4 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 10], .p5, 4, 16, 0b0100
    cdecl itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

    ; type(数値と文字列両方表示)
    cdecl itoa, word [si + 18], .p6, 4, 16, 0b0100
    cdecl itoa, word [si + 16], .p6 + 4, 4, 16, 0b0100  

    cdecl puts, .s1

    mov bx, [si + 16]
    and bx, 0x07    ; これいる？
    shl bx, 1
    add bx, .t0 
    cdecl puts, word [bx]

    pop si
    pop bx 
    mov bp, sp 
    pop bp 
    ret

    ; データ
.s1:    db " "
.p2:    db "ZZZZZZZZ_"
.p3:    db "ZZZZZZZZ "
.p4:    db "ZZZZZZZZ_"
.p5:    db "ZZZZZZZZ "
.p6:    db "ZZZZZZZZ", 0

.s4:    db " (Unknown)", 0x0A, 0x0D, 0
.s5:    db " (usable)", 0x0A, 0x0D, 0
.s6:    db " (reserved)", 0x0A, 0x0D, 0
.s7:    db " (ACPI data)", 0x0A, 0x0D, 0
.s8:    db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:    db " (bad memory)", 0x0A, 0x0D, 0

.t0: dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4
 




