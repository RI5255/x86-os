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

    cdecl	draw_rect, 100, 100, 200, 200, 0x03
	cdecl	draw_rect, 400, 250, 150, 150, 0x05
	cdecl	draw_rect, 350, 400, 300, 100, 0x06

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
%include "./modules/protect/draw_rect.s"

    ; padding
    times KERNEL_SIZE - ($ -$$) db 0