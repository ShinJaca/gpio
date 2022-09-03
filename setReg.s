@ setReg.s
@ define função para gravar dados em um registrador com offsets
@ de bits e de endereço base do registrador
@
@ uso: 
@   r0 ----> endereço base do registrador
@   r1 ----> offset do endereço base
@   r2 ----> valor a ser configurado
@   r3 ----> posição do valor a ser movido

@ Define my Raspberry Pi
    .cpu    cortex-a7
    .syntax unified     

    .text
    .align  2
    .global setReg
    .type   setReg,   %function

setReg:
    add r0, r0, r1  @ Offset do endereço base
    lsl r2, r2, r3  @ offset do valor a ser registrado
    str r2, [r0]    @ atualiza registrador endereçado em r0

    bx  lr          @ return

    