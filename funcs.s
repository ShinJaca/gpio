@ Opens the /dev/gpiomem device and maps GPIO memory
@ into program virtual address space.
@ 2017-09-29: Bob Plantz


@ Define my Raspberry Pi
        @ .cpu    arm1176jz-s
        .cpu    cortex-a7
        .syntax unified         @ modern syntax

@ Constants for assembler
@ The following are defined in /usr/include/asm-generic/fcntl.h:
@ Note that the values are specified in octal.
        .equ    O_RDWR,00000002   @ open for read/write
        .equ    O_DSYNC,00010000  @ synchronize virtual memory
        .equ    __O_SYNC,04000000 @      programming changes with
        .equ    O_SYNC,__O_SYNC|O_DSYNC @ I/O memory
@ The following are defined in /usr/include/asm-generic/mman-common.h:
        .equ    PROT_READ,0x1   @ page can be read
        .equ    PROT_WRITE,0x2  @ page can be written
        .equ    MAP_SHARED,0x01 @ share changes

@ The following are defined by me:
        .equ    PERIPH,0x3f000000   @ RPi 2 & 3 peripherals
        @ .equ    PERIPH,0x20000000   @ RPi zero & 1 peripherals
        .equ    O_FLAGS,O_RDWR|O_SYNC @ open file flags
        .equ    PROT_RDWR,PROT_READ|PROT_WRITE
        .equ    NO_PREF,0
        .equ    PAGE_SIZE,4096  @ Raspbian memory page
        .equ    FILE_DESCRP_ARG,0   @ file descriptor
        .equ    DEVICE_ARG,4        @ device address
        .equ    STACK_ARGS,8    @ sp already 8-byte aligned

@ Endereços e offsets para oum GPIO
        .equ    GPIO_OFFSET,0x200000    @ start of GPIO device
        .equ    GPFSEL0,0x0             @ Offset do reg GPFSEL0
        .equ    GPFSEL1,0x4             
        .equ    GPFSEL2,0x8             
        .equ    GPFSEL3,0xC             
        .equ    GPFSEL4,0x10             
        .equ    GPFSEL5,0x14             
        .equ    GPCLR0,0x28             @
        .equ    GPCLR1,0x2C             @
        .equ    GPSET0,0x1c             @
        .equ    GPSET1,0x20             @

        .equ    FSEL_OUTPUT,0b001       @ Bits de modo de OUTPUT
        .equ    FSEL_MASK,  0b111

@ Endereços e offsets para o TIMER
        .equ    TIMER_OFFSET,0x3000  @ start of GPIO device
        .equ    TCLO,0x4
        .equ    TCHI,0x8

    
@ Constant program data
        .section .rodata
        .align  2
device:
        @ .asciz  "/dev/gpiomem"
        .asciz  "/dev/mem"

        .text
        .align  2
        .global _openfile
        @ .type   _config, %macro

.macro _openfile filedesc_adr
        ldr     r0, deviceAddr  @ address of /dev/gpiomem
        ldr     r1, openMode    @ flags for accessing device
        bl      open
        ldr     r4, \filedesc_adr
        str     r0, [r4]
.endm

        .global _memmap

.macro _memmap base_adr, filedesc_reg, mappedadr_adr
@ Map the address registers to a virtual memory location so we c[an access them        
        str     \filedesc_reg, [sp, FILE_DESCRP_ARG] @ /dev/mem file descriptor
        ldr     r0, \base_adr        @ address of GPIO
        str     r0, [sp, DEVICE_ARG]      @ location of GPIO
        mov     r0, NO_PREF     @ let kernel pick memory
        mov     r1, PAGE_SIZE   @ get 1 page of memory
        mov     r2, PROT_RDWR   @ read/write this memory
        mov     r3, MAP_SHARED  @ share with other processes
        bl      mmap
        ldr     r1, \mappedadr_adr
        str     r0, [r1]
.endm

.macro _setreg port_adr, regmask, data, data_pos
        ldr r0, \port_adr
        ldr r0, [r0] 
        mov r1, \regmask
        @ mov r2, \data_pos
        bic r0, r0, r1, lsl \data_pos
        mov r1, \data
        lsl r1, r1, \data_pos
        orr r0, r0, r1
        ldr r1, \port_adr
        str r0, [r1]
.endm   


deviceAddr:
        .word   device
openMode:
        .word   O_FLAGS

gpio:
        .word   PERIPH+GPIO_OFFSET
timer:
        .word   PERIPH+TIMER_OFFSET



        