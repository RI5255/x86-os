; itoa(num, buf, size, radix, flags)
; num:      変換する数値
; buf:      バッファのアドレス
; size:     バッファのサイズ
; radix:    基数
; flags:    オプション
  
itoa:
    push ebp 
    mov ebp, esp 

    push ebx 
    push edi 
    push esi 

    mov eax, [ebp + 8]  ; 変換する数値
    mov esi, [ebp + 12] ; バッファのアドレス　
    mov ecx, [ebp + 16] ; バッファのサイズ
    mov ebx, [ebp + 24] ; flags    

    mov edi, esi
    add edi, ecx
    dec edi             ; バッファの末尾のアドレス

    ; 符号付判定　
    test ebx, 0b0001    
    je .L0
    cmp eax, 0
    jge .L0
    or ebx, 0b0010      ; 負数なら必ず符号を出力
.L0:
    ; 符号出力判定　
    test ebx, 0b0010
    je .L3 
    cmp eax, 0
    jge .L1
    neg eax
    mov [esi], byte '-'
    jmp .L2
.L1:
    mov [esi], byte '+'
.L2:
    dec ecx
.L3:
    ; ASCII変換(この時点でeaxは正)
    mov ebx, [ebp + 20] ; radix
.L4:
    mov edx, 0
    div ebx             ; eax=商, edx=余り
    mov esi, edx
    mov dl, byte [.ascii + esi]
    mov [edi], dl 
    dec edi
    cmp eax, 0
    loopnz .L4

    ; 空欄を埋める　
    cmp ecx, 0
    je .L6
    mov al, ' '
    cmp [ebp + 24], word 0b0100
    jne .L5
    mov al, '0'         ; B2が1なら'0'で埋める
.L5:
    std                 ; DF=1(マイナス方向)
    rep stosb           ; while(--ecx) *edi-- = al
.L6:
    pop esi
    pop edi 
    pop ebx 
    mov esp, ebp 
    pop ebp 
    ret

.ascii db "0123456789ABCDEF"