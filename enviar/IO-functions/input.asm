;--------------------------------------------------
;%define varpointer dword[ebp+8]
;%define negativo dword [ebp-4]
input_int:
    enter   4,0
    mov     ecx, 13
    mov dword [ebp-4], 0
_aloc_buffer:
    push    byte 0
    loop _aloc_buffer
    
    ;esi =  esp
    mov     esi, esp        ;esi = fim da pilha    
    
    ;le 12 bytes e guarda no fim da pilha
    mov     eax, 3          ;read
    mov     ebx, 0          ;from prompt
    mov     ecx, esi        ;store in esi
    mov     edx, 13         ;max of 13 bytes
    int     0x80            ;system call
    ;guarda o valor do return
    mov ecx, eax
    
    ;se o numero for negativo
    cmp     byte[esi], '-'
    jne     _nao_negativo
    inc     esi             ;le um caractere a menos
    mov dword [ebp-4], 1     ;flag de negativo = 1
_nao_negativo:

    mov     ebx, 10         ; ebx = 10 pra multiplicar no loop
    mov     eax, 0          ; eax =0 pra armazenar a soma 
_loop_input:
    cmp     byte[esi], 0ah
    je      _end_loop
    cdq                     ;edx.eax = eax
    mul     ebx             ;edx.eax = eax*10
    movzx   edx, byte[esi]  ;edx = [esi]
    add     eax, edx        ;eax += edx 
    sub     eax, '0'        ;eax -= '0'
    inc     esi             ;esi ++
    jmp     _loop_input   
_end_loop:

    cmp dword [ebp-4], 1
    jne     _fim_input
    neg     eax
_fim_input:
    
    mov dword ebx, [ebp+8]
    mov dword [ebx], eax
    mov     eax, ecx
    mov     ecx, 13
    sub     esp, 13
    call _print_bytes_message    
    leave
    ret     4