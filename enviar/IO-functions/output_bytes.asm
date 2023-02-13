;--------------------------------------------------
_print_bytes_message:
    enter 0,0
    push    eax
    mov     ecx, _byte_str   
    mov     edx, 25
    mov     ebx, 1
    mov     eax, 4
    int     0x80   
    pop     eax
    push    eax
    push    eax
    call    _print_bytes
    pop     eax
    push    eax
    mov     ecx, _newline   
    mov     edx, 2
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    pop     eax
    leave
    ret
;--------------------------------------------------
_print_bytes:;copia da funcao de print int
    enter   8,0         ;declara i e aux
    
    mov     esi, ebp    ;ponteiro pra aux
    sub     esi, 8
    
    mov     ebx, 0      ; contador  

    mov dword eax, [ebp+8] ;eax = numero
    mov dword [ebp-4], 0   ;i=0
    mov     ecx, 10
_decompo:               ;do{
    cdq                     ;eax -> edx.eax
    div     ecx             ;eax = edx.eax/10; edx = edx.eax%10
    add     edx, '0'        ;edx = edx + '0'
    push    edx             ;pilha.push_back(edx)
    inc dword [ebp-4]       ;i++
    cmp     eax, 0      ;} while(eax != 0) 
    jnz     _decompo 
     
_print:
    ;printa
    pop dword [ebp-8]
    
    push    ebx
    mov     ecx, esi   
    mov     edx, 1
    mov     ebx, 1
    mov     eax, 4
    int     0x80   
    pop     ebx
    inc     ebx
    
    dec dword [ebp-4]
    cmp dword [ebp-4],0
    jne     _print
    mov     eax, ebx
    
    leave
    ret     4