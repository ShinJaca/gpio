@ Opens the /dev/gpiomem device and maps GPIO memory
@ into program virtual address space.
@ 2017-09-29: Bob Plantz 



@ Define my Raspberry Pi
        .syntax unified         @ modern syntax

        
@ Constant program data
        .section .rodata
        .align  2

        .equ    STACK_ARGS,8    @ sp already 8-byte aligned
        .equ    PBTN1,  0x20        @GPIO05
        .equ    PBTN2,  0x80000     @GPIO19
        .equ    PBTN3,  0x4000000   @GPIO26

@ The program
        .text
        .align  2

updateTimer:
        push    {fp, lr}
        bl      _clearDisplay

        add     r0, 0x30
        add     r1, 0x30

        sub     sp, sp, #8
        str     r0, [sp, 0]
        str     r1, [sp, 4]

        bl      _sendChar
        ldr     r1, [sp, 4]
        bl      _sendChar

        add     sp, sp, #8
        
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

setup:
        bl      _lcdStartup
        bl      _clearDisplay
        bl      _turnOnCursorOff
        bl      _setMemoryMode

        ldr     r0, =gpioAdr
        bl      _getGpioAdr
loop:
        mov     r0, #100
        bl      _mdelay
        
        ldr     r1, =CNTR
        ldr     r0, [r1]
        add     r0, #1
        str     r0, [r1]
        
        cmp     r0, #10
        bne     btn1
@ else
        ldr     r2, =COUNTER
        ldr     r3, =COUNTERDEC
        add     r0, #1
        add     r1, #1
        cmp     r0, #9
        movgt   r0, #0
        cmp     r1, #9
        movgt   r1, #0
        str     r0, [r2]
        str     r1, [r3]

btn1:   @ Reset Button
        mov     r0, PBTN1       
        bl      _readIn
        cmp     r0, #0
        bgt     updtmr

        mov     r0, #0
        mov     r1, #0


@ btn2:   @ Pause Button
@         mov     r0, PBTN2
@         bl      _readIn

@         ldr     r4, =POLD
@         ldr     r5, [r4]
        
@         cmp     r5, r0
@         beq     updtmr
@         str     r0, [r4]
        
@         cmp     r0, #0
@         blne    updtmr

@         ldr     r0, =PAUSE
@         mov     r1, [r0]


updtmr: @ Update valores de timer
        bl    updateTimer
        
        b loop


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
        gpioAdr:        .word 0
        CNTR:           .word 0
        COUNTER:        .word 0
        COUNTERDEC:     .word 0
        PAUSE:          .byte 0
        POLD:           .word 0, 0, 0 @ PBTN1, PBTN2, PBTN3

