section .data
    delim db " ", 0
    token_len dd 0
    temp_ecx db 0
    len db 0

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern strlen
extern malloc

global create_tree
global iocla_atoi

iocla_atoi:
    mov esi, [esp + 4]
    xor ebx, ebx
    xor edi, edi
    xor eax, eax
    mov edx, 1
    movzx ebx, byte[esi]
    cmp ebx, '-'
    je make_negative
    jmp get_characters

make_negative:
    mov edx, -1     ;se va inmulti cu -1 in caz ca e nr negativ
    inc esi
    jmp get_characters

get_characters:
    movzx ebx, byte[esi]
    cmp ebx, 0x00
    jle make_number
    imul eax, 10
    lea eax, [eax+ebx-'0']
    inc esi
    jmp get_characters

make_number:
    imul eax, edx
    leave
    ret

;=====================================================================

create_tree:
    enter 0, 0
    push ebx
    push ecx
    mov ebx, [ebp+8]

;aflu lungimea sirului initial

count_length:
    push ebx
    call strlen
    add esp, 4
    dec eax
    mov [len], eax      ;salvez lungimea in variabila [len]
    mov ecx, eax        ;ecx va salva lungimea sirului initial
    xor eax, eax

    xor edi, edi
    xor edx, edx

;======================================================================

;parcurg sirul caracter cu caracter de la final
while:
    mov dl, byte[ebx+ecx]
    cmp dl, ' '         ;daca am gasit spatiu creiez un cuvant
    je put_space
    cmp ecx, 0          ;am ajuns la final si tratez separat root-ul
    je get_root
    inc edi
    mov [token_len], edi       ;aflu lungimea unui token
    dec ecx
    jmp while

;aloc memorie pentru token = esi
put_space:
    xor edi, edi 
    mov [temp_ecx], ecx
    push ebx
    push ecx
    push dword [token_len]
    call malloc
    add esp, 4
    mov esi, eax
    pop ecx
    pop ebx

;creez tokenul, mutand caracterele din ebx in esi
create_token:
    inc ecx
    xor edx, edx
    mov dl, byte[ebx+ecx]  
    mov [esi+edi], dl
   
    inc edi
    cmp edi, [token_len]    ;verific daca am ajuns la lungimea token
    je fin_while            ;daca da finalizez cuvantul prin a ii pune \0
    jmp create_token

;finalizez token-ul
fin_while:    
    mov dl, 0x00
    mov [esi+edi], dl
    jmp verificare

;restaurez valoarea lui ecx
fin_while2:
    xor edi, edi
    mov ecx, [temp_ecx]
    dec ecx
    jmp while

;il tratez pe root separat, fiind sigura ca el mereu este operator
get_root:
    xor edx, edx
    push ebx
    push ecx
    push dword [token_len]
    call malloc
    add esp, 4
    mov esi, eax
    pop ecx
    pop ebx

;creez token-ul din root
while_root:
    mov dl, byte[ebx+ecx]

    mov [esi], edx
    xor edx, edx
    mov dl, 0x00
    mov byte[esi+1], dl
    jmp operator_root

;verific daca este operator sau operand
verificare:
    cmp byte [esi], '+'
    je operator
    cmp byte [esi], '/'
    je operator
    cmp byte [esi], '*'
    je operator
    cmp byte [esi], '-'
    je check_operator
    jmp operand

;verific daca '-' provine de la operator sau operand
check_operator:
    mov ecx, [token_len]
    cmp ecx, 1
    je operator
    jmp operand

;creez arborele in cazul cand este operator
operator:
    push dword 4
    call malloc
    add esp, 4
    xor edi, edi
    mov edi, eax
    mov [edi], esi

    push dword 12       ;aloc memorie pe stiva
    call malloc
    add esp, 4
    xor edx, edx
    mov edx, dword[edi]
    mov [eax], edx      ;pun in parinte valoarea lui edi aka esi-token

    xor edi, edi
    pop edi             ;scot un copil de pe stiva si il fac nod de stanga
    mov [eax+4], edi    

    xor edi, edi
    pop edi             ;scot al doilea copil de pe stiva si il fac nod de dreapta
    mov [eax+8], edi
    push eax            ;inserez nodul eax pe stiva
    jmp fin_while2

;aloc memorie pentru operand si il pun pe stiva
operand:
    push dword 12
    call malloc
    add esp, 4
    
    mov [eax], esi
    xor edx, edx
    mov [eax+4], edx
    mov [eax+8], edx
    push eax
    jmp fin_while2

;la fel ca la operator doar ca aici tratez doar root-ul
operator_root:
    push dword 4
    call malloc
    add esp, 4
    xor edi, edi
    mov edi, eax
    mov [edi], esi

    xor eax, eax
    push dword 12
    call malloc
    add esp, 4
    xor edx, edx
    mov edx, dword[edi]
    mov [eax], edx

    xor ebx, ebx
    pop ebx
    mov [eax+4], ebx

    xor ebx, ebx
    pop ebx
    mov [eax+8], ebx
    push eax
;======================================================================
exit:
    pop eax
    pop ecx
    pop ebx
    leave
    ret
