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
        .equ    O_FLAGS,O_RDWR|O_SYNC @ open file flags
        .equ    PROT_RDWR,PROT_READ|PROT_WRITE
        .equ    NO_PREF,0
        .equ    PAGE_SIZE,4096  @ Raspbian memory page
        .equ    FILE_DESCRP_ARG,0   @ file descriptor
        .equ    DEVICE_ARG,4        @ device address
        .equ    STACK_ARGS,8    @ sp already 8-byte aligned

@ Endereços e offsets para oum GPIO
        .equ    GPFSEL2,0x8             @ Offset do reg GPFSEL2
        .equ    GPCLR0,0x28             @
        .equ    GPSET0,0x1c             @
        .equ    GPIO22_OFFSET,6         @ Offset da configuração do GPIO22
        .equ    FSEL_OUTPUT,0b001       @ Bits de modo de saída

@ Constant program data
        .section .rodata
        .align  2
device:
        .asciz  "/dev/mem"

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

@ Map the GPIO registers to a virtual memory location so we can access them        
        str     r4, [sp, FILE_DESCRP_ARG] @ /dev/gpiomem file descriptor
        ldr     r0, gpio        @ address of GPIO
        str     r0, [sp, DEVICE_ARG]      @ location of GPIO
        mov     r0, NO_PREF     @ let kernel pick memory
        mov     r1, PAGE_SIZE   @ get 1 page of memory
        mov     r2, PROT_RDWR   @ read/write this memory
        mov     r3, MAP_SHARED  @ share with other processes
        bl      mmap
        mov     r7, r0          @ save virtual memory address
        
_teste:
@ TESTE DE USO DE FUNÇÕES DE CONFIGURAÇÃO
_configpins:
        mov     r0, r7                  @ Recupera endereço base
        mov     r1, GPFSEL2             @ Registrador de configuração de modo
        mov     r2, FSEL_OUTPUT         @ Bits de modo de OUTPUT
        mov     r3, GPIO22_OFFSET       @ Offset corespondetes ao pino em GPFSEL2
        bl      setReg

_setpins:
        mov     r0, r7                  @ Recupera endereço base
        mov     r1, GPCLR0              @ Resistrador de limpeza dos pinos
        mov     r2, FSEL_OUTPUT         @ Bits de saída
        mov     r3, 22                  @ Offset do pino no registrador GPCLR0
        bl      setReg

_closefile:
        mov     r0, r7          @ memory to unmap
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
openMode:
        .word   O_FLAGS
gpio:
        .word   PERIPH+GPIO_OFFSET

