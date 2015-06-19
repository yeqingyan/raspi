/*
 * Function get mailbox base address
 */
.globl GetMailboxBase
GetMailboxBase:
ldr r0, =0x2000B880
mov pc, lr

/*
 * MailboxWrite
 * ------------
 * Function to write to mailbox
 * 
 * Parameters
 * r0: Message content, only use top 28 bits, lowest 4 bits should be 0
 * r1: Mailbox, mailbox using 4 bits.
 */
.globl MailboxWrite
MailboxWrite:
tst r0, #0b1111        /* Make sure lowest 4 bits in r0 are all 0 */
movne pc, lr
cmp r1, #15            /* Make sure mailbox is in 4 bits */
movhi pc, lr

MailChannel .req r1
MsgContent .req r2
mov MsgContent, r0
push {lr}

bl GetMailboxBase
mailboxBase .req r0
writeWait$:                              /* Write wait */
status .req r3
ldr status, [mailboxBase, #0x18]        /* Status address is 0x2000B898 */
tst status, #0x80000000                 /* Check top bit is 0 */
.unreq status
bne writeWait$ 

add MsgContent, MailChannel
.unreq MailChannel
str MsgContent, [mailboxBase, #0x20]     /* Send address is 0x2000B8A0 */
.unreq MsgContent
.unreq mailboxBase
pop {pc}

/*
 * MailboxRead
 * -----------
 * Function to read from mailbox
 * 
 * Parameters:
 * r0: mailbox, only using 4 bits.
 * 
 * Return:
 * r0: read message
 */
.globl MailboxRead
MailboxRead:
cmp r0, #15             /* Make sure mailbox is in 4 bits */
movhi pc, lr

MailChannel .req r1
mov MailChannel, r0

push {lr}
bl GetMailboxBase
mailboxBase .req r0

rightMail$:
readWait$:               /* Write wait */
status .req r2
ldr status, [mailboxBase, #0x18]        /* Get status from 0x2000B898 */
tst status, #0x40000000
.unreq status
bne readWait$

MsgContent .req r2
ldr MsgContent, [mailboxBase]
readChannel .req r3
and readChannel,  MsgContent, #0b1111   /* Get read channel */
teq readChannel, MailChannel            /* Make sure channel is match */
.unreq readChannel

bne rightMail$                          /* Repeat if channel is not match*/
.unreq MailChannel
.unreq mailboxBase

and  r0, MsgContent, #0xFFFFFFF0        /* Remove mail channel information in msg */
.unreq MsgContent
pop {pc}
