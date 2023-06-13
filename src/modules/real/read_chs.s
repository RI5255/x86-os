; short read_chs(struct drive *d, short sect, char *dst);
; CHS方式で指定されたセクタを読み出す関数
read_chs:
    push bp 
    mov bp, sp 
    
    push 3                      ; リトライ回数 
    
    push bx
    push si
    
    mov si, [bp + 4] ; 構造体のアドレス
    
    mov ch, [si + drive.cyln]   ; シリンダ番号(下位8bit)
    mov cl, [si + drive.cyln + 1] 
    shl cl, 6                   ; シリンダ番号(上位2bit)
    or cl, [si + drive.sect]    ; セクタ番号 
    mov dh, [si + drive.head]   ; ヘッダ番号
    mov dl, [si]                ; ドライブ番号
    mov ax, 0                  
    mov es, ax                  ; int 0x13で読み込むときは、es:bxに読み込まれる
    mov bx, [bp + 8]            ; 読み出し先アドレス。

.L0:
    mov ah, 0x02
    mov al, [bp + 6]            ; 読み出しセクタ数
    int 0x13    
    jnc .L1                     ; CF=0なら成功。1なら失敗
    mov al, 0
    jmp .L2                     ; 失敗ならそのまま戻る。

.L1: 
    cmp al, 0                   ; alには読み出したセクタ数が入る
    jne .L2                     ; 読み込めていれば終了
    mov ax, 0
    dec word [bp - 2]
    jnz .L0                     ; リトライを試みる    

.L2: 
    mov ah, 0                   ; ahにはステータスコードが入っているが破棄。(返り値は読み込んだセクタ数になる。)
    pop si
    pop bx
    mov sp, bp 
    pop bp 
    ret