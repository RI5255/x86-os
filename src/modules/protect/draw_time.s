; draw_time(row, col, color, time)
; row:      行
; col:      列
; color:    表示色
; time:     時刻　

draw_time:
    push ebp 
    mov ebp, esp 
    push ebx

    mov ebx, [ebp + 20] ; 時刻 
    
    mov eax, 0
    mov al, bl          ; 秒
    cdecl itoa, eax, .sec, 2, 16, 0b0100

    mov eax, 0
    mov al, bh          ; 分
    cdecl itoa, eax, .min, 2, 16, 0b0100

    shr ebx, 16         ; 時　
    cdecl itoa, ebx, .hour, 2, 16, 0b0100

    cdecl draw_str, dword [ebp + 8], dword [ebp + 12], dword [ebp + 16], .hour

    pop ebx 
    mov esp, ebp 
    pop ebp
    ret

ALIGN 2, db 0
.hour:	db	"ZZ:"
.min:	db	"ZZ:"
.sec:	db	"ZZ", 0