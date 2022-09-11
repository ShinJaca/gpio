@ Opens the /dev/gpiomem device and maps GPIO memory
@ into program virtual address space.
@ 2017-09-29: Bob Plantz 


.include "funcs.s"

@ Define my Raspberry Pi
        @ .cpu    arm1176jz-s
        .cpu    cortex-a7
        .syntax unified         @ modern syntax

        .equ    GPIO22_OFFSET, 6

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
openfile:
        _openfile fileDescriptor_adr
        ldr     r4, fileDescriptor_adr
        ldr     r4, [r4]

memorymap:
        _memmap gpio, r4, mappedAdress_adr
        ldr     r7, mappedAdress_adr
        ldr     r7, [r7]

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
        mov     r1, GPSET0              @ Resistrador de limpeza dos pinos
        mov     r2, FSEL_OUTPUT         @ Bits de saída
        mov     r3, 22                  @ Offset do pino no registrador GPCLR0
        bl      setReg

_closefile:
        mov     r0, r7          @ memory to unmap
        mov     r1, PAGE_SIZE   @ amount we mapped
        bl      munmap          @ unmap it
        @ bkpt
        mov     r0, r4          @ /dev/gpiomem file descriptor
        bl      close           @ close the file
        @ bkpt
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
mappedAdress_adr:       .word mappedAdress

.data
        fileDescriptor: .word 0
        mappedAdress:   .word 0

