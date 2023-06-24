int_nm:
    pusha
    push ds
    push es

    mov ax, DS_KERNEL
    mov ds, ax
    mov es, ax

    clts                            ; タスクスイッチフラグをクリア
    
    mov edi, [.last_tss]            
    str esi                         ; TRレジスタ
    and esi, ~0x0007                ; 下位3bitをマスク

    cmp edi, 0      
    je .L0                          ; FPUを使う初めてのタスクだった場合

    cmp esi, edi
    je .L1                          ; 前回と同じタスクだった場合

    cli                             ; 割り込み禁止

    ; 前のタスクのFPUコンテキストを保存
    mov ebx, edi 
    call get_tss_base
    call save_fpu_context

    ; 現在のタスクのFPUコンテキストをロード
    mov ebx, esi
    call get_tss_base
    call load_fpu_context

    sti                             ; 割り込みを有効化
    jmp .L1

.L0:
    cli                             ; 割り込みを禁止

    mov ebx, esi
    call get_tss_base
    call load_fpu_context           ; FPUを初期化

    sti                             ; 割り込みを有効化

.L1:
    mov [.last_tss], esi

    pop es 
    pop ds
    popa 

    iret

ALIGN 4, db 0
.last_tss:	dd		0

; ebxで指定されるTSSディスクリプタからベースアドレスを取得する。
get_tss_base:
    mov eax, [GDT + ebx + 2]
    shl eax, 8
    mov al, [GDT + ebx + 7]
    ror eax, 8
    ret

save_fpu_context:
    fnsave [eax + 104]
    mov [eax + 104 + 108], dword 1  ; コンテキストを保存したことを示すフラグ
    ret

load_fpu_context:
    cmp [eax + 104 + 108], dword 0
    jne .L0
    fninit                          ; FPUを初期化
    jmp .L1
.L0:
    frstor [eax + 104]              ; コンテキストを復帰
.L1:
    ret