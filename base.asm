IDEAL
MODEL small
STACK 100h
DATASEG

    RANDOM_NUMBER dw ?

    GAP dw 50
    SCREEN_HEIGHT dw 200
    BACKGROUND_COLOR db 11

    ; tubes variables:
    TUBES_COLOR db 14
    TUBES_WIDTH dw 15
    TUBES_X_POSITION dw 275
    UPPER_TUBE_Y_POSITION dw 0
    LOWER_TUBE_Y_POSITION dw 50 ; GAP size
    LOWER_TUBE_HEIGHT dw 75
    UPPER_TUBE_HEIGHT dw 75
    
    ; bird variables:
    BIRD_COLOR db 7
    BIRD_WIDTH dw 15
    BIRD_HEIGHT dw 15
    BIRD_X_POSITION dw 100
    BIRD_Y_POSITION dw 90
    
    VELOCITY dw 1
CODESEG

proc generateRandomNumber
    push ax
    push bx

    mov bx, [SCREEN_HEIGHT]
    sub bx, [GAP]
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
    push ax
    push bx
    
    ;call generateRandomNumber
    
    mov ax, [UPPER_TUBE_HEIGHT]
    add [LOWER_TUBE_HEIGHT], ax


    ; mov ax, [RANDOM_NUMBER]
    ; mov [TUBE1_Y_POSITION], ax
    ; mov bx, [SCREEN_HEIGHT]
    ; sub bx, [TUBE1_Y_POSITION]
    ; sub bx, [GAP]
    ; mov [TUBE2_Y_POSITION], bx

    pop bx
    pop ax
    ret
endp generateTubesValues

proc CheckSpacePressed
    push ax

    mov ah, 01h  ; Check if a key has been pressed
    int 16h
    jz no_key_press ; Jump if no key is pressed
    mov ah, 00h  ; Get the key pressed
    int 16h
    cmp al, 32    ; Compare with space key
    jne no_key_press

    mov ax, [BIRD_Y_POSITION]
    sub ax, 15
    cmp ax, 0 
    jge new_placing
    mov ax,0

    new_placing:
        mov [BIRD_Y_POSITION], ax


    no_key_press:
        pop ax
        ret
endp CheckSpacePressed


proc tubesMovement
    push ax
    
    mov ax, [TUBE1_X_POSITION]
    sub ax, 1
    mov [TUBE1_X_POSITION], ax
    mov [TUBE2_X_POSITION], ax

    cmp ax, 0
    jge noResetTubes
    call generateTubesValues
    mov [TUBE1_X_POSITION], 300
    mov [TUBE2_X_POSITION], 300
    
    noResetTubes:
        pop ax
        ret
endp tubesMovement

proc checkCollision
    push ax
    push bx

    mov ax, [TUBE1_X_POSITION]
    cmp ax, [BIRD_X_POSITION]
    jne near noCollision

    mov ax, [BIRD_Y_POSITION]
    mov bx, [TUBE1_Y_POSITION]
    add bx, [GAP]
    cmp ax, bx
    jl near collision

    mov bx, [TUBE2_Y_POSITION]
    cmp ax, bx
    jl near collision
    
    jmp near noCollision

    collision:
        jmp near exit

    noCollision:
        pop bx
        pop ax
        ret
endp checkCollision

proc drawBird
    push ax
    push bx
    push cx
    push dx

    mov [BIRD_Y_POSITION], 90
    mov cx, [BIRD_HEIGHT]
    outer_loop:
        push cx

        mov [BIRD_X_POSITION], 50 ; original value
        mov cx, [BIRD_WIDTH]
        inner_loop:
            push cx

            mov cx, [BIRD_X_POSITION]
            mov dx, [BIRD_Y_POSITION]
            mov al, [BIRD_COLOR]
            mov ah, 0ch
            mov bx, 0                     
            int 10h
            inc [BIRD_X_POSITION]
            
            pop cx
            loop inner_loop

        inc [BIRD_Y_POSITION]
        pop cx  
        loop outer_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret 0

endp drawBird

proc drawTubes
    push ax
    push bx
    push cx
    push dx

    upper_tube:
        mov [UPPER_TUBE_Y_POSITION], 0
        mov cx, [UPPER_TUBE_HEIGHT]
        tube_outer_loop:
            push cx

            mov [TUBES_X_POSITION], 275 ; original value
            mov cx, [TUBES_WIDTH]
            tube_inner_loop:
                push cx

                mov cx, [TUBES_X_POSITION]
                mov dx, [UPPER_TUBE_Y_POSITION]
                mov al, [TUBES_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h
                inc [TUBES_X_POSITION]
                
                pop cx
                loop tube_inner_loop

            inc [UPPER_TUBE_Y_POSITION]
            pop cx  
            loop tube_outer_loop

    lower_tube:
        mov [LOWER_TUBE_Y_POSITION], 125
        mov cx, [LOWER_TUBE_HEIGHT]
        lower_tube_outer_loop:
            push cx

            mov [TUBES_X_POSITION], 275 ; original value
            mov cx, [TUBES_WIDTH]
            lower_tube_inner_loop:
                push cx

                mov cx, [TUBES_X_POSITION]
                mov dx, [LOWER_TUBE_Y_POSITION]
                mov al, [TUBES_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h
                inc [TUBES_X_POSITION]
                
                pop cx
                loop lower_tube_inner_loop

            inc [LOWER_TUBE_Y_POSITION]
            pop cx  
            loop lower_tube_outer_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret 0

endp drawTubes

proc updateBirdPlace
    push ax
    push bx
    
    ; gravity
    mov ax, [VELOCITY]
    add ax, 1
    cmp ax, 5 ; so the falling wont be too fast
    jle velocity_fine
    mov ax, 5

    velocity_fine:
        mov [VELOCITY], ax
        mov ax, [BIRD_Y_POSITION]
        add ax, [VELOCITY] ; pushing the bird down
        cmp ax, 0 ; if bird goes above screen height
        jge new_position
        mov ax, 0

    new_position:
        cmp ax, [SCREEN_HEIGHT] ; if bird goes below the screen
        jle placing_update
        mov ax, [SCREEN_HEIGHT]

    placing_update:
        mov [BIRD_Y_POSITION], ax


    pop bx
    pop ax
    ret
endp updateBirdPlace

start:
    mov ax, @data
    mov ds, ax
    
    mov ax, 13h
    int 10h

game_loop:
    ;call generateTubesValues
    call drawTubes 
    call drawBird
    call checkSpacePressed
    call updateBirdPlace
    ;call tubesMovement

    ;call checkCollision

    jmp game_loop



exit:
    mov ax, 03h
    int 10h

    mov ax, 4c00h
    int 21h
END start