call_gate:
    push ebp 
    mov ebp, esp 

    push ebx
    push ds 
    push es

    mov ax, 0x0010 
    mov ds, ax
    mov es, ax

    mov eax, dword [ebp + 12]
    mov ebx, dword [ebp + 16]
    mov ecx, dword [ebp + 20]
    mov edx, dword [ebp + 24]
    cdecl draw_str, eax, ebx, ecx, edx

    pop es 
    pop ds
    pop ebx

    mov esp, ebp 
    pop ebp 

    retf 4*4