draw_rotation_bar:
    mov eax , [TIMER_COUNT]
    
    ; 16カウントごとに更新
    shr eax, 4
    
    cmp eax, [.index]
    je .L0

    mov [.index], eax
    and eax, 0x03

    mov al, [.table + eax]
    cdecl draw_char, 29, 0, 0x000f, eax

.L0:
    ret

ALIGN 4, db 0
.index:		dd 0
.table:		db	"|/-\"