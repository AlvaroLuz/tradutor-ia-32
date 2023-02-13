;---------------------------------------------
;%define varpointer dword[ebp+12]
;%define in_bytes dword[ebp+8]
input_s:
    enter   0,0
    mov     eax, 3          ;read
    mov     ebx, 0          ;from prompt
    mov dword ecx, [ebp+12] 	;store in varpointer
    mov dword edx, [ebp+8]   	;in_bytes 
    int     0x80            ;system call
    call _print_bytes_message
    leave
    ret     8