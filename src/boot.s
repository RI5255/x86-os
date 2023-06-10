entry:
    jmp ipl

    times 90 - ($ - $$) db 0x90 ; BPB(Boot Parameter Block)

; IPL(Initial Program Loader)
ipl:
    jmp $ ; 無限ループ
    times 510 - ($ - $$) db 0x90
    db 0x55, 0xAA

