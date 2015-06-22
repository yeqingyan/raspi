.section .data
.align 1
foreColour:
.hword 0xFFFF

.align 2
graphicsAddress:
.int 0

.align 4
font:
.incbin "font.bin"
.section .text
/*
 * SetForeColour
 * -------------
 * Parameters:
 * r0: Fore colour
 */
.globl SetForeColour
SetForeColour:
cmp r0, #0x10000        /* r0 should lower than 0x10000 */
movhs pc, lr
ldr r1, =foreColour
strh r0, [r1]
mov pc, lr

/*
 * SetGraphicsAddress
 * ------------------
 * Parameters:
 * r0: Graphic Address
 */
.globl SetGraphicsAddress
SetGraphicsAddress:
ldr r1, =graphicsAddress
str r0, [r1]
mov pc, lr

/*
 * SetPixel
 * --------
 * This function only work for high color(16-bit)
 *
 * Parameters:
 * r0: x coordinate
 * r1: y coordinate
 */
.globl SetPixel
SetPixel:

Xcoord .req r0
Ycoord .req r1
graphAddr .req r2
ldr graphAddr, =graphicsAddress
ldr graphAddr, [graphAddr]

height .req r3
ldr height, [graphAddr, #4]     /* Get Height */
sub height, #1
cmp Ycoord, height              /* Check height */
movhi pc, lr
.unreq height

width .req r3
ldr width, [graphAddr]          /* Get width */
sub width, #1
cmp Xcoord, width               /* Check width */
movhi pc, lr

/* Compute the address of the pixel to write */
ldr graphAddr, [graphAddr, #32]         /* Get GPU pointer */
add width, #1
mla Xcoord, Ycoord, width, Xcoord       /* Calculate pixel position in memory */
.unreq width
.unreq Ycoord
add graphAddr, Xcoord, lsl #1           
.unreq Xcoord

fore .req r3
ldr fore, =foreColour
ldrh fore, [fore]
strh fore, [graphAddr]
.unreq fore
.unreq graphAddr
mov pc, lr  

/* 
 * DrawLine
 * --------
 * Draw a line by using Bresenham's Algorithm 
 * 
 * Parameters:
 * r0: x0
 * r1: y0
 * r2: x1
 * r3: y1
 */
.globl DrawLine
DrawLine:
push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
x0 .req r9
x1 .req r10
y0 .req r11
y1 .req r12

mov x0, r0
mov x1, r2
mov y0, r1
mov y1, r3

dx .req r4
dyn .req r5 
sx .req r6
sy .req r7
err .req r8

cmp x0, x1
subgt dx, x0, x1
movgt sx, #-1
suble dx, x1, x0
movle sx, #1

cmp y0, y1
subgt dyn, y1, y0
movgt sy, #-1
suble dyn, y0, y1
movle sy, #1

add err, dx, dyn
add x1, sx
add y1, sy

pixelLoop$:
        teq x0, x1
        teqne y0, y1
        popeq {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

        mov r0, x0
        mov r1, y0
        bl SetPixel

        cmp dyn, err, lsl #1
        addle err, dyn
        addle x0, sx

        cmp dx, err, lsl #1
        addge err, dx
        addge y0, sy

        b pixelLoop$

.unreq x0
.unreq x1
.unreq y0
.unreq y1
.unreq dx
.unreq dyn
.unreq sx
.unreq sy
.unreq err

/*
 * DrawCharacter 
 * -------------
 * Parameters:
 * r0: character
 * r1: x
 * r2: y
 */
.globl DrawCharacter
DrawCharacter:
push {r4, r5, r6, r7, r8, lr}
Character .req r3
px .req r4
py .req r5

mov Character, r0
cmp Character, #127     /* character should less than 127*/
movhi r0, #0            /* return error */
movhi r1, #1    
movhi pc, lr

charAddress .req r6
mov px, r1
mov py, r2
ldr charAddress, =font
add charAddress, Character, lsl #4          /* set char base address*/

bits .req r7
bit .req r8
RowLoop$:

        ldrb bits, [charAddress]
        mov bit, #8
        BitLoop$:
                subs bit, #1
                blt BitLoopEnd$         /* If bit < 1, end BitLoop */
                lsl bits, #1
                tst bits, #0x100
                beq BitLoop$

                add r0, px, bit 
                mov r1, py  
                bl SetPixel             /* if bit is 1, draw it on screen */
                
                teq bit, #0             /* Never run into this line? */
                bne BitLoop$
        BitLoopEnd$:
        .unreq bit
        .unreq bits
        add py, #1
        add charAddress, #1
        tst charAddress, #0b1111
        bne RowLoop$

.unreq Character
.unreq charAddress
.unreq px
.unreq py
width .req r0
height .req r1
mov width, #8
mov height, #16
pop {r4, r5, r6, r7, r8, pc}
.unreq width
.unreq height

/*
 * DrawString
 * ----------
 * Parameters:
 * r0: string
 * r1: length
 * r2: x
 * r3: y
 */
.globl DrawString
DrawString:

x .req r4
y .req r5
x0 .req r6
String .req r7
length .req r8
char .req r9
push {r4, r5, r6, r7, r8, r9, lr}

mov String, r0
mov length, r1
mov x, r2
mov y, r3

mov x0, x

PositionLoop$: 
        subs length, #1
        blt PositionLoopEnd$

        ldrb char, [String]
        add string, #1

        mov r0, char
        mov r1, x
        mov r2, y
        bl DrawCharacter
        cwidth .req r0
        cheight .req r1 
        
        teq char, #'\n'         /* New line */
        moveq x, x0
        addeq y, cheight
        beq PositionLoop$
        
        teq char, #'\t'         /* Tab */
        addne x, cwidth
        bne PositionLoop$
        
        add cwidth, cwidth, lsl #2
        x1 .req r1
        mov x1, x0

        TabLoop$:
                add x1, cwidth
                cmp x, x1
                bge TabLoop$
        mov x, x1
        .unreq x1
        b PositionLoop$
PositionLoopEnd$:
.unreq cwidth
.unreq cheight

pop {r4, r5, r6, r7, r8, r9, pc}
.unreq x
.unreq y
.unreq x0
.unreq String
.unreq length
.unreq char
