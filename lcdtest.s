@ Opens the /dev/gpiomem device and maps GPIO memory
@ into program virtual address space.
@ 2017-09-29: Bob Plantz 


.include "funcs.s"

@ Define my Raspberry Pi
        @ .cpu    arm1176jz-s
        .cpu    cortex-a7
        .syntax unified         @ modern syntax

        .equ    FSEL08, 24
        .equ    FSEL12, 6
        .equ    FSEL16, 18
        .equ    FSEL20, 0
        .equ    FSEL21, 3
        .equ    FSEL25, 15

        .equ    OUTMODE, 0b001
        .equ    REGMASK, 0b111

        .equ    GPIO12, 12
        .equ    GPIO16, 16
        .equ    GPIO20, 20
        .equ    GPIO21, 21
        .equ    RS,     25
        .equ    EN,     8



@ Constant program data
        .section .rodata
        .align  2


@ The program
        .text
        .align  2
        .global main
        .type   main, %function
main:
        sub     sp, sp, 16      @ space for saving regs
        str     r4, [sp, 0]     @ save r4
        str     r5, [sp, 4]     @      r5
        str     fp, [sp, 8]     @      fp
        str     lr, [sp, 12]    @      lr
        add     fp, sp, 12      @ set our frame pointer
        sub     sp, sp, STACK_ARGS @ sp on 8-byte boundary
openfile:       @ Abertura do arquivo de espelahamento de memoria /dev/mem
        _openfile fileDescriptor_adr
memorymap:      @ Mapeamento de memória para GPIO
        _memmap gpio, r0, mappedAdress_adr
gpioconfig:     @ configuração de modo dos GPIOs
        @ Gpios do banco GPFSEL2
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL20
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL21
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL25
        @ ldr r0, 





        .align  2


fileDescriptor_adr:     .word fileDescriptor
mappedAdress_adr:       .word mappedAdress
GPORT_adr:              .word GPORT             @ Armazena os bits antes de enviar

.data
        fileDescriptor: .word 0
        mappedAdress:   .word 0
        GPORT:          .word 0


