task_2:
    cdecl draw_str, 1, 63, 0x07, .s0
    
    fild dword [.c1000]
    fldpi
    fidiv dword [.c180] 
    fldpi
    fadd st0, st0
    fldz

.L0:
    fadd st0, st2 
    fprem                   ; 2πの範囲になるように剰余を計算してst0にセット
    fld st0 
    fsin
    fmul st0    
    fmul st0, st4
    fbstp [.bcd]

    mov eax, [.bcd]
    mov ebx, eax

    and eax, 0x0f0f
    or eax, 0x3030

    shr ebx, 4 
    and ebx, 0x0f0f
    or ebx, 0x3030

    mov [.s2], bh           ; 1桁目
    mov [.s3], ah           ; 少数1桁目
    mov [.s3 + 1], bl       ; 少数2桁目
    mov [.s3 + 2], al       ; 少数3桁目

    mov eax, 7
    bt [.bcd + 9], eax
    jc .L1

    mov [.s1], byte '+'
    jmp .L2

.L1:    
    mov [.s1], byte '-'     

.L2:
    cdecl draw_str, 1, 72, 0x07, .s1

    cdecl wait_tick, 20

    jmp .L0

ALIGN 4, db 0
.c1000:		dd	1000
.c180:		dd	180

.bcd:	times 10 db	0x00

.s0		db	"Task-2", 0
.s1:	db	"-"
.s2:	db	"0."
.s3:	db	"000", 0
