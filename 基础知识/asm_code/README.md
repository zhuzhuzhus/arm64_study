## 汇编语法

常用的伪指令
1. 对齐伪指令：`align` 一般有三个参数，第一个参数表示对齐要求，第二个参数表示要填充的值，可以省略，默认为0，第三个参数表示这个对齐指令应该跳过的最大字节数
    下面指令表示按照4字节对齐：
    ~~~asm
    align 2
    ~~~
    下面是使用3个参数的伪指令
    ~~~asm
    .align 5,0,100
    .align 5,0,8
    ~~~
    第一条伪指令设置对多的跳过字节数为100，填充值为0，第二条指令设置最多跳过的字节数小于对齐的字节数，因此不会执行。
2. 数据定义伪指令
    1. .byte :8位数当成数据插入汇编代码中
    2. .hword&&.short :把16位数当成数据插入汇编代码中
    3. .long&&.int&&.word :把32位数当成数据插入汇编代码中
    4. .quad :把64位数当成数据插入汇编代码中
    5. .FLOAT :把浮点数当成数据插入汇编代码中
    6. .ascii&&.string :把string当成数据插入汇编代码中，对于ascii伪操作定义的字符串需要自行添加结尾字符'\0
    7. .asciz :把string当成数据插入汇编代码中，对于asciz伪操作定义的字符串不需要自行添加结尾字符'\0'
    8. .rept&&.endr :重复执行伪操作
    9. .equ :给符号赋值
        ~~~asm
        .rept 3
        .long 0
        .endr
        ~~~
        上述rept伪操作会重复.long 0 3次
2. 与函数相关的伪指令
    1. .global :
    2. .include : 引用头文件
    3. if,else,.endif : 控制语句
    4. .ifdef,.ifndef : 判断定义
    5. .ifc string1,string2 : 判断字符串是否相等
    6. .ifeq expression : 判断expression是否为0
    7. ifeqs string1,string2 : 等同ifc
    8. .ifge expression : 判断expression是否大于等于0
    9. .ifle expression : 判断expression是否小于等于0
    10. .ifne expression :  判断expression是否不等于0
3. 与段相关的伪指令
    1. .section name "flags" : name表示段的名称，flags表示段的属性
        属性：
        1. a:段具有可分配属性
        2. d：具有GNU_MBIMD属性
        3. e：段被排除在可执行和共享库之外
        4. w：段具有可写属性
        5. w
        6. x：段具有可执行属性
        7. M：段具有可合并属性
        8. S：段包含零终止字符串
        9. G：段是段组的成员
        10. T：段用于线程本地存储
    2. .pushsection && .popsection :把代码链接到指定的段，而其他代码还保留在原来的段中:
    ~~~asm
    .section .text

    .global atomic_add
    atomic_add
        ...
        ret

    .pushsection ".idmap.text" , "awx"
    1:
    ldxr x2,[x1]
    orr x2,x2,x0
    ret
    .popsection
    ~~~

4. 与宏相关的伪指令
    1. 在宏里使用参数，需要添加前缀 “\”
        ~~~asm
        .macro add_1 p1 p2
        add x0,\p1,\p2
        .endm
        ~~~
        在定义宏参数时还可以设置一个初始化值，如：
        ~~~asm
        .macro add_data p1=0 p2
        add x0,\p1,\p2
        .endm

        main：
        mov x2,#10
        mov x3,#20
        add_data x2,x3
        add_data ,x3
        ~~~
        调用add_data ,x3时，p1被初始化为0

        在宏参数后面加入:req表示宏调用过程中必须传递一个值，否则编译中会报错：
        ~~~asm
        .macro add_data p1:req p2
        add x0,\p1,\p2
        .endm
        ~~~
        此时调用p1就必须传参
    2. 宏的特殊字符
        下面的代码使用宏的多个参数作为字符串
        ~~~asm
        .macro opcode base length
        \base.\length
        .endm
        ~~~
        在上面代码中 opcode宏想把两个参数串成一个字符串，例如base.length，但是上面的代码时错误的，因为汇编器不知道如何解析base，他不知道base的结束字符在哪里，我们可以使用"\()"来告诉汇编器，宏的参数什么时候结束。将上面代码修改为如下即可：
        ~~~asm
        .macro opcode base length
        \base().\length
        .endm
        ~~~
        

