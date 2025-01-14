
    mov x1,#0x8000
    mov x3,#16
    ldr x2,[x1]
    ldr x2,[x1,#8]!
    add x1,x1,x3
    ldr x2,[x1]
    add x1,x1,x3, lsl #3
    ldr x2,[x1]
