; short get_drive_param(struct drive *d)
; BIOSコールのINT 0x13(AH = 0x8)でドライブパラメータを取得できる。
; この時取得できるのはアクセスできる最後のセクタのCHS。
; 成功時0以外、失敗時0を返す。
; rorはROtate Rightの略。

get_drive_param:
    push bp 
    mov bp, sp 
    
    push bx 
    push si

    mov si, [bp + 4]
    
    mov ah, 8
    mov dl, [si + drive.no]
    int 0x13
    jc  .L0         ; 失敗した場合はCF=1になる。

    mov al, cl
    and ax, 0x3F    ; 下位6bitのみ有効化(セクタ数)
    shr cl, 6       ; シリンダ数の上位2bitのみにしておく。
    ror cx, 8       ; シリンダ数
    inc cx

    movzx bx, dh    ; ヘッド数
    inc bx  

    mov [si + drive.cyln], cx 
    mov [si + drive.head], bx 
    mov [si + drive.sect], ax

    jmp .L1

.L0:
    mov ax, 0

.L1:
    pop si 
    pop bx 
    mov sp, bp 
    pop bp 
    ret

