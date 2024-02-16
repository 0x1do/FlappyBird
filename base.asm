IDEAL
MODEL small
STACK 100h
DATASEG
    
    RANDOM_NUMBER db ?
    TUBE1_LENGTH db ?
    TUBE2_LENGTH db ?
    GAP db 50
    SCREEN_HEIGHT db 200
CODESEG


proc generateRandomNumber
    push ax
    push bx

    mov bl, [SCREEN_HEIGHT]
    sub bl, [GAP]
    sub bl, 1 ; bl now contains the highest length tube1 can be
    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    xor al, ah
    and al, bl ; put in al random number between 0 and second operand
    mov [RANDOM_NUMBER], al
    add [RANDOM_NUMBER], '0'

    pop bx
    pop ax
    ret 
endp genRandNum

proc generateTubes
    push ax
    push bx
    
    mov al, [RANDOM_NUMBER]
    mov [TUBE1_LENGTH], al
    mov bl, [SCREEN_HEIGHT]
    sub bl, [TUBE1_LENGTH]
    sub bl, [GAP]
    mov [TUBE2_LENGTH], bl

    pop bx
    pop ax
    ret
endp generatetubes

start:
    mov ax, @data
    mov ds, ax

    mov ax, 13h
    int 10h

exit:
    mov ax, 4c00h
    int 21h
END start