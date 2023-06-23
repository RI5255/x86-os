; draw_str(row, col, color, p)
; row:      行
; col:      列　
; color:    表示色(前景色,背景色)
; p:        文字列のアドレス

draw_str:
    push ebp 
    mov ebp, esp 

    push ebx 
    push edi 
    push esi 

    mov ebx, [ebp + 8]          ; 行
    mov edi, [ebp + 12]         ; 列
    mov esi, [ebp + 20]         ; 文字列のアドレス 

    cld
.L0:
    movzx ecx, word [ebp + 16]  ; 表示色    
    lodsb                       ; al = *esi++
    cmp al, 0 
    je .L2
    
    %ifdef USE_SYSTEM_CALL
        int 0x81
    %else 
        cdecl draw_char, ebx, edi, ecx, eax
    %endif

    inc edi
    cmp edi, 80
    jl .L1
    mov edi, 0
    inc ebx
    cmp ebx, 30
    jl  .L1
    mov ebx, 0
.L1:
    jmp .L0

.L2:
    pop esi 
    pop edi 
    pop ebx 
    mov esp, ebp 
    pop ebp
    ret
