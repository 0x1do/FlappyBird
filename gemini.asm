IDEAL
MODEL small
STACK 100h
DATASEG
    x_width dw 50
    y_pos dw 70
    BIRD_SIZE dw 15

CODESEG
proc drawRectangle

    mov al, 05h
    mov ah, 0ch
    mov bh, 0 
    mov cx, [x_width]
    mov dx, 50  ; Set x-coordinate (adjust as needed)
    mov si, [y_pos]  ; Set y-coordinate

    outerLoop:
        mov di, cx  ; Copy width to di register

        innerLoop:
            int 10h
            add si, 1  ; Increment y_pos for the next row
            loop innerLoop  ; Repeat innerLoop cx times

        sub si, cx  ; Reset y_pos for next row
        add si, 1  ; Increment y_pos for next row
        loop outerLoop  ; Repeat outerLoop dx times
    
    ret
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
