int_timer:
    pusha
    push ds 
    push es 

    mov ax, 0x0010 
    mov ds, ax 
    mov es, ax 

    inc dword [TIMER_COUNT]

    ; マスタPICに割り込みの終了を通知
    outp 0x20, 0x20 

    ; タスクの切り替え
    str ax      ; TRレジスタを取得
    cmp ax, SS_TASK_0
    je .L0
    cmp ax, SS_TASK_1
    je .L1
    cmp ax, SS_TASK_2
    je .L2
    jmp SS_TASK_0:0
    jmp .L3
.L0:
    jmp SS_TASK_1:0
    jmp .L3
.L1:
    jmp SS_TASK_2:0
    jmp .L3
.L2:
    jmp SS_TASK_3:0
    jmp .L3
.L3:
    pop es 
    pop ds 
    popa
    
    iret

ALIGN 4, db 0
TIMER_COUNT:	dd	0