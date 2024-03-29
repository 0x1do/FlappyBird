IDEAL
MODEL small
STACK 100h
DATASEG

    RANDOM_NUMBER dw ?

    GAP dw 50
    SCREEN_HEIGHT dw 200
    BACKGROUND_COLOR db 11
    BLACK_COLOR  db 00h

    ; tubes variables:
    TUBES_COLOR db 14
    TUBES_WIDTH dw 15
    TUBES_X_POSITION dw 275
    UPPER_TUBE_Y_POSITION dw 0
    LOWER_TUBE_Y_POSITION dw 125 ; GAP size
    LOWER_TUBE_HEIGHT dw 75
    UPPER_TUBE_HEIGHT dw 75
    
    ; bird variables:
    BIRD_COLOR db 7
    BIRD_WIDTH dw 15
    BIRD_HEIGHT dw 15
    BIRD_X_POSITION dw 50
    BIRD_Y_POSITION dw 90
    
    VELOCITY dw 1
CODESEG

proc generateRandomNumber
    push ax
    push bx

    mov bx, [SCREEN_HEIGHT]
    sub bx, [GAP]
    sub bx, 1 ; bl now contains the highest random possible value
    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    xor al, ah
    and al, bl ; put in al random number between 0 and second operand
    xor ah, ah
    mov [RANDOM_NUMBER], ax

    pop bx
    pop ax
    ret 
endp generateRandomNumber

proc generateTubesValues
    push ax bx cx
    
    call generateRandomNumber
    
    ; upper tube calc
    mov ax, [RANDOM_NUMBER]
    mov [UPPER_TUBE_HEIGHT], ax
    mov bx, [SCREEN_HEIGHT]
    sub bx, ax
    sub bx, [GAP]
    

    mov [LOWER_TUBE_HEIGHT], bx
    mov cx, [SCREEN_HEIGHT]
    sub cx, [LOWER_TUBE_HEIGHT]
    
    
    mov [UPPER_TUBE_Y_POSITION], 0    
    mov [LOWER_TUBE_Y_POSITION], cx


    pop cx bx ax
    ret
endp generateTubesValues


proc generateNewTubes
    call generateTubesValues

endp generateNewTubes


start:
    mov ax, @data
    mov ds, ax
    

game_loop:
    
    ; mov ax, [TUBES_X_POSITION]
    ; cmp ax, 20
    call generateNewTubes




    jmp game_loop

exit:
    mov ax, 03h
    int 10h

    mov ax, 4c00h
    int 21h
END start