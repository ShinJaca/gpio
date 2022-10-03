.syntax unified



.section .rodata
.align 2
    .equ    STACK_ARGS,8    @ sp already 8-byte aligned


.text
.align 2

.macro stacAloc size
    sub     sp, sp, 8       @ Espaço para LR e FP
    str     fp, [sp, 0]     @ Salvando FP
    str     lr, [sp, 4]     @ Salvando LR
    add     fp, sp, 4       @ Novo frame pointer

    sub     sp, sp, \size   @ Espaço para variáveis locais
.endm

.macro stacDisaloc size
    add     sp, sp, \size
    sub     sp, fp, 4
    ldr     fp, [sp, 0]
    ldr     lr, [sp, 4]
    add     sp, sp, 8
.endm

stackL1:
    stacAloc #8

    mov r0, #25

    stacDisaloc #8
    bx      lr

stackL0:
    sub     sp, sp, 8
    str     fp, [sp, 0]
    str     lr, [sp, 4]
    add     fp, sp, 4
    sub     sp, sp, 12
    mov     r3, #1
    str     r3, [fp, #-12]
    mov     r3, #3
    str     r3, [fp, #-8]
    bl      stackL1

    sub     sp, fp, #4
    pop     {fp, lr}
    bx      lr


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

code:
    bl stackL0


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

