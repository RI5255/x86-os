; draw_color_bar(row, col)
; row: 行
; col: 列
; 指定された場所にカラーバーを8行2列で表示する。一つのカラーバーはスペース8個分の大きさ

draw_color_bar:
    push ebp 
    mov ebp, esp 
    
    push ebx 
    push edi 
    push esi

    mov edi, [ebp + 8]      ; 行
    mov esi, [ebp + 12]     ; 列

    mov ebx, 0
.L0:
    cmp ebx, 16             ; draw_strは16回呼ばれる
    jae .L1

    mov eax, ebx
    shr eax, 1
    add eax, edi

    mov ecx, ebx
    and ecx, 0x1 
    shl ecx, 3              ; カラーバーは一つ8byte
    add ecx, esi

    mov edx, ebx
    shl edx, 1
    mov edx, [.t0 + edx]    ; 表示色は配列から取得

    cdecl draw_str, eax, ecx, edx, .s0
    inc ebx
    jmp .L0

.L1:
    pop esi 
    pop edi 
    pop ebx
    mov esp, ebp 
    pop ebp 
    ret

.s0:	db '        ', 0
.t0:	dw	0x0000, 0x0800
		dw	0x0100, 0x0900
		dw	0x0200, 0x0A00
		dw	0x0300, 0x0B00
		dw	0x0400, 0x0C00
		dw	0x0500, 0x0D00
		dw	0x0600, 0x0E00
		dw	0x0700, 0x0F00