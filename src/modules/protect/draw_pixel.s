; draw_pixel(x, y, color)
; color: 表示色

draw_pixel:
    push ebp 
    mov ebp, esp 

    push ebx 
    push edi 
    push esi 

    mov edi, [ebp + 12]                     ; y
    shl edi, 4
    lea edi, [edi * 4 + edi + 0xA_0000]     ; yを80倍して足す(1行80byteだから)

    mov ebx, [ebp + 8]                      ; x
    mov ecx, ebx                            ; 元のxを保存
    shr ebx, 3
    add edi, ebx                            ; xを8で割って足す(1byte=8bitだから)

    and ecx, 0x7                            ; xを8で割った余り  
    mov ebx, 0x80
    shr ebx, cl                             ; bit patternを作成

    mov esi, [ebp + 16]                     ; 色
    
    ; 輝度
    cdecl	vga_set_read_plane, 0x03
    cdecl	vga_set_write_plane, 0x08
    cdecl	vram_bit_copy, ebx, edi, 0x08, esi

    ; R
    cdecl	vga_set_read_plane, 0x02
    cdecl	vga_set_write_plane, 0x04
    cdecl	vram_bit_copy, ebx, edi, 0x04, esi

    ; G
    cdecl	vga_set_read_plane, 0x01
    cdecl	vga_set_write_plane, 0x02
    cdecl	vram_bit_copy, ebx, edi, 0x02, esi

    ; B
    cdecl	vga_set_read_plane, 0x00
    cdecl	vga_set_write_plane, 0x01
    cdecl	vram_bit_copy, ebx, edi, 0x01, esi

    pop esi 
    pop edi 
    pop ebx 

    mov esp, ebp 
    pop ebp 
    ret