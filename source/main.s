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

pinNum .req r0
pinFunc .req r1
mov pinNum, #16         /* Select 16th pin */
mov pinFunc, #1         /* Select pin function 1 */
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

loop$:

/*
 * Turn off GPIO 16th pin, the light will on
 * Address: GPIO Pin Output Clear 0(GPCLR0)
 * Register value: Clean GPIO pin 16
 */
pinNum .req r0
pinVal .req r1
mov pinNum, #16
mov pinVal, #0
bl SetGpio
.unreq pinNum
.unreq pinVal

/*
 * Wait 20 ticks
 */
mov r0, #20
bl Wait

/*
 * Turn off the light  
 * Address: GPIO Pin Output Set 0(GPSET0)
 * Register value: Set 0 GPIO pin 16
 */
pinNum .req r0
pinVal .req r1
mov pinNum, #16
mov pinVal, #1
bl SetGpio
.unreq pinNum
.unreq pinVal

/*
 * Wait 20 ticks
 */
mov r0, #20
bl Wait

/* Loop over this process*/
b loop$

