task_1:
    ;cdecl draw_str, 0, 63, 0x07, .s0
    cdecl SS_GATE_0:0, 0, 63, 0x07, .s0

.L0:
    ; 時刻を表示
    ;cdecl draw_time, 0, 72, 0x0700, dword [RTC_TIME]

    jmp .L0

.s0 db	"Task-1", 0