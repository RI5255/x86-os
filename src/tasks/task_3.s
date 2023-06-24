task_3:
    mov ebp, esp 

    push dword 0    ; -4:   x0
    push dword 0    ; -8:   y0
    push dword 0    ; -12:  x 
    push dword 0    ; -16:  y
    push dword 0    ; -20:  r

    mov esi, DRAW_PARAM

    ; タイトルを表示
    mov eax, [esi + rose.x0]
    mov ebx, [esi + rose.y0]

    shr eax, 3
    shr ebx, 4
    dec ebx
    mov ecx, [esi + rose.color_s]
    lea edx, [esi + rose.title]
    cdecl draw_str, ebx, eax, ecx, edx 

    ; x軸の中点を計算
    mov eax, [esi + rose.x0]
    mov ebx, [esi + rose.x1]
    sub ebx, eax
    shr ebx, 1
    add ebx, eax
    mov [ebp - 4], ebx

    ; y軸の中点を計算
    mov eax, [esi + rose.y0]
    mov ebx, [esi + rose.y1]
    sub ebx, eax
    shr ebx, 1
    add ebx, eax
    mov [ebp - 8], ebx

    ; x軸の描画
    mov eax, [esi + rose.x0]
    mov ebx, [ebp - 8]
    mov ecx, [esi + rose.x1]
    cdecl draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]

    ; y軸の描画
    m mov eax, [esi + rose.y0]
    mov ebx, [ebp - 4]
    mov ecx, [esi + rose.y1]
    cdecl draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_x]

    ; 枠の描画
    mov eax, [esi + rose.x0]
    mov ebx, [esi + rose.y0]
    mov ecx, [esi + rose.x1]
    mov edx, [esi + rose.y1]
    cdecl draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z]

    ; 振幅をx軸の約95%とする
    mov eax, [esi + rose.x1]
    sub eax, [esi + rose.x0]
    shr eax, 1
    mov ebx, eax
    shr ebx, 4
    sub eax, ebx

    ; FPUの初期化
    cdecl fpu_rose_init, eax, dword [esi + rose.n], dword [esi + rose.d]

.L0:
    ; 座標計算
    lea eax, [ebp - 12]     ; xのアドレス 
    lea ecx, [ebp - 16]     ; yのアドレス
    mov ebx, [ebp - 20]     ; r

    cdecl fpu_rose_update, eax, ecx, ebx
    
    ; 角度更新
    inc ebx
    mov eax, ebx
    mov edx, 0
    mov ebx, 360 * 100 
    div ebx                 ; edx = edx:eax % ebx
    mov [ebp - 20], edx

    ; ドット描画
    mov ebx, [ebp - 12]
    mov edi, [ebp - 16]

    add ebx, [ebp - 4]
    add edi, [ebp - 8]

    mov ecx, [esi + rose.color_f]
    int 0x82

    ; ウェイト
    cdecl wait_tick, 2

    ; ドット描画(消去)
    mov ecx, [esi + rose.color_b]
    int 0x82

    jmp .L0

ALIGN 4, db 0
DRAW_PARAM:
	istruc	rose
		at	rose.x0,		dd		 16
		at	rose.y0,		dd		 32
		at	rose.x1,		dd		416
		at	rose.y1,		dd		432

		at	rose.n,			dd		2
		at	rose.d,			dd		1

		at	rose.color_x,	dd		0x0007
		at	rose.color_y,	dd		0x0007
		at	rose.color_z,	dd		0x000F
		at	rose.color_s,	dd		0x030F
		at	rose.color_f,	dd		0x000F
		at	rose.color_b,	dd		0x0003

		at	rose.title,		db		"Task-3", 0

	iend

; fpu_rose_init(A, n, d)
fpu_rose_init:
    push ebp 
    mov ebp, esp 

    push dword 180

    fldpi
    fidiv dword [ebp - 4]
    fild dword [ebp + 12]
    fidiv dword [ebp + 16]
    fild dword [ebp + 8]

    mov esp, ebp 
    pop ebp 
    ret

; fpu_rose_update(px, py, t)
; px:   x座標を格納するアドレス
; py:   y座標を格納するアドレス
; t:    角度
fpu_rose_update:
    push ebp 
    mov ebp, esp 

    push ebx

    mov eax, [ebp + 8]      ; xのアドレス
    mov ebx, [ebp + 12]     ; yのアドレス

    fild dword [ebp + 16]   ; t
    fmul st0, st3           ; π/180をかけてラジアンに変換
    fld  st0
    fsincos

    fxch st2                ; st0とst2を交換
    fmul st0, st4           ; st0にkを掛ける
    fsin
    fmul st0, st3           ; Asin(kθ)

    fxch st2
    fmul st0, st2           ; Asin(kθ)cos(θ)
    fistp dword [eax]

    fmulp st1, st0          ; Asin(kθ)sin(θ)
    fchs                    ; -Asin(kθ)sin(θ)
    fistp dword [ebx]

    pop ebx 

    mov esp, ebp 
    pop ebp 
    ret