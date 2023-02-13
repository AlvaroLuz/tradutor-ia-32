;---------------------------------------------
;%define varpointer dword[ebp+8]
input_c:
    enter 0,0
    mov     eax, 3          ;read
    mov     ebx, 0          ;from prompt
    mov dword ecx, [ebp+8] 	;store in varpointer
    mov     edx, 1          ;1 byte
    int     0x80            ;system call
    call _print_bytes_message
    leave
    ret     8