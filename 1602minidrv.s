.include "funcs.s"
.include "lcd_instructions.s"

.syntax unified

@Constantes

.section .rodata
.align 2

@Offsets de registradores

    @Seleção de funcção de pinos
    .equ    FSEL01, 3   @EN (GPIO01)
    @ .equ    FSEL08, 24   @EN (GPIO08)
    .equ    FSEL12, 6   @D4 (GPIO12)
    .equ    FSEL16, 18  @D5 (GPIO16)
    .equ    FSEL20, 0   @D6 (GPIO20)
    .equ    FSEL21, 3   @D7 (GPIO21)
    .equ    FSEL25, 15  @RS (GPIO25)

    @Nomeação dos pinos
    .equ    GPIO12, 12
    .equ    GPIO16, 16
    .equ    GPIO20, 20
    .equ    GPIO21, 21
    .equ    RS,     25
    .equ    EN,     1   
    @ .equ    EN,     8

    @Constante de pinos
    .equ    ENPIN,  0x2
    @ .equ    ENPIN,  0x100
    .equ    RSPIN,  0x2000000
    .equ    PBTN1,  0x20        @GPIO05
    .equ    PBTN2,  0x80000     @GPIO19
    .equ    PBTN3,  0x4000000   @GPIO26

@Constantes de funções

    @ Pulso de enable
    .equ    PULSEINT, 10

    @ Período de contagem do timer
    .equ    INTERVALO, 1000

    @ Mascara de limpeza de estados de pinos
    .equ    CLEANMASK, 0x2311120



.text
.align 2


@ Zera o estado do(s) pino(s) selecionado(s) em pinmsk
.macro pinClr pinmsk
        mov r11, \pinmsk
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r11, [r12, GPCLR0]
.endm 

@ Seta o estado do(s) pino(s) selecionado(s) em pinmsk
.macro pinSet pinmsk
        mov r11, \pinmsk
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        str r11, [r12, GPSET0]
.endm 



@ Gera um pulso no pino EN (ENable) para confirmar um comando ou dado
.global _pulseEnable
.type   _pulseEnable, %function

_pulseEnable:
        pinClr ENPIN                        @zera pino enable
        udelay PULSEINT, tmAddress_adr      @espera um pequeno intervalo
        pinSet ENPIN                        @eleva o nível do pino enable
        udelay PULSEINT, tmAddress_adr      @espera um pequeno intervalo
        pinClr ENPIN                        @zera pino enable

        bx  lr


@ Funções internas

@ Escreve um nibble para a memória e para a porta configurada
_write4bits:
         _mapbitsToPort4 r0, GPORT_adr
        ldr r12, gpioAddress_adr
        ldr r12, [r12]
        ldr r11, GPORT_adr
        ldr r11, [r11]
        str r11, [r12, GPSET0]

        bx lr


@ Limpa um nibble da memória e da porta configurada
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


@ Envia um comando de configuração do modo do LCD (Para inicialização apenas)
@ r0 --> MODO a ser enviado

_setmode:
        mov r7, lr      @ salvando o ponteiro para a saída 

        bl _write4bits

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _pulseEnable

        mov r6, #10
        udelay r6, tmAddress_adr

        bl _clean4bits

        mov r6, #4500
        udelay r6, tmAddress_adr

        bx r7

@ Executa os passos para enviar um comando para o LCD
.macro sendCmd CMD
        @ Primeiro os bits altos
        mov r0, \CMD
        lsr r0, #4
        bl _write4bits

        bl _pulseEnable


        mov r0, \CMD
        lsr r0, #4
        bl _clean4bits
        

        @ Segundo os bits baixos
        mov r0, \CMD
        bl _write4bits

        bl _pulseEnable

        mov r0, \CMD
        bl _clean4bits
.endm

.macro sendData CMD

        pinSet RSPIN

        @ Primeiro os bits altos
        mov r0, \CMD
        lsr r0, #4
        bl _write4bits

        bl _pulseEnable

        mov r0, \CMD
        lsr r0, #4
        bl _clean4bits
             
        @ Segundo os bits baixos
        mov r0, \CMD
        bl _write4bits

        bl _pulseEnable

        mov r0, \CMD
        bl _clean4bits

        pinClr RSPIN
.endm