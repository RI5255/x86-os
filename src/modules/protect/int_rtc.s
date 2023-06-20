; rtc_int_en(bit)
; RTCの内部レジスタBに指定されたbitをセットする

rtc_int_en:
    push ebp
    mov ebp, esp

    outp 0x70, 0x0b
    in al, 0x71
    or al, [ebp + 8]
    out 0x71, al

    mov esp, ebp 
    pop ebp 
    ret

int_rtc:
    pusha
    push ds 
    push es

    ; ds, esをkernelのデータ用セグメントディスクリプタを指すように設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    cdecl rtc_get_time, RTC_TIME	

    ; RTCから割り込み要因を取得&割り込み発生要因をクリア
    outp 0x70, 0x0c
    in al, 0x71

    ; PICに割り込みの終了を通知
    outp 0xa0, 0x20
    outp 0x20, 0x20

    pop es 
    pop ds
    popa
    
    iret


