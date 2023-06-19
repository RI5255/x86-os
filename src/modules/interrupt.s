ALIGN 4
IDTR:   dw  8 * 256 - 1
        dd  VECT_BASE

; 割り込みハンドラを登録する
init_int:
    push ebx
    push edi 

    lea eax, [int_default]
    mov ebx, 0x0008_8e00    ; セグメントセレクタ=8, P=1, DPL=0, DT=0, タイプ=0xe
    xchg ax, bx             ; eax:ebxが割り込みゲートディスクリプタになる

    mov ecx, 256 
    mov edi, VECT_BASE
.L0:
    mov [edi], ebx
    mov [edi + 4], eax
    add edi, 8
    loop .L0

    lidt [IDTR]

    pop edi 
    pop ebx 

    ret

; スタックに積まれている値を表示して無限ループ
int_stop:
    cdecl draw_str, 15, 25, 0x060f, eax

    mov		eax, [esp]
    cdecl	itoa, eax, .p1, 8, 16, 0b0100

    mov		eax, [esp + 4]
    cdecl	itoa, eax, .p2, 8, 16, 0b0100

    mov		eax, [esp + 8]
    cdecl	itoa, eax, .p3, 8, 16, 0b0100

    mov		eax, [esp +12]
    cdecl	itoa, eax, .p4, 8, 16, 0b0100

    cdecl	draw_str, 16, 25, 0x0F04, .s1
    cdecl	draw_str, 17, 25, 0x0F04, .s2
    cdecl	draw_str, 18, 25, 0x0F04, .s3
    cdecl	draw_str, 19, 25, 0x0F04, .s4

    jmp		$

.s1		db	"ESP+ 0:"
.p1		db	"________ ", 0
.s2		db	"   + 4:"
.p2		db	"________ ", 0
.s3		db	"   + 8:"
.p3		db	"________ ", 0
.s4		db	"   +12:"
.p4		db	"________ ", 0

; デフォルトの割り込みハンドラ(int_stopを呼び出す)
int_default:
    pushf
    push cs
    push int_stop

    mov eax, .s0
    iret

.s0		db	" <    STOP    > ", 0

; ゼロ除算用の割り込みハンドラ
int_zero_div:
    pushf
    push cs
    push int_stop

    mov eax, .s0
    iret

.s0		db	" <    ZERO DIV    > ", 0