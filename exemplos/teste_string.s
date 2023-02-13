section .text
global _start
_start:

	;INPUT_S STRING,5
		push dword string
		push dword 5
		call input_s

	;OUTPUT_S STRING,5
		push dword string
		push dword 5
		call output_s

	;STOP
		mov eax,1
		mov ebx,0
		int 0x80
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
section .data
_byte_str  db 0dh,0ah,"Bytes lidos/escritos = "
_newline   db 0dh,0ah
section .bss
string	resb 5
