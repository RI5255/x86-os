; read_lba(drive, lba, sect, dest);

read_lba:
    push bp 
    mov bp, sp  

    push si 
    mov si, [bp + 4]            ; ドライブパラメターのアドレス

    mov ax, [bp + 6]            ; LBA
    cdecl lba_chs, si, .chs, ax ; LBAをCHSに変換

    mov al, [si + drive.no]
    mov [.chs + drive.no], al

    cdecl read_chs, .chs, word [bp + 8], word [bp + 10]

    pop si 

    mov bp, sp 
    pop bp 
    ret

ALIGN 2
.chs    times drive_size    db 0 