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

    ; BIOSのフォントデータを表示
    cdecl draw_font, 13, 63

    ; 文字列を表示
    cdecl draw_str, 14, 25, 0x010f, .s0

    ; カラーバーを表示
    cdecl draw_color_bar, 4, 63

    ; 短形を表示
    cdecl draw_rect, 100, 100, 200, 200, 0x03
	cdecl draw_rect, 400, 250, 150, 150, 0x05
	cdecl draw_rect, 350, 400, 300, 100, 0x06

.L0:
    ; 時刻を表示　
    cdecl rtc_get_time, RTC_TIME
    cmp eax, 1
    je .L0
    cdecl draw_time, 0, 72, 0x0700, dword [RTC_TIME]
    jmp .L0
    
    ; 処理の終わり
    jmp $

.s0:    db " Hello, Kernel! ", 0

ALIGN 4, db 0
FONT_ADDR:  dd 0
RTC_TIME:	dd	0

%include "./modules/protect/vga.s"
%include "./modules/protect/draw_char.s" 
%include "./modules/protect/draw_font.s"
%include "./modules/protect/draw_str.s"
%include "./modules/protect/draw_color_bar.s"
%include "./modules/protect/draw_pixel.s"
%include "./modules/protect/draw_line.s"
%include "./modules/protect/draw_rect.s"
%include "./modules/protect/itoa.s" 
%include "./modules/protect/rtc.s"
%include "./modules/protect/draw_time.s"
    ; padding
    times KERNEL_SIZE - ($ -$$) db 0