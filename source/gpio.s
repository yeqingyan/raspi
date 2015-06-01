/*
 * Define global symbol GetGpioAddress, make it accessible to all files
 */
.globl GetGpioAddress
GetGpioAddress:
ldr r0,=0x20200000      /* Store 0x20200000 to register r0*/
mov pc, lr              /* Copy value in lr(link register) to pc register, like return */

/* 
 * Define function SetGpioFunction
 */
.globl SetGpioFunction
SetGpioFunction:
cmp r0, #53     /* Check input between 0 to 53(54 pins) */
cmpls r1, #7    /* Check function between 0 to 7(8 functions) */
movhi pc, lr    
push {lr}       /* Save lr value, because lr will be updated after run bl*/
mov r2, r0      /* Save r0 value, which will be changed by GetGpioAddress */
bl GetGpioAddress /* r0 have GPIO address */

/*
 * Find the which GPIO address our pin number is in.
 */
functionLoop$:
        cmp r2, #9              /* Compare input pin to 9 */
        subhi r2, #10           /* if InputPin >=9, r2 substracts 10 */
        addhi r0, #4            /* if InputPin >=9, GPIO address plus 4 */
        bhi functionLoop$

add r2, r2,lsl #1       /* r2 = r2 + r2, equal to r2 = 3*r2 */
lsl r1, r2              /* Set function bits correspond to our pin number(3 bits per pin)*/

mov r3, #7              /* Create mask into r3 */
lsl r3, r2              /* r3 = 000000...111...000000 */
mvn r3, r3              /* r3 = 111111...000...111111 */
ldr r2, [r0]            /* Load old gpio value into r2 */
and r2, r3              /* set 3 bit with pin in old gpio to 0 */

orr r1, r2              /* Got final bit set */

str r1, [r0]            /* Store r1 in GPIO address */
pop {pc}                /* Pop previous pushed lr, return from this call */ 

/*
 * Turn pin on/off 
 */
.globl SetGpio
SetGpio:
pinNum .req r0  /* Set r0 alias pinNum */
pinVal .req r1  /* Set r1 alias pinVal */

cmp pinNum, #53
movhi pc,lr
push {lr}
mov r2, pinNum
.unreq pinNum
pinNum .req r2
bl GetGpioAddress
gpioAddr .req r0
pinBank .req r3
lsr pinBank, pinNum, #5         /* pinNum=0-31 pinBank=0, pinNum=32-53 pinBank=4 */
lsl pinBank, #2
add gpioAddr, pinBank
.unreq pinBank

and pinNum, #31         /* Calulate remainder of pinNum divided by 32 */
setBit .req r3  
mov setBit, #1
lsl setBit, pinNum
.unreq pinNum

teq pinVal, #0          /* Check turn pin on or off */
.unreq pinVal
streq setBit, [gpioAddr, #40] /* Turn pin off*/
strne setBit, [gpioAddr, #28] /* Turn pin on*/
.unreq setBit
.unreq gpioAddr
pop {pc}        
