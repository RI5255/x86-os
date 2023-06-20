; ring_rd(buff, data)
; buff: リングバッファのアドレス
; data: データを保存するアドレス
; 成功時に1, 失敗時に0を返す

ring_rd:
    push ebp 
    mov ebp, esp 

    push ebx 
    push esi 
    push edi 

    mov esi, [ebp + 8]                      ; リングバッファのアドレス
    mov edi, [ebp + 12]                     ; データを保存するアドレス 

    mov eax, 0
    mov ebx, [esi + ring_buff.rp]           ; 読み込み位置
    cmp ebx, [esi + ring_buff.wp]           ; 書き込み位置と比較
    je .L0                                  ; 読み込みデータが無い場合は終了

    mov al, [esi + ring_buff.item + ebx]    ; データ 
    mov [edi], al 

    ; 読み込み位置を更新
    inc ebx
    and ebx, RING_INDEX_MASK
    mov [esi + ring_buff.rp], ebx

    mov eax, 1

.L0:
    pop edi 
    pop esi 
    pop ebx 

    mov esp, ebp 
    pop ebp 
    ret 

; ring_wr(buff, data)
; buff: リングバッファのアドレス 
; data: 書き込むデータ
; 成功時0以外、失敗時0を返す

ring_wr:
    push ebp 
    mov ebp, esp 

    push ebx 
    push esi

    mov esi, [ebp + 8]                      ; リングバッファのアドレス

    mov eax, 0
    mov ebx, [esi + ring_buff.wp]           ; 書き込み位置
    mov ecx, ebx
    inc ecx
    and ecx, RING_INDEX_MASK

    cmp ecx, [esi + ring_buff.rp]           ; バッファが一杯だったら終了
    je .L0

    mov al, [ebp + 12]                      ; データ

    mov [esi + ring_buff.item + ebx], al
    mov [esi + ring_buff.wp], ecx
    mov eax, 1

.L0:
    pop esi 
    pop ebx 
    mov esp, ebp 
    pop ebp 
    ret

; draw_key(row, col, buff)
; row: 行
; col: 列
; buff: リングバッファのアドレス　

draw_key:
    push ebp 
    mov ebp, esp 

    push ebx
    push edi 
    push esi 

    mov edi, [ebp + 12]             ; 列
    mov esi, [ebp + 16]             ; リングバッファのアドレス　

    mov ebx, [esi + ring_buff.wp]   ; 書き込み位置　
    lea esi, [esi + ring_buff.item] ; データのアドレス
    mov ecx ,RING_ITEM_SIZE

.L0:
    dec ebx
    and ebx, RING_INDEX_MASK
    movzx eax, byte [esi + ebx]

    push ecx
    cdecl itoa, eax, .tmp, 2, 16, 0b0100 
    pop ecx
    push ecx
    cdecl draw_str, dword [ebp + 8], edi, 0x02, .tmp
    pop ecx

    add edi, 3                      ; 表示位置を更新

    loop .L0

    pop esi 
    pop edi 
    pop ebx

    mov esp, ebp 
    pop ebp
    ret

.tmp	db "-- ", 0
