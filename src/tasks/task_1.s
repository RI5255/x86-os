task_1:
    cdecl draw_str, 0, 63, 0x07, .s0

.L0:
    ; 時刻を表示
    cdecl draw_time, 0, 72, 0x0700, dword [RTC_TIME]

    ; task0に切り替える
    jmp SS_TASK_0:0

    jmp .L0

.s0 db	"Task-1", 0