; draw_font(row, col)
; row: 行
; col: 列
; BIOSが使っているフォント全256種類を16x16で表示する

draw_font:
    push ebp 
    mov ebp, esp 
    
    push ebx
    push edi 
    push esi 

    mov esi, [ebp + 8]  ; 行
    mov edi, [ebp + 12] ; 列

    mov ebx, 0
.L0:
    cmp ebx, 256
    jae .L1

    mov eax, ebx
    shr eax, 4          
    add eax, esi        ; 1行は16文字

    mov ecx, ebx
    and ecx, 0x0f
    add ecx, edi

    cdecl draw_char, eax, ecx, 0x07, ebx

    inc ebx
    jmp .L0

.L1:
    pop esi 
    pop edi 
    pop ebx 
    mov esp, ebp 
    pop ebp 
    ret
