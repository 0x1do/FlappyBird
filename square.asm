IDEAL
MODEL small
STACK 100h
DATASEG
    x_BIRD dw 10
    y_BIRD dw 5
    BIRD_WIDTH dw 5
    BIRD_HEIGHT dw 5

CODESEG
proc drawRectangle
    push ax
    push bx
    push cx
    push dx


    outer_loop:
    push cx
        mov [y_bird], 10
        mov [x_bird], 10 ; original value
        mov cx, 15
        inner_loop:
            push cx

            mov cx, [x_bird]
            mov dx, [y_bird]
            mov al, 05h ; color
            mov ah, 0ch
            mov bx, 0
            int 10h
            inc [x_bird]
            
            pop cx
            loop inner_loop

        inc [y_bird]
        pop cx  
        loop outer_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret 0

endp drawRectangle


start:
    mov ax, @data
    mov ds, ax
    
    mov ax, 13h
    int 10h
game_loop:
    call drawRectangle

    jmp game_loop


exit:
    mov ah, 00h
    mov al, 2h
    int 10h

    mov ax, 4c00h
    int 21h
END start