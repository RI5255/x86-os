; draw_line(x0, y0, x1, y1, color)
; (x0, y0): 始点の座標
; (x1, y1): 終点の座標
; color: 表示色　

draw_line:
    push ebp 
    mov ebp, esp 

    ; ローカル変数
    push dword 0    ; -4:   sum(相対軸の積算値)
    push dword 0    ; -8:   x0
    push dword 0    ; -12:  xw 
    push dword 0    ; -16:  inc_x(1 or -1)
    push dword 0    ; -20:  y0
    push dword 0    ; -24:  yw 
    push dword 0    ; -28:  inc_y(1 or -1)

    push ebx 
    push edi
    push esi

    ; 幅を計算(x軸)
    mov eax, [ebp + 8]  ; x0
    mov ebx, [ebp + 16] ; x1
    sub ebx, eax
    jge .L0
    neg ebx
    mov esi, -1         ; xを負の方向に増加させる
    jmp .L1
.L0:
    mov esi, 1          ; xを正の方向に増加させる
.L1: 
    ; 高さを計算(y軸)
    mov ecx, [ebp + 12] ; y0
    mov edx, [ebp + 20] ; y1
    sub edx, ecx
    jge .L2
    neg edx
    mov edi, -1         ; yを負の方向に増加させる
    jmp .L3 
.L2:
    mov edi, 1          ; yを正の方向に増加させる
.L3:
    ; ローカル変数に保存
    mov [ebp - 8], eax  ; x0
    mov [ebp - 12], ebx ; xw  
    mov [ebp - 16], esi ; inc_x

    mov [ebp - 20], ecx ; y0
    mov [ebp -24], edx  ; yw  
    mov [ebp -28], edi  ; inc_y

    ; 基準軸を決める
    cmp ebx, edx
    jg  .L4

    ; xw <= ywの場合はyが基準
    lea esi, [ebp - 20] ; &y0
    lea edi, [ebp - 8]  ; &x0 
    jmp .L5
.L4:
    ; yw < xwの場合はxが基準
    lea esi, [ebp -8]   ; &x0 
    lea edi, [ebp -20]  ; &y0
.L5:
    ; 繰り返し回数(基準軸のdot数)
    mov ecx, [esi - 4]  ; 基準軸の幅
    cmp ecx, 0
    jnz .L6
    mov ecx, 1
.L6:
    ; 線を描画
    push ecx
%ifdef USE_SYSTEM_CALL
    mov ebx, dword [ebp - 8]
    mov edi, dword [ebp - 20]
    mov ecx, dword [ebp + 24]
    int 0x82
%else
    cdecl draw_pixel, dword [ebp - 8], dword [ebp - 20], dword [ebp + 24]
%endif
    pop ecx

    ; 座標を更新
    mov eax, [esi - 8]  ; 基準軸増分
    add [esi], eax

    mov eax, [ebp - 4]  ; 相対軸の積算値
    add eax, [edi - 4]  ; 相対軸の幅を足す
    mov ebx, [esi - 4]  ; 基準軸の幅

    cmp eax, ebx
    jl .L7              ; 基準軸の幅以下なら更新しない
    sub eax, ebx        ; 積算値から基準軸の幅を引く
    mov ebx, [edi - 8]  ; 相対軸増分
    add [edi], ebx

.L7:
    mov [ebp - 4], eax  ; 積算値を更新
    loop .L6

    pop esi
    pop edi 
    pop ebx 
    mov esp, ebp 
    pop ebp 
    ret

