adr_test:
    adr x0,mytest
    adrp x1,mytest
    ldr x2,[x0]
    ldr x3,[x1]
    ldr x4,mytest //dword value
    ldr x5,=mytest //address value


.global atomic_test
atomic_test:
    mov x3 ,#0x1
    lsl x3,x3,x0
    ldxr x4,[x1]
    orr x4,x4,x3
    stxr w0,x4,[x1]
    ret