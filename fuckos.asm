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

        mov si, os_name
        call print_normal_string
        call newline

        mov si, please_type
        call print_normal_string
        call newline

show_prompt:
        mov di, cmd
        mov cx, 32
        rep stosb

        mov si, prompt
        call print_normal_string

        mov ax, chars
        mov bx, 64
        call readline

        call newline

        mov ax, chars
        call trim

        mov si, chars
        cmp byte [si], 0
        je show_prompt

        jmp $

; si = string to print
print_normal_string:
        pusha
        mov ah, 0Eh

.repeat:
        lodsb
        cmp al, 0
        je .done

        int 10h
        jmp .repeat

.done:
        popa
        ret

newline:
        pusha
        mov ah, 0Eh
        mov al, 13
        int 10h
        mov al, 10
        int 10h
        popa
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
.return:
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
        pusha
        mov ah, 0x03
        mov bh, 0x00
        int 0x10

        mov [.tmp], dx
        popa
        mov dx, [.tmp]

        ret

.tmp:
        dw 0

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

; based on MikeOS os_input_string
; ax = output address
; bx = max bytes of output string
readline:
        pusha
        cmp bx, 0x00
        je .done
        mov di, ax
        dec bx
        mov cx, bx

.get_char:
        call getch
        cmp al, 8
        je .backspace

        cmp al, 13
        je .end_string

        jcxz .get_char

        cmp al, ' '
        jb .get_char

        cmp al, 126
        ja .get_char

        call .add_char

        dec cx
        jmp .get_char

.end_string:
        mov al, 0
        stosb

.done:
        popa
        ret

.backspace:
        cmp cx, bx 
        jae .get_char
        inc cx
        call .reverse_cursor
        mov al, ' '
        call .add_char
        call .reverse_cursor
        jmp .get_char

.reverse_cursor:
        dec di 
        call get_cursor_position
        cmp dl, 0
        je .back_line

        dec dl
        call set_cursor_position
        ret

.back_line:
        dec dh
        mov dl, 79
        call set_cursor_position
        ret

.add_char:
        stosb
        mov ah, 0x0E
        mov bh, 0
        push bp
        int 0x10
        pop bp
        ret

; ax = location of string
trim:
        pusha
        mov dx, ax
        mov di, ax
        mov cx, 0

.keepcounting:
        cmp byte [di], ' '
        jne .counted
        inc cx
        inc di
        jmp .keepcounting

.counted:
        cmp cx, 0
        je .finished_copy
        mov si, di
        mov di, dx

.keep_copying:
        mov al, [si]
        mov [di], al
        cmp al, 0
        je .finished_copy
        inc si
        inc di
        jmp .keep_copying

.finished_copy:
        mov ax, dx
        call str_len
        cmp ax, 0
        je .done_trimming
        mov si, dx
        add si, ax

.more:
        dec si
        cmp byte [si], ' '
        jne .done_trimming
        mov byte [si], 0
        jmp .more

.done_trimming:
        popa
        ret

str_len:
        pusha
        mov bx, ax
        mov cx, 04

.process_str_len:
        cmp byte [bx], 0
        je .done_str_len
        inc bx
        inc cx
        jmp .process_str_len

.done_str_len:
        mov word [.tmp_counter], cx
        popa
        mov ax, [.tmp_counter]
        ret

.tmp_counter:
        dw 0

os_name:
        db "Fuck OS 1.0", 0x00
by_text:
        db "By: F. E. Silva", 0x00

please_type:
        db "Please type your command...", 0x00

prompt:
        db ">>> ", 0x00

key_text:
        db "Press any key to continue", 0x00

chars:
        times 64 db 0
cmd:
        times 32 db 0