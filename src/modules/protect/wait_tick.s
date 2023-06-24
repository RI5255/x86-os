; wait_tick(tick)
; ウェイト回数

wait_tick:
    push ebp 
    mov ebp, esp 

    mov ecx, [ebp + 8]      ; ウェイト回数
    mov eax, [TIMER_COUNT]

.L0:
    cmp [TIMER_COUNT], eax
    je .L0                  ; 割り込みでTIMER_COUNTが下記変わるためにインクリメント
    inc eax                 
    loop .L0

    mov esp, ebp 
    pop ebp
    ret