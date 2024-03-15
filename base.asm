IDEAL
MODEL small
STACK 100h
DATASEG

    RANDOM_NUMBER dw ?

    GAP dw 50
    SCREEN_HEIGHT dw 200
    BACKGROUND_COLOR db 11
    BLACK_COLOR  db 01

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
    
    call generateRandomNumber
    
    ; upper tube calc
    mov ax, [RANDOM_NUMBER]
    mov [UPPER_TUBE_HEIGHT], ax
    mov bx, [SCREEN_HEIGHT]
    sub bx, ax
    sub bx, [GAP]
    
    mov [LOWER_TUBE_HEIGHT], bx

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
    sub ax, 10
    cmp ax, 0 
    jge new_placing
    mov ax, 0

    new_placing:
        mov [BIRD_Y_POSITION], ax


    no_key_press:
        pop ax
        ret
endp CheckSpacePressed


proc tubesMovement
    push ax
    
    mov ax, [TUBES_X_POSITION]
    sub ax, 1
    mov [TUBES_X_POSITION], ax

    cmp ax, 0
    jge short noResetTubes
    call generateTubesValues
    mov [TUBES_X_POSITION], 310

    noResetTubes:
        pop ax
        ret
endp tubesMovement

proc drawBird
    push ax bx cx dx
    push bp
    mov bp, sp

    sub sp, 4

    tmp_x equ [bp-4]
    tmp_y equ [bp-2]


    

    mov ax, [BIRD_Y_POSITION]
    mov tmp_y, ax ; set original value
    mov cx, [BIRD_HEIGHT]
    outer_loop:
        push cx

        mov ax, [BIRD_X_POSITION]
        mov tmp_x, ax ; set original value
        mov cx, [BIRD_WIDTH]
        inner_loop:
            push cx

            mov cx, tmp_x
            mov dx, tmp_y
            mov al, [BIRD_COLOR]
            mov ah, 0ch
            mov bx, 0                     
            int 10h
            add tmp_x, 1 
     
            pop cx
            loop inner_loop

        add tmp_y, 1
        pop cx  
        loop outer_loop

    add sp, 4
    pop bp dx cx bx ax
    ret 0

endp drawBird

proc drawTubes
    push ax bx cx dx bp
    mov bp, sp
    sub sp, 6
    
    tmp_x equ [bp-4]
    upper_tmp_y equ [bp-2]
    lower_tmp_y equ [bp-6]
    

    upper_tube:
        mov ax, [UPPER_TUBE_Y_POSITION]
        mov upper_tmp_y, ax
        mov cx, [UPPER_TUBE_HEIGHT]
        tube_outer_loop:
            push cx

            mov ax, [TUBES_X_POSITION]
            mov tmp_x, ax
            mov cx, [TUBES_WIDTH]
            tube_inner_loop:
                push cx

                mov cx, tmp_x
                mov dx, upper_tmp_y
                mov al, [TUBES_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h
                inc tmp_x
                
                pop cx
                loop tube_inner_loop

            inc upper_tmp_y
            pop cx  
            loop tube_outer_loop

    lower_tube:
        mov ax, [LOWER_TUBE_Y_POSITION]
        mov lower_tmp_y, ax

        lower_tube_outer_loop:
            push cx

            mov ax, [TUBES_X_POSITION]
            mov tmp_x, ax
            mov cx, [TUBES_WIDTH]
            lower_tube_inner_loop:
                push cx

                mov cx, tmp_x
                mov dx, lower_tmp_y
                mov al, [TUBES_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h
                inc tmp_x
                
                pop cx
                loop lower_tube_inner_loop

            inc tmp_y
            pop cx  
            loop lower_tube_outer_loop

    pop bp dx cx bx ax
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
    cmp ax, [SCREEN_HEIGHT] ; if bird goes above screen height
    jge new_position
    mov ax, [SCREEN_HEIGHT]

    new_position:
        mov [BIRD_Y_POSITION], ax


    pop bx
    pop ax
    ret
endp updateBirdPlace

proc cleanBird
    push ax bx cx dx bp
    
        mov bp, sp

    sub sp, 4

    tmp_x equ [bp-4]
    tmp_y equ [bp-2]
    

    mov ax, [BIRD_Y_POSITION]
    mov tmp_y, ax ; set original value
    mov cx, [BIRD_HEIGHT]
    clean_outer_loop:
        push cx

        mov ax, [BIRD_X_POSITION]
        mov tmp_x, ax ; set original value
        mov cx, [BIRD_WIDTH]
        clean_inner_loop:
            push cx

            mov cx, tmp_x
            mov dx, tmp_y
            mov al, [BLACK_COLOR]
            mov ah, 0ch
            mov bx, 0                     
            int 10h
            add tmp_x, 1 
     
            pop cx
            loop clean_inner_loop

        add tmp_y, 1
        pop cx  
        loop clean_outer_loop

    add sp, 4

    pop bp dx cx bx ax 
    ret 0
endp cleanBird

proc cleanTubes
    push ax bx cx dx bp
    mov bp, sp
    sub sp, 6
    
    tmp_x equ [bp-4]
    upper_tmp_y equ [bp-2]
    lower_tmp_y equ [bp-6]
    

    clean_upper_tube:
        mov ax, [UPPER_TUBE_Y_POSITION]
        mov upper_tmp_y, ax
        mov cx, [UPPER_TUBE_HEIGHT]
        clean_tube_outer_loop:
            push cx

            mov ax, [TUBES_X_POSITION]
            mov tmp_x, ax
            mov cx, [TUBES_WIDTH]
            clean_tube_inner_loop:
                push cx

                mov cx, tmp_x
                mov dx, upper_tmp_y
                mov al, [BLACK_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h
                inc tmp_x
                
                pop cx
                loop clean_tube_inner_loop

            inc upper_tmp_y
            pop cx  
            loop clean_tube_outer_loop

    clean_lower_tube:
        mov ax, [LOWER_TUBE_Y_POSITION]
        mov lower_tmp_y, ax

        clean_lower_tube_outer_loop:
            push cx

            mov ax, [TUBES_X_POSITION]
            mov tmp_x, ax
            mov cx, [TUBES_WIDTH]
            clean_lower_tube_inner_loop:
                push cx

                mov cx, tmp_x
                mov dx, lower_tmp_y
                mov al, [BLACK_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h
                inc tmp_x
                
                pop cx
                loop clean_lower_tube_inner_loop

            inc tmp_y
            pop cx  
            loop clean_lower_tube_outer_loop

    pop bp dx cx bx ax
    ret 0
endp cleanTubes

proc checkCollision
    push ax
    push bx

    mov ax, [TUBES_X_POSITION]
    cmp ax, [BIRD_X_POSITION]
    jne short noCollision

    ; check collision with upper tube
    mov ax, [BIRD_Y_POSITION]   
    cmp ax, [UPPER_TUBE_HEIGHT]
    jle short collision

    ; check collision with lower tube
    mov bx, [SCREEN_HEIGHT]
    sub bx, [LOWER_TUBE_HEIGHT]
    cmp ax, bx
    jge short collision
    
    jmp short noCollision

    collision:
        jmp short exit

    noCollision:
        pop bx
        pop ax
        ret
endp checkCollision

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
    call tubesMovement
    call cleanBird
    call cleanTubes
    call checkCollision

    jmp game_loop


exit:
    mov ax, 03h
    int 10h

    mov ax, 4c00h
    int 21h
END start