; void itoa(short num, char *buf, short size, short radix, short flag)
; testは論理積を計算する。jeはZF=1ならジャンプする。
; divはunsiged divide。dx:axを指定された即値orレジスタの値で割り、商をax, 余りをdxに格納する。
; loopnzはcx-1が0以外かつZF!=1の時に指定されたラベルにジャンプする。
; stosbはdiにaxの値を書き込んで、diをDFに応じて加減算する。
; 数値を文字列に変換する際は基数で割っていくことになる。つまり下の方から文字列に変換していくことになる。

itoa:
    push bp 
    mov bp, sp 
    push bx
    mov ax, [bp + 4]    ; 変換する数値
    mov si, [bp + 6]    ; 変換結果を書き込むバッファ
    mov cx, [bp + 8]    ; バッファのサイズ    
    mov di, si
    add di, cx 
    dec di              ; バッファの最後尾
    mov bx, [bp + 12]   ; flags 

    ; 符号付判定
    test bx, 0b0001     ; 最下位bitが1なら符号付
    je .L0
    cmp ax, 0           
    jge .L0
    or bx, 0b0010       ; 負数なら必ず符号を表示する
.L0:

    ; 符号出力判定
    test bx, 0b0010    ; フラグが1なら符号を出力
    je .L3
    cmp ax, 0
    jge .L1
    neg ax              ; 符号反転
    mov [si], byte '-'
    jmp .L2
.L1:
    mov [si], byte '+'
.L2: 
    dec cx 
.L3:

    ; ASCII変換(この時点でaxは必ず正)
    mov bx, [bp + 10]       ; 基数
.L4:
    mov dx, 0
    div bx                  ; ax = dx:ax / bx, dx = dx:ax % bx
    mov  si, dx
    mov dl, byte [.ascii + si]
    mov [di], dl 
    dec di
    cmp ax, 0
    loopnz .L4              ; cx - 1 != 0 かつZF != 1の時.L4にジャンプ

    ; 空欄を埋める
    cmp cx, 0
    je .L6
    mov al, ' '
    cmp [bp + 12], word 0b0100
    jne .L5
    mov al, '0'             ; フラグが1なら'0'で埋める。
.L5:
    std                     ; DF = 0
    rep stosb

.L6:
    pop bx 
    mov bp, sp 
    pop bp 
    ret

.ascii db "0123456789ABCDEF"


