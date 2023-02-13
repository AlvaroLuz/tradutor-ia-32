;------------------------------------------
;%define char_pointer[ebp+8]
output_c:
    enter   0,0  
    mov dword ecx, [ebp+8]   
    mov     edx, 1
    mov     ebx, 1
    mov     eax, 4
    int     0x80    
    call _print_bytes_message
    leave
    ret     4