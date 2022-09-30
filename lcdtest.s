@ Opens the /dev/gpiomem device and maps GPIO memory
@ into program virtual address space.
@ 2017-09-29: Bob Plantz 



@ Define my Raspberry Pi
        .syntax unified         @ modern syntax

        
@ Constant program data
        .section .rodata
        .align  2

        .equ    STACK_ARGS,8    @ sp already 8-byte aligned


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

        bl _lcdStartup

        bl _clearDisplay

config:
        bl _turnOnCursorOn

        bl _setMemoryMode


        mov r0, 0x30
        bl _sendChar
        mov r0, 0x31
        bl _sendChar
        mov r0, 0x33
        bl _sendChar
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


COUNTER_adr:            .word COUNTER

.data


        COUNTER:        .word 0x30
        COUNTERDEC:     .word 0x30


