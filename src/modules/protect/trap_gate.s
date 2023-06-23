trap_gate_81:
    cdecl draw_char, ebx, edi, ecx, eax
    iret

trap_gate_82:
    cdecl draw_pixel, ebx, edi, ecx
    iret
