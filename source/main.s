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

mov r0, #16             /* Select 16th pin */
mov r1, #1              /* Select pin function 1 */
bl SetGpioFunction

ptrn .req r4
ldr ptrn,=pattern       /* Load pattern label address into ptrn register */
ldr ptrn,[ptrn]         /* Load value of address in ptrn register */
seq .req r5             /* Register 5 for sequence position */
mov seq, #0


loop$:

mov r0, #16             /* Select 16th pin */
mov r1, #1
lsl r1, seq
and r1, ptrn            /* If current part of position is a 1, r1 will be a non-zero value */
bl SetGpio

/*
 * Wait 250000 ticks
 */
ldr r0, =250000         /* instruction mov r0, #val need value in range 0 - 65535, so we can not use mov here */
bl Wait

add seq, #1
and seq, #0b11111       /* Reset seq to 0 if it reaches 32 */

/* Loop over this process*/
b loop$
.unreq ptrn
.unreq seq 

.section .data
.align 2
pattern:
.int 0b11111111101010100010001000101010 /* Morse code, 0 for turn off LED, 1 for turn on LED */
