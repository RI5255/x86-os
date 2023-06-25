int_pf:
    push ebp 
    mov ebp, esp 

    pusha
    push ds
    push es

    mov ax, 0x0010 
    mov ds, ax 
    mov es, ax

    ;　例外を生成したアドレスを確認
    mov eax, cr2 
    and eax, ~0x0fff
    cmp eax, 0x0010_7000
    jne .L0

    ; ページを有効化してパラメータをコピーする
    mov [CR3_BASE + 0x1000 + 0x107 * 4], dword  0x00107007
    
    cdecl memcpy, 0x0010_7000, DRAW_PARAM, rose_size

    jmp .L1

.L0:
    add esp, 8
    popa
    pop ebp

    pushf
    push cs
    push int_stop

    mov eax, .s0
    iret

.L1:
    pop es 
    pop ds
    popa 

    mov esp, ebp 
    pop ebp 

    add esp, 4      ; エラーコードを破棄
    iret

.s0		db	" <    PAGE FAULT    > ", 0