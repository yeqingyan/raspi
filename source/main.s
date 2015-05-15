/*
 * TODO More explanation
 * Let our code runs first, put our code in .init section
 */
.section .init
.globl _start
_starta:
/* 
 * store 0x20200000 into register r0
 * 0x20200000 is GPIO Controller Address
 */
ldr r0,=0x20200000

mov r1, #1        /* Move 1 into register 1 */
lsl r1, #18       /* shift value in register 1 left by 18 places */

/* Send value in register r1 to GPIO Controller 
 * Enable 16th GPIO pin
 */ 
str r1, [r0, #4]

mov r1, #1
lsl r1, #16
str r1, [r0. #40] /* Turn the 16th pin off, the light will on */

loop$:
b loop$

