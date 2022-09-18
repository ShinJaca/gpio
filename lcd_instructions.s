
.syntax unified

.equ    STMODE, 0x03
.equ    B4MODE, 0x02
.equ    B42LINE,0b00101000
.equ    CLEAR,  0b00000001
.equ    HOME,   0b00000010
.equ    SHFTL,  0b00000111
.equ    SHFTR,  0b00000101
.equ    EMSLN,  0b00000110
.equ    D1C0B0, 0b00001100
.equ    D1C1B0, 0b00001110
.equ    D1C1B1, 0b00001111  @ Display ON, Cursor ON, Blink ON

.equ    CSHFTL, 0b00010000
.equ    CSHFTR, 0b00010100
.equ    CPOADR, 0b10000000

.equ    STLNCH, 0x00101000  @ set 2 lines 5x7 matrix

.equ    CGADDR, 0x01000000  @ Set address MASK

.equ    CHARA, 0x41
