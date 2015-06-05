/*
 * Function get timer address. 
 */
.globl GetSystemTimerBase
GetSystemTimerBase:
ldr r0, =0x20003000
mov pc, lr

/*
 * Define function GetSystemTime, 
 * return r0 contains lower 32 bits 
 * return r1 contains 32 bits 
 */
.globl GetTimeStamp
GetTimeStamp:
push {lr}
bl GetSystemTimerBase
ldrd r0, r1, [r0,#4]
pop {pc}

/*
 * Define function wait, wait time is less than 4 bytes
 */
.globl Wait
Wait:
delay .req r2
mov delay, r0   /* Get delay ticks */
push {lr}
bl GetTimeStamp
start .req r3
mov start, r0   /* Get start time */

loop$:      /* Wait loop begin */
bl GetTimeStamp
elapsed .req r1
sub elapsed, r0, start
cmp elapsed, delay
.unreq elapsed 
bls loop$   /* Loop if time laspe is lower than wait time */

.unreq delay
.unreq start
pop {pc}
