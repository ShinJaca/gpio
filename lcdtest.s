@ Opens the /dev/gpiomem device and maps GPIO memory
@ into program virtual address space.
@ 2017-09-29: Bob Plantz 


.include "funcs.s"
.include "lcd_instructions.s"

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

        .equ    ENPIN,  0x100
        .equ    RSPIN,  0x2000000

        .equ    INTERVALO, 5000
        .equ    PULSEINT, 10

        .equ    CLEANMASK, 0x2311100


@ Constant program data
        .section .rodata
        .align  2


@ The program
        .text
        .align  2
_pulseEnable:
        mov r10, ENPIN
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r10, [r12, GPCLR0]

        udelay PULSEINT, tmAddress_adr

        mov r10, ENPIN
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r10, [r12, GPSET0]

        udelay PULSEINT, tmAddress_adr

        mov r10, ENPIN
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r10, [r12, GPCLR0]

        bx  lr

_write4bits:
         _mapbitsToPort4 r0, GPORT_adr
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        ldr r11, GPORT_adr
        ldr r11, [r11]
        str r11, [r12, GPSET0]

        bx lr

_clean4bits:
        _mapbitsToPort4 r0, GPORT_adr
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        ldr r11, GPORT_adr
        ldr r11, [r11]
        str r11, [r12, GPCLR0]
        ldr r11, GPORT_adr
        mov r10, #0
        str r10, [r11]

        bx lr

_setmode8:
        mov r0, STMODE
        bl _write4bits

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _pulseEnable

        mov r6, #30
        udelay r6, tmAddress_adr

        mov r0, STMODE
        bl _clean4bits

        mov r6, #4500
        udelay r6, tmAddress_adr

        bx lr


.macro sendCmd CMD
        @ Primeiro os bits altos
        mov r0, \CMD
        lsr r0, #4
        bl _write4bits

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _pulseEnable

        mov r6, #100
        udelay r6, tmAddress_adr

        mov r0, \CMD
        lsr r0, #4
        bl _clean4bits
        
        
        @ Segundo os bits baixos
        mov r0, \CMD
        bl _write4bits

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _pulseEnable

        mov r6, #100
        udelay r6, tmAddress_adr

        mov r0, \CMD
        bl _clean4bits
.endm

.macro sendData CMD

        ldr r0, gpioAddress_adr
        ldr r0, [r0]
        mov r1, RSPIN
        str r1, [r0, GPSET0]

        @ Primeiro os bits altos
        mov r0, \CMD
        lsr r0, #4
        bl _write4bits

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _pulseEnable

        mov r6, #30
        udelay r6, tmAddress_adr

        mov r0, \CMD
        lsr r0, #4
        bl _clean4bits
        
        
        @ Segundo os bits baixos
        mov r0, \CMD
        bl _write4bits

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _pulseEnable

        mov r6, #30
        udelay r6, tmAddress_adr

        mov r0, \CMD
        bl _clean4bits

        ldr r0, gpioAddress_adr
        ldr r0, [r0]
        mov r1, RSPIN
        str r1, [r0, GPCLR0]
.endm


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
        _memmap gpio, r0, gpioAddress_adr
        ldr r0, fileDescriptor_adr
        ldr r0, [r0]
        _memmap timer, r0, tmAddress_adr
        
gpioconfig:     @ configuração de modo dos GPIOs
        @ Gpios do banco GPFSEL2
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL20
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL21
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL25

        ldr r0, gpioAddress_adr
        ldr r0, [r0]                    @ Endereço base dos perif
        ldr r1, GPORT_adr
        ldr r1, [r1]                    @ Valor configurado da porta
        str r1, [r0, GPFSEL2]           @ Salva no registrador
        ldr r1, GPORT_adr
        mov r0, #0
        str r0, [r1]                    @ Zera a porta

        @ Gpios do banco GPFSEL0
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL08

        ldr r0, gpioAddress_adr
        ldr r0, [r0]                    @ Endereço base dos perif
        ldr r1, GPORT_adr
        ldr r1, [r1]                    @ Valor configurado da porta
        str r1, [r0, GPFSEL0]                    @ Salva no registrador
        ldr r1, GPORT_adr
        mov r0, #0
        str r0, [r1]                    @ Zera a porta

        @ Gpios do banco GPFSEL1
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL12
        _setreg GPORT_adr, REGMASK, OUTMODE, FSEL16
        
        ldr r0, gpioAddress_adr
        ldr r0, [r0]
        mov r6, r0
        ldr r1, GPORT_adr
        ldr r1, [r1]                    @ Valor configurado da porta
        str r1, [r0, GPFSEL1]                    @ Salva no registrador

        ldr r0, GPORT_adr
        mov r1, 0
        str r1, [r0]

        ldr r0, =CLEANMASK
        str r0, [r6, GPCLR0]

setmode:
        bl _setmode8

setmode1:
        bl _setmode8

setmode2:
        bl _setmode8

bit4mode:
        mov r0, B4MODE
        bl _write4bits

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _pulseEnable

        mov r6, #100
        udelay r6, tmAddress_adr

        mov r0, B4MODE
        bl _clean4bits

        mov r6, #150
        udelay r6, tmAddress_adr



clear1:
        sendCmd B42LINE
        mov r6, #500
        mdelay r6, tmAddress_adr

        sendCmd CLEAR

        mov r6, #500
        mdelay r6, tmAddress_adr

comandos:
        sendCmd D1C1B0

        mov r6, #500
        mdelay r6, tmAddress_adr

        sendCmd SHFTR

        mov r6, #500
        mdelay r6, tmAddress_adr

        sendCmd CSHFTR

        mov r6, #500
        mdelay r6, tmAddress_adr
        
        
        sendData 0x4A
        mov r6, #50
        mdelay r6, tmAddress_adr

        sendData 0x41
        mov r6, #50
        mdelay r6, tmAddress_adr
        
        sendData 0x43
        mov r6, #50
        mdelay r6, tmAddress_adr
        
        sendData 0x41

        
@ fim de programa
        mov     r0, 0           @ return 0;
        add     sp, sp, STACK_ARGS  @ fix sp
        ldr     r4, [sp, 0]     @ restore r4
        ldr     r5, [sp, 4]     @      r5
        ldr     fp, [sp, 8]     @         fp
        ldr     lr, [sp, 12]    @         lr
        add     sp, sp, 16      @ restore sp
        @ bkpt
        bx      lr              @ return
        .align  2


fileDescriptor_adr:     .word fileDescriptor
gpioAddress_adr:        .word gpioAddress
tmAddress_adr:          .word tmAddress
GPORT_adr:              .word GPORT             @ Armazena os bits antes de enviar
LTR_A_adr:               .word LTR_A

.data
        fileDescriptor: .word 0
        gpioAddress:    .word 0
        tmAddress:      .word 0
        GPORT:          .word 0
        LTR_A:          .ascii "A"


