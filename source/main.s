/*
 * Code in .init section will be called before the main() is called.
 * Details in GCC Internals documentation(How Initialization Functions Are Handled)
 */
.section .init
.globl _start   /* Define global symbol _start, make this symbol visible to ld */
_start:
/* 
 * store 0x20200000 into register r0
 * 0x20200000 is GPIO Controller Address
 */
ldr r0,=0x20200000

/*
 * Send value in register r1 to GPIO Controller 
 * Enable 16th GPIO pin
 * Address: GPIO Function Select 1(GPFSEL1)
 * Register value: Function Select 16(FSEL16)
 */ 
mov r1, #1        
lsl r1, #18       
str r1, [r0, #4]        /*0x20200004*/

mov r1, #1
lsl r1, #16
loop$:
/*
 * Turn off GPIO 16th pin, the light will on
 * Address: GPIO Pin Output Clear 0(GPCLR0)
 * Register value: Clean GPIO pin 16
 */
str r1, [r0, #40]       /*0x20200028*/

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
str r1, [r0, #28]       /*0x2020001C*/

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

