
    //测试adds和cmp指令的c标志位
adds_cmp_c:
    mov x2,#0x3
    ldr x1,=0xfffffffffffffffe
    adds x0,x1,x2
    adc x0,xzr,xzr

//实现比较x0，x1的大小，如果x0 < x1，返回0xffffffffffffffff，否则返回0
overflow:
    mov x0,#0
    ret

mov x0,#0x200000000
    mov x1,#0x90000000
    cmp x0,x1 //sbc xzr,x0,x1 => x0 + ~x1 + 1
    b.cs overflow
    mov x0,#0xffffffffffffffff


compare_and_return:
	cmp x0, x1
	sbc x0, xzr, xzr
	ret

//x0 >= x1 有符号溢出，c = 1，sbc x0,xzr,xzr = 0 - ~0 + 1 = 1
//x0 < x1 无符号溢出，c = 0，sbc x0,xzr,xzr = 0 - ~0 + 0 = 0xffffffffffffffff



//测试ands对Z标志位的影响
    mov x0,#00
    mov x1,#00
    ands x0,x0,x1
    mrs x1,nzcv
    mov x1,#0xfffffffff
    mrs x1,nzcv

//测试位段操作指令
bfi_ubfi_sbfi:
    mov x1,#0x345
    bfi x0,x1,#8,#4
    ldr x2,=0x5678abcd
    ubfx x3,x2,#4,#8
    sbfx x4,x2,#4,#8

    mrs x1, ID_AA64ISAR0_EL1
    ubfx x2,x1,#4,#4
    ubfx x0,x1,#20,#4