page_set_4m:
    push ebp 
    mov ebp, esp 

    push edi 

    cld
    mov edi, [ebp + 8]          ; ページディレクトリの先頭
    mov eax, 0
    mov ecx, 1024
    rep stosd                   ; 0初期化

    ; 先頭のエントリを設定
    mov eax, edi                ; ページテーブルの先頭
    and eax, ~0x0000_0fff        
    or eax, 7                   ; RWの許可
    mov [edi - (1024 * 4)], eax 

    ; ページテーブルの設定
    mov eax, 0x7
    mov ecx, 1024

.L0:
    stosd
    add eax, 0x1000
    loop .L0

    pop edi
    
    mov esp, ebp 
    pop ebp
    ret 

init_page:
    cdecl page_set_4m, CR3_BASE
    cdecl page_set_4m, CR3_TASK_4
    cdecl page_set_4m, CR3_TASK_5
    cdecl page_set_4m, CR3_TASK_6

    ; 0x0010_7000に対応するページテーブルエントリのPを0にする
    mov [CR3_BASE + 0x1000 + 0x107 * 4], dword 0

    ; 0x0010_7000に対応するページテーブルエントリだけ書き変える
    mov [CR3_TASK_4 + 0x1000 + 0x107 * 4], dword PARAM_TASK_4 + 7
    mov [CR3_TASK_5 + 0x1000 + 0x107 * 4], dword PARAM_TASK_5 + 7
    mov [CR3_TASK_6 + 0x1000 + 0x107 * 4], dword PARAM_TASK_6 + 7

    cdecl memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size
    cdecl memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size 
    cdecl memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size 
    
    ret
