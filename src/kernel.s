    %include "./include/define.s"
    %include "./include/macro.s"

    ORG KERNEL_LOAD 
[BITS 32]
kernel:
    ; フォントアドレスを取得
    mov esi, BOOT_LOAD + SECT_SIZE
    movzx eax, word [esi]               ; セグメント
    shl eax, 4
    movzx ebx, word [esi + 2]           ; オフセット　
    add eax, ebx
    mov [FONT_ADDR], eax                ; フォントのアドレスを保存

    cdecl draw_font, 13, 63             ; BIOSのフォントデータを表示

    cdecl draw_str, 14, 25, 0x010f, .s0

    cdecl draw_color_bar, 4, 63

    cdecl draw_line, 100, 100,   0,   0, 0x0F
    cdecl draw_line, 100, 100, 200,   0, 0x0F
    cdecl draw_line, 100, 100, 200, 200, 0x0F
    cdecl draw_line, 100, 100,   0, 200, 0x0F

    cdecl draw_line, 100, 100,  50,   0, 0x02
    cdecl draw_line, 100, 100, 150,   0, 0x03
    cdecl draw_line, 100, 100, 150, 200, 0x04
    cdecl draw_line, 100, 100,  50, 200, 0x05

    cdecl draw_line, 100, 100,   0,  50, 0x02
    cdecl draw_line, 100, 100, 200,  50, 0x03
    cdecl draw_line, 100, 100, 200, 150, 0x04
    cdecl draw_line, 100, 100,   0, 150, 0x05

    cdecl draw_line, 100, 100, 100,   0, 0x0F
    cdecl draw_line, 100, 100, 200, 100, 0x0F
    cdecl draw_line, 100, 100, 100, 200, 0x0F
    cdecl draw_line, 100, 100,   0, 100, 0x0F

    ; 処理の終わり
    jmp $

.s0:    db " Hello, Kernel! ", 0

ALIGN 4, db 0
FONT_ADDR:  dd 0

%include "./modules/protect/vga.s"
%include "./modules/protect/draw_char.s" 
%include "./modules/protect/draw_font.s"
%include "./modules/protect/draw_str.s"
%include "./modules/protect/draw_color_bar.s"
%include "./modules/protect/draw_pixel.s"
%include "./modules/protect/draw_line.s"

    ; padding
    times KERNEL_SIZE - ($ -$$) db 0