;------------------------------------------------
;%define str_pointer[ebp+12]
;%define str_size [ebp+8]
output_s:
    enter   0,0
    mov dword esi, [ebp+12]
    mov dword ecx , [ebp+8]
_repete: 
    push    ecx
    mov     ecx, esi   
    mov     edx, 1
    mov     ebx, 1
    mov     eax, 4
    int     0x80 
    pop     ecx
    inc	    esi
    loop    _repete
    mov	    eax, [ebp+8]
    call _print_bytes_message
    leave
    ret     8