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
 * Wait, repeat substract 1 in register 2, until value in register 2 became 0
 */
mov r2, #0x3F0000

wait1$:
        sub r2, #1
        cmp r2, #0
        bne wait1$

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
 * Wait2 is the same as wait1
 */
mov r2, #0x3F0000
wait2$:
        sub r2, #1
        cmp r2, #0
        bne wait2$

/* Loop over this process*/
b loop$

