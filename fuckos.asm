main:

        cli ;clear interrupts
        mov ax, 0x00
        mov ss, ax
        mov sp, 0x0ffff
        sti ;restore interrupts
        cld
        mov ax, 0x2000
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax

        mov ax, 0x01; 40 x 25 video mode
        int 0x10
        call cls

        mov dh, 0x0a
        mov dl, 0x0c
        call set_cursor_position

        mov si, os_name
        mov bl, 0x05
        call print_string

        mov dl, 0x0c
        call set_cursor_position
        mov si, by_text
        call print_string

        inc dh
        mov dl, 0x07
        call set_cursor_position

        mov bl, 0x0e
        mov si, key_text
        call print_string

        call getch

        mov ax, 0x03; 80 x 25 video mode
        int 0x10
        call cls

        mov bx, os_name
        call print_normal_string

        mov bx, please_type
        call print_normal_string

show_prompt:
        mov bx, prompt
        call print_normal_string

        jmp $

; bx = string to print
print_normal_string:
        pusha
.start:
        mov al, [bx]
        cmp al, 0
        je .ok
        cmp al, 1
        je .ok2

        mov ah, 0x0e
        
        int 0x10
        add bx, 1
        jmp .start

.ok:
        call newline
        popa
        ret
.ok2:
        popa
        ret

newline:
        mov al, 13
        int 0x10
        mov al, 10
        int 0x10
        ret

; si = string to print
print_string:

.print:
        mov ah, 0x09
        mov cx, 0x01 ;one character
        lodsb
        cmp al, 0x00
        je .return
        int 0x10
        call get_cursor_position
        inc dl ;increment column
        call set_cursor_position
        jmp .print
.return
        call get_cursor_position
        inc dh ;increment row (newline?)
        mov dl, 0x00 ;set column to 0
        call set_cursor_position
        ret

cls:
        pusha
        mov dx, 0x00
        call set_cursor_position
        mov ah, 0x06
        mov al, 0x00
        mov bh, 0x07
        mov cx, 0x00
        mov dh, 0x18
        mov dl, 0x4f
        int 0x10
        popa
        ret

; bh = page number (0..7)
; dh = row
; dl = column
; ch = cursor start line
; cl = cursor bottom line
set_cursor_position:
        pusha
        mov ah, 0x02
        mov bh, 0x00
        int 0x10
        popa
        ret

; bh = page number
; dh = row
; dl = column
; ch = cursor start line
; cl = cursor bottom line
get_cursor_position:
        mov ah, 0x03
        mov bh, 0x00
        int 0x10
        ret

; ax = keypressed
getch:
        mov ah, 0x11
        int 0x16
        jnz .key_pressed
        hlt
        jmp getch

.key_pressed:
        mov ah, 0x10
        int 0x16
        ret

os_name:
        db "Fuck OS 1.0", 0x00
by_text:
        db "By: F. E. Silva", 0x00

please_type:
        db "Please type your command...", 0x00

prompt:
        db ">>> ", 0x01

key_text:
        db "Press any key to continue", 0x00