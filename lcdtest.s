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

        .equ    INTERVALO, 5000

        .equ    CLEANMASK, 0x2311100


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
        mov r0, CLEAR
        _mapbitsToPort4 r0, GPORT_adr
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        ldr r11, GPORT_adr
        ldr r11, [r11]
        str r11, [r12, GPSET0]

pulse:
        mov r6, #10
        mdelay r6, tmAddress_adr

        mov r10, 0x100
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r10, [r12, GPCLR0]

        mdelay r6, tmAddress_adr

        mov r10, 0x100
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r10, [r12, GPSET0]

        mdelay r6, tmAddress_adr

        mov r10, 0x100
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r10, [r12, GPCLR0]

        mov r6, #100
        mdelay r6, tmAddress_adr



        mov r0, CLEAR
        _mapbitsToPort4 r0, GPORT_adr
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        ldr r11, GPORT_adr
        ldr r11, [r11]
        str r11, [r12, GPCLR0]

@ m1:
@         mov r10, #1
@         lsl r10, EN             @ posição do pino enable
@         ldr r6, gpioAddress_adr
@         ldr r6, [r6]          @ endereço base dos GPIO
@         mov r12, #1
@         str r10, [r6, GPCLR0]  @ Clear ENABLE
@         mdelay r12, tmAddress_adr   @ espera 1ms
@         str r10, [r6, GPSET0] @ Clear ENABLE
@         mdelay r12, tmAddress_adr   @ espera 1ms
@         str r10, [r6, GPCLR0] @ Clear ENABLE
@         mov r12, #100
@         mdelay r12, tmAddress_adr   @espera 100ms para o comando ser interpretado
        @ enpulse tmAddress_adr, gpioAddress_adr
@         mov r7, #5
@         mdelay r7, tmAddress_adr

@         enpulse tmAddress_adr, gpioAddress_adr
@         mdelay r7, tmAddress_adr

@         enpulse tmAddress_adr, gpioAddress_adr
@         mov r7, #150
@         udelay r7, tmAddress_adr
@         mov r0, B4MODE
@         _mapbitsToPort4 r0, GPORT_adr
@         ldr r12, gpioAddress_adr
@         ldr r12, [r12]
@         ldr r11, =CLEANMASK
@         str r11, [r12, GPCLR0]
@         ldr r11, GPORT_adr
@         ldr r11, [r11]
@         str r11, [r12, GPSET0]
@         enpulse tmAddress_adr, gpioAddress_adr
@         mov r7, #1000
@         mdelay r7, tmAddress_adr
        
@ clearlcd:

@         mov r0, CLEAR
@         lsr r0, #4
@         _mapbitsToPort4 r0, GPORT_adr
@         ldr r12, gpioAddress_adr
@         ldr r12, [r12]
@         ldr r11, =CLEANMASK
@         str r11, [r12, GPCLR0]
@         ldr r11, GPORT_adr
@         ldr r11, [r11]
@         str r11, [r12, GPSET0]
@         enpulse tmAddress_adr, gpioAddress_adr
@         @ mov r7, #1000
        @ mdelay r7, tmAddress_adr
        
        @ mov r0, 0b00111000
        @ lsr r0, #4
        @ _mapbitsToPort4 r0, GPORT_adr

        @ ldr r0, gpioAddress_adr
        @ ldr r0, [r0]                    @ GPIO base endereço
        @ ldr r1, GPORT_adr
        @ ldr r1, [r1]                    @ Valor da porta atual
        @ mov r2, #1
        @ mov r2, r2, lsl EN              @ Mascara do pino ENABLE
        @ orr r1, r1, r2
        @ str r1, [r0, GPSET0]            @ Primeiro nimble
        @ mov r7, #10
        @ mdelay r7, tmAddress_adr
        @ str r2, [r0, GPCLR0]            @ Limpa enable
        
        @ mov r7, #100
        @ mdelay r7, tmAddress_adr

        @ mov r0, 0b1000
        @ _mapbitsToPort4 r0, GPORT_adr

        @ ldr r0, gpioAddress_adr
        @ ldr r0, [r0]                    @ GPIO base endereço
        @ ldr r1, GPORT_adr
        @ ldr r1, [r1]                    @ Valor da porta atual
        @ mov r2, #1
        @ mov r2, r2, lsl EN              @ Mascara do pino ENABLE
        @ orr r1, r1, r2
        @ str r1, [r0, GPSET0]            @ Primeiro nimble
        @ mov r7, #10
        @ mdelay r7, tmAddress_adr
        @ str r2, [r0, GPCLR0]            @ Limpa enable

        @ mov r7, #50
        @ mdelay r7, tmAddress_adr



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

.data
        fileDescriptor: .word 0
        gpioAddress:    .word 0
        tmAddress:      .word 0
        GPORT:          .word 0


