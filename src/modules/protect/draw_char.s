
; draw_char(row, col, color, ch)
; row: 行
; col: 列
; color; 表示色(前景色、背景色)
; ch: 文字

draw_char:
    push ebp 
    mov ebp, esp 

    push ebx 
    push edi
    push esi

    %ifdef USE_TEST_AND_SET
        cdecl test_and_set, IN_USE
    %endif

    ; 表示文字から文字データのアドレスを計算
    movzx esi, byte [ebp + 20]              ; 文字データ
    shl esi, 4                              ; 文字データは16byte
    add esi, [FONT_ADDR]                    ; フォントのアドレス

    ; row, colから書き込み際となるVRAMのアドレスを計算
    mov edi, [ebp + 8]                      ;  行
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000]     ; 1280倍(1行は1028バイトだから)
    add edi, [ebp + 12]                     ; 列を足す(1列は1バイトだから)

    movzx ebx, word [ebp + 16]              ; 表示色

    ; 輝度
    cdecl vga_set_read_plane, 0x3
    cdecl vga_set_write_plane, 0x08
    cdecl vram_font_copy, esi, edi, 0x8, ebx

    ; R
    cdecl vga_set_read_plane, 0x02
    cdecl vga_set_write_plane, 0x04
    cdecl vram_font_copy, esi, edi, 0x04, ebx

    ; G
    cdecl vga_set_read_plane, 0x01
    cdecl vga_set_write_plane, 0x02		
    cdecl vram_font_copy, esi, edi, 0x02, ebx

    ; B
    cdecl vga_set_read_plane, 0x00	
    cdecl vga_set_write_plane, 0x01
    cdecl vram_font_copy, esi, edi, 0x01, ebx

    %ifdef USE_TEST_AND_SET
        mov [IN_USE], dword 0
    %endif 

    pop esi 
    pop edi 
    pop ebx

    mov esp, ebp 
    pop ebp 
    ret

%ifdef USE_TEST_AND_SET
ALIGN 4, db 0
IN_USE:	dd	0
%endif