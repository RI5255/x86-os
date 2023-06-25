; memcpy(dst, src, size)

memcpy:
    push ebp 
    mov ebp, esp 

    push edi 
    push esi 

    cld
    mov edi, [ebp + 8]
    mov esi, [ebp + 12]
    mov ecx, [ebp + 16]
    rep movsb

    pop esi 
    pop edi 
    
    mov esp, ebp 
    
    pop ebp 
    ret