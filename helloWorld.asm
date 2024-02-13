IDEAL
MODEL small
STACK 100h
DATASEG
    msg db 'hello world$'
CODESEG
main:
    mov ax, @data
    mov ds, ax
    lea dx, [msg]
    mov ah, 9h
    int 21h
exit:
    mov ax, 4c00h
    int 21h
END main