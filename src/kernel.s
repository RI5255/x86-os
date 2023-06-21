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
    
    ; TSSディスクリプタのベースを設定
    set_desc GDT.tss_0, TSS_0
	set_desc GDT.tss_1, TSS_1	

    ; LDTディスクリプタのベースとリミットを設定
    set_desc GDT.ldt, LDT, word LDT_LIMIT

    ; GDTを設定(再設定)
    lgdt [GDTR]

    ; task1用のスタックを設定
    mov esp, SP_TASK_0

    ; TRレジスタを設定
    mov ax, SS_TASK_0
    ltr ax 

    ; IDTを初期化してIDTRを設定　
    cdecl init_int
    
    ; PICを初期化
    cdecl init_pic
    
    ; 割り込みハンドラを登録 
    set_vect 0x00, int_zero_div
    set_vect 0x20, int_timer
    set_vect 0x21, int_keyboard
    set_vect 0x28, int_rtc

    ; RTCの割り込みを有効化
    cdecl rtc_int_en, 0x10

    ; タイマのカウンタをセット
    cdecl int_en_timer0

    ; PICのIMRを設定
    outp 0x21, 0b1111_1000              ; スレーブPIC, KBC, タイマからの割り込みを有効化
    outp 0xa1, 0b1111_1110              ; RTC空の割り込みを有効化

    ; ハードウェア割り込みを有効化
    sti

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
    ; task1に切り替える
    jmp SS_TASK_1:0

    cdecl draw_rotation_bar

    ; リングバッファのデータを読む
    cdecl ring_rd, _KEY_BUFF, .int_key
    cmp eax, 0
    je .L0 

    ; keybordからの入力を表示
    cdecl draw_key, 29, 2, _KEY_BUFF

    jmp .L0

.s0:    db " Hello, Kernel! ", 0

ALIGN 4, db 0
.int_key:	dd	0

ALIGN 4, db 0
FONT_ADDR:  dd 0
RTC_TIME:	dd	0

%include "descriptor.s"
%include "./modules/int_timer.s"
%include "tasks/task_1.s"

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
%include "./modules/protect/pic.s"
%include "./modules/protect/int_rtc.s"
%include "./modules/protect/ring_buff.s"
%include "./modules/protect/int_keyboard.s"
%include "./modules/protect/interrupt.s"
%include "./modules/protect/timer.s"
%include "./modules/protect/draw_rotation_bar.s"

    ; padding
    times KERNEL_SIZE - ($ -$$) db 0