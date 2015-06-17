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

render$:
        fbAddr .req r3
        ldr fbAddr, [fbInfoAddr, #32]
        
        colour .req r0
        y .req r1
        mov y, #768
        drawRows$:
                x .req r2
                mov x, #1024
                drawPixels$:
                        strh colour, [fbAddr]
                        add fbAddr, #2
                        sub x, #1
                        teq x, #0
                        bne drawPixels$
                sub y, #1
                add colour, #1
                teq y, #0
                bne drawRows$
        b render$

.unreq fbAddr
.unreq fbInfoAddr
