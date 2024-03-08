IDEAL
MODEL small
STACK 100h
DATASEG

    RANDOM_NUMBER dw ?

    GAP dw 50
    SCREEN_HEIGHT dw 200

    TUBE_COLOR db 14
    BACKGROUND_COLOR db 11
    BIRD_COLOR db 10
    
    BIRD_SIZE dw 15

    BIRD_X_POSITION dw 120
    BIRD_Y_POSITION dw 100

    TUBES_WIDTH dw 15
    TUBE1_X_POSITION dw 300
    TUBE1_Y_POSITION dw 75

    TUBE2_X_POSITION dw 300
    TUBE2_Y_POSITION dw 125
    
    VELOCITY dw 1
CODESEG

proc generateRandomNumber
    push ax
    push bx

    mov bx, [SCREEN_HEIGHT]
    sub bx, [GAP]
    sub bx, 1 ; bl now contains the highest length tube1 can be
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

proc generateTubes
    push ax
    push bx
    
    call generateRandomNumber

    mov ax, [RANDOM_NUMBER]
    mov [TUBE1_Y_POSITION], ax
    mov bx, [SCREEN_HEIGHT]
    sub bx, [TUBE1_Y_POSITION]
    sub bx, [GAP]
    mov [TUBE2_Y_POSITION], bx

    pop bx
    pop ax
    ret
endp generateTubes

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
    call generateTubes
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

proc drawSquare
    push ax
    push bx
    push cx
    push dx

    ; Use local variables for better readability
    mov ax, [BIRD_X_POSITION]
    mov bx, [BIRD_Y_POSITION]
    mov cx, [BIRD_SIZE]

draw_loop:
    push cx
    
    ; Use local variables
    mov cx, [BIRD_SIZE]
    mov dx, bx    

inner_loop:
    mov ah, 0ch
    mov al, [BIRD_COLOR]
    int 10h

    add dx, 1 ; next y pixel
    loop inner_loop
    
    add ax, 1 ; next x pixel
    pop cx
    loop draw_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp drawSquare

proc drawTube
    push ax
    push bx
    push cx
    push dx

    ; Drawing the upper tube
    mov ax, [TUBE1_X_POSITION] ; Tube's X position
    mov cx, [TUBES_WIDTH]      ; Tube width
    mov dx, 0                  ; Start at the top of the screen

upper_tube_loop:
    push cx
    mov bx, dx                ; Y position

    mov cx, [TUBE1_Y_POSITION]
    sub cx, dx                ; Height of the upper tube
    jz lower_tube_start       ; Skip if height is zero

draw_upper_tube_pixel:
    mov ah, 0Ch               ; Function to plot a pixel
    mov al, [TUBE_COLOR]      
    int 10h                  

    inc bx                    ; Move to the next pixel
    loop draw_upper_tube_pixel

    pop cx
    inc ax                    ; Move to the next column
    cmp ax, [TUBE1_X_POSITION]
    add ax, [TUBES_WIDTH]
    jl upper_tube_loop

lower_tube_start:
    ; Adjust the starting Y of the lower tube
    mov dx, [TUBE1_Y_POSITION]
    add dx, [GAP]

    mov ax, [TUBE1_X_POSITION] ; Tube X
    mov cx, [TUBES_WIDTH]      ; Tube width

lower_tube_loop:
    push cx
    mov bx, dx                ; Y position for the lower tube

    mov cx, [SCREEN_HEIGHT]   ; Bottom of the screen
    sub cx, dx                ; Height of the lower tube
    jz end_draw               ; Skip if height is zero

draw_lower_tube_pixel:
    mov ah, 0Ch              
    mov al, [TUBE_COLOR]   
    int 10h                   

    inc bx                    ; Move to the next pixel
    loop draw_lower_tube_pixel

    pop cx
    inc ax                    ; Move to the next column
    cmp ax, [TUBE1_X_POSITION]
    add ax, [TUBES_WIDTH]
    jl lower_tube_loop

end_draw:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp drawTube

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
    call drawTube         ; Tube1
    call drawTube         ; Tube2
    call drawSquare       ; Draw bird
    call checkSpacePressed
    call updateBirdPlace
    call tubesMovement

    call checkCollision

    jmp game_loop



exit:
    mov ax, 03h
    int 10h

    mov ax, 4c00h
    int 21h
END start