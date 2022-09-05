.global main
.type   main, %function

main:
    ldr r0, =t
    mov r1, #1

    str r1, [r0]

    bx  lr
.data
    t: .word 0x123
    x: .word 0

