IDEAL
MODEL small
STACK 100h
DATASEG
    RANDOM_NUMBER db ?
    CLOCK equ es:6Ch
CODESEG
proc genRandNum ; generates random number
    push ax
    push dx
    mov ax, 40h
    mov es, ax
    mov ax, [CLOCK]
    xor al, ah
    and al, 00000111b ; put in al random number between 0 and second operand
    mov [RANDOM_NUMBER], al
    add [RANDOM_NUMBER], '0'
    pop dx
    pop ax
    ret 
endp
start:
    mov ax, @data
    mov ds, ax
exit:
    mov ax, 4c00h
    int 21h
END start