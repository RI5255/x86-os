; draw_rect(x0, y0, x1, y1, color)

draw_rect:
    push ebp 
    mov ebp, esp 

    ; ローカル変数
    push dword 0        ; -4:   x0 
    push dword 0        ; -8:   y0
    push dword 0        ; -12:  x1
    push dword 0        ; -16:  y1

    push ebx

    mov eax, [ebp + 8]  ; x0
    mov ebx, [ebp + 12] ; y0
    mov ecx, [ebp + 16] ; x1
    mov edx, [ebp + 20] ; y1

    cmp eax, ecx
    jl .L0
    xchg eax, ecx
.L0:
    cmp ebx, edx
    jl .L1 
    xchg ebx, edx
.L1:
    ; ローカル変数として保存
    mov [ebp - 4], eax
    mov [ebp - 8], ebx
    mov [ebp - 12], ecx
    mov [ebp - 16], edx

    ; 上線
    cdecl draw_line, dword [ebp - 4],   \
                     dword [ebp - 8],   \
                     dword [ebp - 12],  \
                     dword [ebp - 8],   \
                     dword [ebp + 24]   
    ; 左線
    cdecl draw_line, dword [ebp - 4],   \
                     dword [ebp - 8],   \
                     dword [ebp - 4],   \
                     dword [ebp - 16],  \
                     dword [ebp + 24]  

    dec dword [ebp - 16]
    ; 下線
    cdecl draw_line, dword [ebp - 4],   \
                     dword [ebp - 16],  \
                     dword [ebp - 12],  \
                     dword [ebp - 16],  \
                     dword [ebp + 24]   
    inc dword [ebp - 16]

    dec dword [ebp - 12]
    ; 右線
    cdecl draw_line, dword [ebp - 12],  \
                     dword [ebp - 8],   \
                     dword [ebp - 12],  \
                     dword [ebp - 16],  \
                     dword [ebp + 24]   
    pop ebx

    mov esp, ebp 
    pop ebp
    ret