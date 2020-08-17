#ifndef FUCKOS_H
#define FUCKOS_H

#define NULL 0

#define VGA_ADDRESS 0xB8000
#define BUFSIZE 2200
#define STR_NAME "Fuck OS"
#define STR_VER "2.0"
#define STR_MSG "Please type your command..."
#define PROMPT ">>> "

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;

uint16* vga_buffer;

enum vga_color {
    BLACK,
    BLUE,
    GREEN,
    CYAN,
    RED,
    MAGENTA,
    BROWN,
    GREY,
    DARK_GREY,
    BRIGHT_BLUE,
    BRIGHT_GREEN,
    BRIGHT_CYAN,
    BRIGHT_RED,
    BRIGHT_MAGENTA,
    YELLOW,
    WHITE,
};

#endif