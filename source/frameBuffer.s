.section .data
.align 12
.globl FrameBufferInfo
FrameBufferInfo:
.int 1024       /* #0 Physical Width */
.int 768        /* #4 Physical Height*/
.int 1024       /* #8 Virutal Width(Framebuffer width) */
.int 768        /* #12 Virtual Height(Framebuffer height) */
.int 0          /* #16 GPU - Pitch */
.int 16         /* #20 Bit Depth (High Colour) */
.int 0          /* #24 X (number of pixels to skip in the top left corner of the screen when copying the framebuffer to screen) */
.int 0          /* #28 Y (same as X) */
.int 0          /* #32 GPU - Pointer */
.int 0          /* #36 GPU - Size */

.section .text
/*
 * InitialiseFrameBuffer
 * ---------------------
 * Parameters
 * r0: weight
 * r1: height
 * r2: bit depth
 * 
 * Return
 * Pointer to framebuffer info. Return 0 if failed.
 */
.globl InitialiseFrameBuffer
InitialiseFrameBuffer:
width .req r0
height .req r1
bitDepth .req r2
cmp width, #4096        /* Width should less than 4096 */
cmpls height, #4096     /* Height should less than 4096 */
cmpls bitDepth, #32     /* Bit depth should less than 32 bits */
result .req r0
movhi result, #0        /* Return 0 if input not valid */
movhi pc, lr

push {r4, lr}           /* Register 3 will be used by MailboxRead/Write so we can not use r3 here. */
fbInfoAddr .req r4
ldr fbInfoAddr, =FrameBufferInfo
str width, [fbInfoAddr, #0]     /* Store input into framebuffer info */
str height, [fbInfoAddr, #4]
str width, [fbInfoAddr, #8]
str height, [fbInfoAddr, #12]
str bitDepth, [fbInfoAddr, #20]
.unreq width
.unreq height
.unreq bitDepth

mov r0, fbInfoAddr
add r0, #0x40000000
mov r1, #1
bl MailboxWrite         /* Write framebuffer to channel 1 */

mov r0, #1
bl MailboxRead          /* Read response */
teq result, #0
movne result, #0        /* If response is not 0, return 0 indicate failure. */
popne {r4, pc}

mov result, fbInfoAddr
.unreq result
.unreq fbInfoAddr
pop {r4, pc}

