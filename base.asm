IDEAL
MODEL small
STACK 100h
DATASEG

    RANDOM_NUMBER db ?

    TUBE1_LENGTH db ?
    TUBE2_LENGTH db ?

    GAP db 50
    SCREEN_HEIGHT db 200

    TUBE_COLOR db 14
    BACKGROUND_COLOR db 11
    BIRD_COLOR db 10
    

    BIRD_X_POSITION dw 120
    BIRD_Y_POSITION dw 100

    TUBE1_X_POSITION dw 300
    TUBE1_Y_POSITION dw ?

    TUBE2_X_POSITION dw 450
    TUBE2_Y_POSITION dw ?
    
    VELOCITY dw 1
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

    pop bx
    pop ax
    ret 
endp generateRandomNumber

proc generateTubes
    push ax
    push bx
    
    call generateRandomNumber

    mov al, [RANDOM_NUMBER]
    mov [TUBE1_Y_POSITION], al
    mov bl, [SCREEN_HEIGHT]
    sub bl, [TUBE1_Y_POSITION]
    sub bl, [GAP]
    mov [TUBE2_Y_POSITION], bl

    pop bx
    pop ax
    ret
endp generateTubes

proc CheckSpacePressed
    push ax

    mov ah, 01h  ; Check if a key has been pressed
    int 16h
    jz noKeyPress ; Jump if no key is pressed
    jnz incYValue
    mov ah, 00h  ; Get the key pressed
    int 16h
    cmp al, 32    ; Compare with space key

    mov ax, [BIRD_Y_POSITION]
    add ax, 10
    mov [BIRD_Y_POSITION], ax


noKeyPress:
    pop ax
    ret
endp CheckSpacePressed

proc updateBirdPlace
    push ax
    push bx
    
    mov ax, [VELOCITY]
    add ax, 1
    mov [VELOCITY], ax
    
    mov ax, [BIRD_Y_POSITION]
    add ax, [VELOCITY]
    mov [BIRD_Y_POSITION], ax
    
    cmp ax, 0
    jle exit

    cmp ax, [SCREEN_HEIGHT]
    jge exit


    pop bx
    pop ax
    
    ret
endp updateBirdPlace


proc tubesMovement
    push ax
    

    mov ax, [TUBE1_X_POSITION]
    sub ax, 1
    mov [TUBE1_X_POSITION], ax

    cmp ax, 0
    jge noResetTube1
    call generateTubes
    mov [TUBE1_X_POSITION], 300

noResetTube1:
    mov ax, [TUBE2_X_POSITION]
    sub ax, 1
    mov [TUBE2_X_POSITION], ax
    
    cmp ax, 0
    jge noResetTube2
    call generateTubes
    mov [TUBE2_X_POSITION], 450
    
noResetTube2:
    pop ax
    ret
endp tubesMovement
start:
    mov ax, @data
    mov ds, ax
    
    mov ax, 13h
    int 10h



exit:
    mov ax, 4c00h
    int 21h
END start