.syntax unified


    .equ    STACK_ARGS,8    @ sp already 8-byte aligned

.section .rodata
.align 2


asc_J:    .ascii "JACA DA BAHIA"


.text
.align 2

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
    ldr r0, =asc_J
    ldr r1, [r0]


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

