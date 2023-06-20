int_keyboard:
    pusha
    push ds 
    push es

    mov ax, 0x0010 
    mov ds, ax 
    mov es, ax

    ; キーコードを取得
    in al, 0x60 

    ; リングバッファに保存
    cdecl ring_wr, _KEY_BUFF, eax

    ; マスタPICに割り込みの終了を通知
    outp 0x20, 0x20 

    pop es 
    pop ds 
    popa
    
    iret

ALIGN 4, db 0
_KEY_BUFF:	times ring_buff_size db 0
