@ Opens the /dev/gpiomem device and maps GPIO memory
@ into program virtual address space.
@ 2017-09-29: Bob Plantz 


@ .include "pinConfig.s"
@ .include "pinSet.s"

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
@        .equ    PERIPH,0x20000000   @ RPi zero & 1 peripherals
        .equ    GPIO_OFFSET,0x200000  @ start of GPIO device
        .equ    TIMER_OFFSET,0x3000  @ start of Timer device
        .equ    O_FLAGS,O_RDWR|O_SYNC @ open file flags
        .equ    PROT_RDWR,PROT_READ|PROT_WRITE
        .equ    NO_PREF,0
        .equ    PAGE_SIZE,0x1000  @ Raspbian memory page
        .equ    FILE_DESCRP_ARG,0   @ file descriptor
        .equ    DEVICE_ARG,4        @ device address
        .equ    STACK_ARGS,8    @ sp already 8-byte aligned

@ Endereços e offsets para oum GPIO
        .equ    GPFSEL2,0x8             @ Reg Sel Funções pinos GPIO20 - GPIO29
        .equ    GPFSEL0,0x0             @ GPIO00 - GPIO09
        .equ    GPCLR0,0x28             @
        .equ    GPSET0,0x1c             @
        .equ    GPIO22_OFFSET,6         @ Offset da configuração do GPIO22
        .equ    GPIO22,22
        .equ    GPIO06_OFFSET,18        @ Offset da configuração do GPIO06
        .equ    GPIO06,6
        .equ    FSEL_OUTPUT,0b001       @ Bits de modo de saída

@ Endereços e offsets para o TIMER
        .equ    TCLO,0x4
        .equ    TCHI,0x8
@ Loops
        .equ    LOOPS,3
        .equ    INTERVALO,500
        .equ    BASEUSEC,1000

@ Constant program data
        .section .rodata
        .align  2
device:
        @ .asciz  "/dev/gpiomem"
        .asciz  "/dev/mem"
memMsg:
        .asciz  "time: %d\n"
intMsg:
        .asciz  "intervalo: %d\n"




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

@ Open /dev/gpiomem for read/write and syncing        
        ldr     r0, deviceAddr  @ address of /dev/gpiomem
        ldr     r1, openMode    @ flags for accessing device
        bl      open
        mov     r4, r0          @ use r4 for file descriptor
        str     r4, [sp, FILE_DESCRP_ARG] @ /dev/gpiomem file descriptor

_maptimer:
        ldr     r0, timer       @ address of TIMER
        str     r0, [sp, DEVICE_ARG]      @ location of TIMER
        mov     r0, NO_PREF     @ let kernel pick memory
        mov     r1, PAGE_SIZE   @ get 1 page of memory
        mov     r2, PROT_RDWR   @ read/write this memory
        mov     r3, MAP_SHARED  @ share with other processes
        bl      mmap

        ldr     r7, =timerMapedAddres
        str     r0, [r7]

@ Map the GPIO registers to a virtual memory location so we can access them        
_mapgpio:
        ldr     r0, gpio       @ address of GPIO
        str     r0, [sp, DEVICE_ARG]      @ location of GPIO
        mov     r0, NO_PREF     @ let kernel pick memory
        mov     r1, PAGE_SIZE   @ get 1 page of memory
        mov     r2, PROT_RDWR   @ read/write this memory
        mov     r3, MAP_SHARED  @ share with other processes
        bl      mmap

        ldr     r7, =gpioMapedAddres    @ aponta para a variavel
        str     r0, [r7]                @ armazena o valor na variavel do ponteiro

_teste:
@ TESTE DE USO DE FUNÇÕES DE CONFIGURAÇÃO
        mov     r6, #0                  @ inicia o contador de loops
_configpins:
        ldr     r0, =gpioMapedAddres    @ aponta para a variavel
        ldr     r0, [r0]                @ recupera o valor da variavel do ponteiro
        @ mov     r1, GPFSEL0             @ Registrador de configuração de modo
        @ mov     r2, FSEL_OUTPUT         @ Bits de modo de OUTPUT
        @ mov     r3, GPIO06_OFFSET       @ Offset corespondetes ao pino em GPFSEL2
        mov     r1, GPFSEL2             @ Registrador de configuração de modo
        mov     r2, FSEL_OUTPUT         @ Bits de modo de OUTPUT
        mov     r3, GPIO22_OFFSET       @ Offset corespondetes ao pino em GPFSEL2
        bl      setReg

_timerset:
        mov     r10, BASEUSEC           @ base de usec
        mov     r11, INTERVALO          @ tempo em msec
        mul     r10, r10, r11           @ conversão de usec para msec

        ldr     r7, =timerMapedAddres
        ldr     r7, [r7]
        ldr     r1, [r7, TCLO]          @ lê o valor do timer para r1
_wait1:
        ldr     r2, [r7, TCLO]          @ carrega o tempo para comparação
        sub     r3, r2, r1              @ intervalo atual
        cmp     r3, r10                 @ comparação do intevalo atual com o intervalo devfinido
        blt     _wait1
      
_setpins:
        ldr     r0, =gpioMapedAddres    @ aponta para a variavel
        ldr     r0, [r0]                @ recupera o valor da variavel do ponteiro
        mov     r1, GPSET0              @ Resistrador de limpeza dos pinos
        mov     r2, FSEL_OUTPUT         @ Bits de saída
        @ mov     r3, GPIO06                  @ Offset do pino no registrador GPCLR0
        mov     r3, GPIO22                  @ Offset do pino no registrador GPCLR0
        bl      setReg

        ldr     r1, [r7, TCLO]
_wait2:
        ldr     r2, [r7, TCLO]
        sub     r3, r2, r1
        cmp     r3, r10
        blt     _wait2

_clrpins:
        ldr     r0, =gpioMapedAddres    @ aponta para a variavel
        ldr     r0, [r0]                @ recupera o valor da variavel do ponteiro
        mov     r1, GPCLR0              @ Resistrador de limpeza dos pinos
        mov     r2, FSEL_OUTPUT         @ Bits de saída
        @ mov     r3, GPIO06                  @ Offset do pino no registrador GPCLR0
        mov     r3, GPIO22                  @ Offset do pino no registrador GPCLR0
        bl      setReg

        mov     r0, LOOPS
        add     r6, r6, #1
        cmp     r6, r0
        blt     _timerset


_closefile:
        @ Unmap memória para os GPIOs
        ldr     r0, =gpioMapedAddres    @ aponta para a variavel
        ldr     r0, [r0]                @ recupera o valor da variavel do ponteiro
        mov     r1, PAGE_SIZE   @ amount we mapped
        bl      munmap          @ unmap it

        @ Unmap memória para o TIMER
        ldr     r0, =timerMapedAddres    @ aponta para a variavel
        ldr     r0, [r0]                @ recupera o valor da variavel do ponteiro
        mov     r1, PAGE_SIZE   @ amount we mapped
        bl      munmap          @ unmap it

        mov     r0, r4          @ /dev/gpiomem file descriptor
        bl      close           @ close the file

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
@ addresses of messages

deviceAddr:
        .word   device
memMsgAddr:
        .word   memMsg
intMsgAddr:
        .word   intMsg
        
openMode:
        .word   O_FLAGS
gpio:
        .word   PERIPH+GPIO_OFFSET

timer:
        .word   PERIPH+TIMER_OFFSET


.data
        timerMapedAddres: .word   0
        gpioMapedAddres: .word   0
