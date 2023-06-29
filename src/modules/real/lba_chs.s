; short lba_chs(struct drive *d, struct drive *d_chs, short lba);

lba_chs:
    push bp 
    mov bp, sp 

    push bx
    push di
    push si 
    
    mov si, [bp + 4]            ; ドライブパラメータのアドレス
    mov di, [bp + 6]            ; LBAをCHSに変換した結果を書き込むdrive構造体のアドレス

    mov al, [si + drive.head]   ; 最大ヘッド数
    mul byte [si + drive.sect]  ; 最大セクタ数(トラックあたりのセクタ数)
    mov bx, ax                  ; シリンダあたりのセクタ数
    mov dx, 0
    mov ax, [bp + 8]            ; LBA
    div bx                      ; r/m16の場合、dx:axをオペランドで割った商がaxに、余りがdxに入る
    mov [di + drive.cyln], ax   ; シリンダ番号
    mov ax, dx
    div byte [si + drive.sect]  ; r/m8の場合、axをオペランドで割った商がalに、余りがahに入る
    movzx dx, ah
    inc dx                      ; セクタ番号は1始まりなので+1する
    mov ah, 0x00
    mov [di + drive.head], ax
    mov [di + drive.sect], dx

    pop si 
    pop di 
    pop bx
    
    mov sp, bp 
    pop bp 
    ret