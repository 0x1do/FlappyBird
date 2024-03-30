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
    sub ax, 1
    cmp ax, 0 
    jge new_placing
    mov ax, 0

    new_placing:
        mov [BIRD_Y_POSITION], ax



    
    ; gravity
    sub [VELOCITY], 1
    cmp [VELOCITY], -7
    jle position_up
    mov [VELOCITY], -7

    position_up:
        mov ax, [VELOCITY]
        add [BIRD_Y_POSITION], ax


    call drawbird

    no_key_press:
        pop ax
        ret
endp CheckSpacePressed


proc tubesMovement
    push ax bx cx dx bp

    mov ax, [TUBES_X_POSITION]
    sub ax, 3
    mov [TUBES_X_POSITION], ax

    pop bp dx cx bx ax
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



proc birdGoingUp
    push ax bx cx dx bp 
    mov bp, sp
    sub sp, 4

    tmp_x equ [bp-4]
    tmp_y equ [bp-2]
    

    ; erase lower row
    mov ax, [BIRD_Y_POSITION]
    mov tmp_y, ax
    mov ax, [BIRD_HEIGHT]
    add tmp_y, ax
    mov ax, [BIRD_X_POSITION]
    mov tmp_x, ax

    mov cx, [BIRD_HEIGHT]
    erase_lower_row:
        push cx 

        mov cx, tmp_x
        mov dx, tmp_y
        mov al, [BLACK_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h
        inc tmp_x
        
        pop cx
        loop erase_lower_row


    ; add upper row
    mov ax, [BIRD_Y_POSITION]
    mov tmp_y, ax
    mov ax, [BIRD_X_POSITION]
    mov tmp_x, ax
    
    mov cx, [BIRD_HEIGHT]
    append_upper_row:
        push cx 

        mov cx, tmp_x
        mov dx, tmp_y
        mov al, [BIRD_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h
        inc tmp_x
        
        pop cx
        loop append_upper_row


    add sp, 4

    pop bp dx cx bx ax 
    ret 0
endp birdGoingUp

proc birdGoingDown
    push ax bx cx dx bp 
    mov bp, sp
    sub sp, 4

    tmp_x equ [bp-4]
    tmp_y equ [bp-2]
    


    ; erase upper row
    mov ax, [BIRD_Y_POSITION]
    mov tmp_y, ax
    mov ax, [BIRD_HEIGHT]
    add tmp_y, ax
    mov ax, [BIRD_X_POSITION]
    mov tmp_x, ax

    mov cx, [BIRD_HEIGHT]
    erase_upper_row:
        push cx 

        mov cx, tmp_x
        mov dx, tmp_y
        mov al, [BIRD_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h
        inc tmp_x
        
        pop cx
        loop erase_upper_row


    ; add lower row
    mov ax, [BIRD_Y_POSITION]
    mov tmp_y, ax
    mov ax, [BIRD_X_POSITION]
    mov tmp_x, ax
    
    mov cx, [BIRD_HEIGHT]
    append_lower_row:
        push cx 

        mov cx, tmp_x
        mov dx, tmp_y
        mov al, [BLACK_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h
        inc tmp_x
        
        pop cx
        loop append_lower_row


    add sp, 4

    pop bp dx cx bx ax 
    ret 0
endp birdGoingDown

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


proc updateTubes
    push ax bx cx dx bp
    mov bp, sp
    sub sp, 6


    tmp_x equ [bp-2]
    lower_tmp_y equ [bp-4]
    upper_tmp_y equ [bp-6]



    ; erase upper tube
    mov ax, [UPPER_TUBE_Y_POSITION]
    mov upper_tmp_y, ax
    mov ax, [TUBES_X_POSITION]
    mov tmp_x, ax
    mov ax, [TUBES_WIDTH]
    add tmp_x, ax
    mov cx, [UPPER_TUBE_HEIGHT]
    erase_upper:
        push cx 
    
        mov cx, tmp_x
        mov dx, upper_tmp_y
        mov al, [BLACK_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h
        inc upper_tmp_y
        
        pop cx
        loop erase_upper


    ; erase lower tube
    mov ax, [LOWER_TUBE_Y_POSITION]
    mov lower_tmp_y, ax
    mov ax, [TUBES_X_POSITION]
    mov tmp_x, ax
    mov ax, [TUBES_WIDTH]
    add tmp_x, ax
    mov cx, [LOWER_TUBE_HEIGHT]
    erase_lower:
        push cx 

        mov cx, tmp_x
        mov dx, lower_tmp_y
        mov al, [BLACK_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h
        inc lower_tmp_y
        
        pop cx
        loop erase_lower


    ; add to the upper tube
    mov ax, [UPPER_TUBE_Y_POSITION]
    mov upper_tmp_y, ax
    mov ax, [TUBES_X_POSITION]
    mov tmp_x, ax
    mov cx, [UPPER_TUBE_HEIGHT]
    append_upper:
        push cx 

        mov cx, tmp_x
        mov dx, upper_tmp_y
        mov al, [TUBES_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h 
        inc upper_tmp_y
         
        pop cx
        loop append_upper


    ; add to the lower tube
    mov ax, [LOWER_TUBE_Y_POSITION]
    mov lower_tmp_y, ax
    mov ax, [TUBES_X_POSITION]
    mov tmp_x, ax
    mov cx, [LOWER_TUBE_HEIGHT]
    append_lower:
        push cx 

        mov cx, tmp_x
        mov dx, lower_tmp_y
        mov al, [TUBES_COLOR]
        mov ah, 0ch
        mov bx, 0
        int 10h 
        inc lower_tmp_y
        
        pop cx
        loop append_lower


    add sp, 6
    pop bp dx cx bx ax
    ret 0
endp updateTubes

proc checkCollision
    push ax
    push bx

    ; check collision with ceiling
    mov ax, [screen_height]
    sub ax, 15
    mov bx, [BIRD_Y_POSITION]
    cmp bx, ax
    jge collision
    
    ; check collision with floor
    cmp bx, 0
    jle collision


    mov ax, [TUBES_X_POSITION]
    cmp ax, [BIRD_X_POSITION]
    jne noCollision

    ; check collision with upper tube
    mov ax, [BIRD_Y_POSITION]   
    mov bx, [UPPER_TUBE_Y_POSITION]
    add bx, [UPPER_TUBE_HEIGHT]
    cmp ax, bx
    jle collision

    ; check collision with lower tube
    mov bx, [SCREEN_HEIGHT]
    sub bx, [LOWER_TUBE_HEIGHT]
    cmp ax, bx
    jge collision
    
    jmp noCollision

    collision:
        jmp exit

    noCollision:
        pop bx
        pop ax
        ret
endp checkCollision


proc updateBirdPlace
    push ax

    ; gravity
    add [VELOCITY], 1
    cmp [VELOCITY], 1
    jle position_down
    mov [VELOCITY], 1

    position_down:
        mov ax, [VELOCITY]
        add [BIRD_Y_POSITION], ax

    ;call cleanbird

    pop ax
    ret
endp updateBirdPlace

proc drawTubes
    push ax bx cx dx bp
    mov bp, sp
    sub sp, 6
    
    tmp_x equ [bp-4]
    upper_tmp_y equ [bp-2]
    lower_tmp_y equ [bp-6]
    

    upper_tube:
            mov ax, [TUBES_X_POSITION]
            mov tmp_x, ax
            mov cx, [TUBES_WIDTH]

        tube_outer_loop:
            push cx

            mov ax, [UPPER_TUBE_Y_POSITION]
            mov upper_tmp_y, ax
            mov cx, [UPPER_TUBE_HEIGHT]
            tube_inner_loop:
                push cx

                mov cx, tmp_x
                mov dx, upper_tmp_y
                mov al, [TUBES_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h ; drawing a pixel
                inc upper_tmp_y
                
                pop cx
                loop tube_inner_loop

            inc tmp_x
            pop cx  
            loop tube_outer_loop

    lower_tube:

        mov ax, [TUBES_X_POSITION]
        mov tmp_x, ax
        mov cx, [TUBES_WIDTH]
        
        lower_tube_outer_loop:
            push cx

            mov ax, [LOWER_TUBE_Y_POSITION]
            mov lower_tmp_y, ax
            mov cx, [LOWER_TUBE_HEIGHT]
            lower_tube_inner_loop:
                push cx

                mov cx, tmp_x
                mov dx, lower_tmp_y
                mov al, [TUBES_COLOR]
                mov ah, 0ch
                mov bx, 0                     
                int 10h
                inc lower_tmp_y
                
                pop cx
                loop lower_tube_inner_loop

            inc tmp_x
            pop cx  
            loop lower_tube_outer_loop

    add sp, 6
    pop bp dx cx bx ax
    ret 0

endp drawTubes

proc generateNewTubes
    call generateTubesValues
    call drawTubes
    mov [TUBES_X_POSITION], 300
endp generateNewTubes

start:
    mov ax, @data
    mov ds, ax
    
    mov ax, 13h
    int 10h

    call drawtubes
    call drawBird
game_loop:
    
    mov ax, [TUBES_X_POSITION]
    cmp ax, 20
    je generateNewTubes

    sleep:
        mov cx, 40000    
        sleep_loop:
            loop sleep_loop


    call updateTubes
    mov ax, [TUBES_X_POSITION]
    dec ax
    mov [TUBES_X_POSITION], ax
    call checkSpacePressed
    call drawbird
    call cleanbird
    call updateBirdPlace
    call drawbird
    call checkCollision
    call cleanbird
    jmp game_loop

exit:
    mov ax, 03h
    int 10h

    mov ax, 4c00h
    int 21h
END start