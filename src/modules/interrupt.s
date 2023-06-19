int_default:
    pushf
    push cs
    push int_stop

    mov eax, .s0
    iret

.s0		db	" <    STOP    > ", 0

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