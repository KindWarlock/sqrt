%macro pushd 0
    push eax
    push ebx
    push ecx
    push edx
%endmacro
 
%macro popd 0
    pop edx
    pop ecx
    pop ebx
    pop eax
%endmacro
 
%macro print 2
    pushd
    mov edx, %1 
    mov ecx, %2 
    mov ebx, 1
    mov eax, 4
    int 0x80
    popd
%endmacro
 
%macro dprint 0
    push edx
    mov bx, 0 
    mov ecx, 10
%%_divide: 
    mov edx, 0
    div ecx 
    push dx 
    inc bx  
    test eax, eax
    jnz %%_divide
 
%%_digit:
    pop ax
    add ax, '0' 
    mov [result], ax
    print 1, result
    dec bx
    cmp bx, 0
    jg %%_digit
    pop edx
%endmacro

%macro divide 2 ; //-like division
    push eax
    push edx
    
    mov edx, 0 
    mov eax, %1
    mov ecx, %2
    div ecx
    
    mov ecx, eax ; result to ecx
    
    pop edx
    pop eax
%endmacro

%macro avg 2 
    mov ecx, 0
    mov eax, 0
    mov edx, 0
%%_sum:
    add eax, %1[ecx]
    add ecx, 4
    cmp ecx, %2
    jl %%_sum
    
    divide xlen, 4
    
    div ecx
%endmacro

%macro print_dec 0 ; from eax and edx
    dprint
    print 1, point 
    mov eax, edx
    dprint
    print nlen, newline
%endmacro

%macro find_dec 2 ; 1 аргумент - сам остаток, 2 - знаменатель. точность до 3 знаков
    pushd
    mov eax, %1
    mov ebx, 100 ; counter
    mov [temp], dword 0
    
%%_remainder:
    mov ecx, 10
    mul ecx
    mov ecx, %2
    divide ecx, 4
    
    div ecx
    
    push edx
    mul ebx
    pop edx
    add [temp], eax
    mov eax, edx
    
    divide ebx, 10
    mov ebx, ecx 
    
    test ebx, ebx
    
    jnz %%_remainder
    popd
%endmacro

%macro x2 0
    ; num / x1.
    mov eax, [x1]
    mov ecx, 10
    mul ecx
    add eax, [x1_rem]
    mov [temp], eax
    
    mov eax, [num]
    mov ecx, 10
    mul ecx 
    
    mov edx, 0
    div dword [temp]
    ; x1 + ...
    add eax, [x1]
    add edx, [x1_rem]
    cmp edx, 10
    jl %%_x2
    add eax, 1

%%_x2:    
    divide eax, 2
    mov [x2], ecx
%endmacro

section .text
 
global _start
 
_start:
    ; x1 = num / 2
    mov eax, [num]
    mov edx, 0
    mov ecx, 2
    div ecx
    mov [x1], eax

    
    mov eax, edx
    mov ecx, 5
    mul ecx
    mov [x1_rem], eax

    x2
    mov eax, [x1]
    sub eax, [x2]
    cmp eax, 1
    jl _loopend
_loop:
    mov eax, [x2]
    mov [x1], eax
    x2
    mov eax, [x1]
    sub eax, [x2]
    cmp eax, 1
    jge _loop

_loopend:
    mov eax, [x2]
    dprint
    
    
    print nlen, newline
    print len, message
    print nlen, newline
 
    mov eax, 1
    int 0x80
 
section .data
    message db "Done"
    len equ $ - message 
    newline db 0xA, 0XD
    nlen equ $ - newline
    point db ','
    
    num dd 2
    
section .bss
    result resb 1
    x1 resd 1
    x1_rem resd 1
    x2 resd 1
    
    temp resd 1
 
