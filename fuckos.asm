os_main:
        cli
        mov ah, 0x0e
        mov al, 'f'
        int 0x10
        mov al, 'u'
        int 0x10
        mov al, 'c'
        int 0x10
        mov al, 'k'
        int 0x10

        jmp $