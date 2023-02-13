;-----------------------------------------------
;%define numero dword [ebp+8]
;%define i dword [ebp-4]
;%define aux dword [ebp-8]
output_int:;de int para string
    enter   8,0         ;declara i e aux
    
    mov     esi, ebp    ;ponteiro pra aux
    sub     esi, 8
    
    mov     ebx, 0      ; contador 
    
    ;if numero>0
    cmp dword [ebp+8], 0
    jge     _nao_neg     
    
    neg	dword [ebp+8]      ;numero = -numero
    ;print("-")
    mov dword [ebp-8], '-'    
    inc     ebx
	push	ebx
    mov     ecx, esi   
    mov     edx, 1
    mov     ebx, 1
    mov     eax, 4
    int     0x80 
	pop ebx
_nao_neg:

    mov dword eax, [ebp+8] ;eax = numero
    mov dword [ebp-4], 0   ;i=0
    mov     ecx, 10
_decompoe:               ;do{
    cdq                     ;eax -> edx.eax
    div     ecx             ;eax = edx.eax/10; edx = edx.eax%10
    add     edx, '0'        ;edx = edx + '0'
    push    edx             ;pilha.push_back(edx)
    inc dword [ebp-4]       ;i++
    cmp     eax, 0      ;} while(eax != 0) 
    jnz     _decompoe 
     
_printa:
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
    jne     _printa
    mov     eax, ebx
    call _print_bytes_message
    ;sai
    leave
    ret     4 