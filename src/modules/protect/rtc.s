; rtc_get_time(dst)
; dst: 時刻を書き込むアドレス
; 返り値:    成功時0, 失敗時1  

rtc_get_time:
    push ebp 
    mov ebp, esp 

    push ebx

    mov al, 0xa
    out 0x70, al
    in al, 0x71     ; 制御レジスタの情報
    test al, 0x80
    je  .L0         ; UIP(Update In Progress)bitが立っていなければ処理を継続
    mov eax, 1 
    jmp .L1

.L0:
    mov al, 0x4     
    out 0x70, al
    in al, 0x71         ; 時間データ

    shl eax, 8

    mov al, 0x2 
    out 0x70, al
    in al, 0x71         ; 分データ 

    shl eax, 8

    mov al, 0x0
    out 0x70, al
    in al, 0x71         ; 秒データ

    and eax, 0xffffff

    mov ebx, [ebp + 8]
    mov [ebx], eax

    mov eax, 0

.L1:
    pop ebx
    mov esp, ebp 
    pop ebp 
    ret

    