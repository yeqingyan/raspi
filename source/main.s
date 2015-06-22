/*
 * Code in .init section will be called before the main() is called.
 * Details in GCC Internals documentation(How Initialization Functions Are Handled)
 */
.section .init
.globl _start   /* Define global symbol _start, make this symbol visible to ld */
_start:

b main

.section .text
main: 
mov sp, #0x8000 /* stack start at 0x8000, bottom of the stack address. */

mov r0, #1024   /* Width */
mov r1, #768    /* Height */
mov r2, #16     /* Color depth */
bl InitialiseFrameBuffer

teq r0, #0
bne noError$    /* Turn on LED, if met error */

mov r0, #16     /* Prepare LED */
mov r1, #1
bl SetGpioFunction      /* Turn on LED */
mov r0, #16
mov r1, #0 
bl SetGpio

error$:
b error$

noError$:
fbInfoAddr .req r4
mov fbInfoAddr, r0
bl SetGraphicsAddress   /* Setup Graphic Adderss*/

mov r0, #9
bl FindTag
ldr r1, [r0]
lsl r1, #2
sub r1, #8
add r0, #8
mov r2, #0
mov r3, #0
bl DrawString
loop$:
b loop$
