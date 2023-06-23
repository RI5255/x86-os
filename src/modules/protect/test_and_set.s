test_and_set:
    push ebp 
    mov ebp, esp 

    push ebx

    mov eax, 0
    mov ebx, [ebp + 8]      ; アドレス

.L0:
    lock bts [ebx], eax     ; *ebxの最下位bitの値をCFにセットして1を書き込む
    jnc .L2                 ; 最下位bitが0ならロックを取ることに成功

.L1:
    bt [ebx], eax           ; *ebxの最下位bitの値をCFにセット
    jc .L1                  ; ロックが取れるまでビジーループ
    jmp .L0

.L2:
    pop ebx 
    mov esp, ebp 
    pop ebp 
    ret