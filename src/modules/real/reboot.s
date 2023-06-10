; void reboot(void);

reboot:
    cdecl puts, .s0
.L0:
    mov ah, 0x00
    int 0x16            ; 入力を受け取る
    cmp al, ' '
    jne .L0   
    cdecl puts, .s1     ; SPACEが入力されるまで繰り返す
    int 0x19            ; 再起動

.s0 db 0x0A, 0x0D, "Push SPACE to reboot...", 0
.s1 db 0x0A, 0x0D, 0x0A, 0x0D, 0