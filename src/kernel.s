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

    ; 文字を表示
    cdecl	draw_char, 0, 0, 0x010F, 'A'
    cdecl	draw_char, 0, 1, 0x010F, 'B'
    cdecl	draw_char, 0, 2, 0x010F, 'C'

    cdecl	draw_char, 0, 0, 0x0402, '0'
    cdecl	draw_char, 0, 1, 0x0212, '1'
    cdecl	draw_char, 0, 2, 0x0212, '_'

    ; 処理の終わり
    jmp $

ALIGN 4, db 0
FONT_ADDR:  dd 0

%include "./modules/protect/vga.s"
%include "./modules/protect/draw_char.s" 

    ; padding
    times KERNEL_SIZE - ($ -$$) db 0
    