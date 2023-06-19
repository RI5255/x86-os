%macro cdecl 1-*.nolist
    %rep %0 - 1
        push %{-1:-1}
        %rotate -1
    %endrep
    %rotate -1
    
    call %1

    %if 1 < %0
        add sp, (__BITS__ >> 3) * (%0 - 1)
    %endif
%endmacro

%macro set_vect 1-*
    push eax
    push edi 

    mov edi, VECT_BASE + (%1 * 8)   ; 対応するIDTのエントリアドレス
    mov eax, %2                     ; 割り込みハンドラのアドレス
    mov [edi], ax 
    shr eax, 16
    mov [edi + 6], ax

    pop edi
    pop eax 
%endmacro

struc drive
    .no     resw    1   ; ドライブ番号
    .cyln   resw    1   ; シリンダ番号 
    .head   resw    1   ; ヘッド 
    .sect   resw    1   ; セクタ　
endstruc

