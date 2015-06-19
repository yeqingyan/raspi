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

currentX .req r5
currentY .req r6
lastRandom .req r7
colour .req r10
lastX .req r8
lastY .req r9

mov lastRandom, #0
mov lastX, #0
mov lastY, #0
mov colour, #0

drawRandomLine$:
createRandom$:
mov r0, lastRandom
bl Random               /* Generate x-coordinate */
mov currentX, r0
bl Random               /* Generate y-coordinate */
mov currentY, r0
mov lastRandom, r0

mov r0, colour
add colour, #1
lsl colour, #16
lsr colour, #16         /* Reset color to 0 if it reaches 0xFFFF */
bl SetForeColour

mov r0, lastX
mov r1, lastY
lsr r2, currentX, #22   /* Convert x,y between 0 and 1023 */
lsr r3, currentY, #22

cmp r3, #768      /* If y larger than 767, get random again */
bhs createRandom$

mov lastX, r2   /* Update lastX, lastY */
mov lastY, r3
bl DrawLine     /* draw line from (currentX, currentY) to (lastX, lastY) */

b drawRandomLine$

.unreq currentX
.unreq currentY
.unreq lastRandom 
.unreq colour
.unreq lastX
.unreq lastY
