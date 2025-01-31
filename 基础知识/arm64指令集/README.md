[基础知识笔记](https://zhuzhuzhus.github.io/2024/09/01/aarch64/)
## arm64指令
### 加载与存储指令
#### LDR STR 指令
前变基的LDR指令编码如下所示:
- 0-4位用来描述目标寄存器
- 5-8位用来描述源寄存器
- 12-20位用来描述源寄存器的偏移量
- 21-29位用于指令分类
- 30-31位为size字段,为0b11时表示64位,为0b10时表示32位

#### 基于基地址的寻址模式
1. 基地址寻址
    ~~~asm
    LDR Xt,[Xn] //以Xn寄存器中的内容作为内存地址,加载此地址的内容到Xt寄存器中
    STR Xt,[Xn] //以Xn寄存器中的内容作为内存地址,将Xt寄存器中的内容存储到此地址中
    ~~~
2. 基地址偏移寻址
    ~~~asm
    LDR Xt,[Xn,#imm] //以Xn寄存器中的内容加上imm偏移量作为内存地址,加载此地址的内容到Xt寄存器中
    STR Xt,[Xn,#imm] //以Xn寄存器中的内容加上imm偏移量作为内存地址,将Xt寄存器中的内容存储到此地址中
    ~~~
    - Xt: 目标寄存器
    - Xn: 基地址寄存器
    - imm: 立即数,表示地址偏移量,偏移量大小为imm12(指令10-21位)的8倍范围为0-32760B,所以这个立即数必须为8的倍数
3. 基地址扩展模式
    ~~~asm
    LDR <Xt>,[Xn,(Xm)]{,<extend> {<amount>}}
    STR <Xt>,[Xn,(Xm)]{,<extend> {<amount>}}
    ~~~
    参数如下:
    - Xt: 目标寄存器
    - Xn: 基地址寄存器
    - Xm: 用来表示偏移的寄存器
    - extend: 表示扩展模式,默认为LSL,对应编码中的option字段(13-15位):
        - 为010时,extend编码为UXTW,表示从寄存器中提取32位数据,高位填充0
        - 为011时,extend编码为LSL,表示逻辑左移
        - 为110时,extend编码为SXTW,表示从寄存器中提取32位数据,高位填充符号位
        - 为111时,extend编码为SXTX,表示从寄存器中提取64位数据。
    - amount: 索引偏移量,当extend参数为LSL时,可以省略,否则需要指定。
详见p40

#### 变基模式
1. 前变基模式
    ~~~asm
    LDR <Xt>,[<Xn>,#imm]!
    STR <Xt>,[<Xn>,#imm]!
    ~~~
    首先更新Xn寄存器的值,然后将Xn寄存器中的内容加上imm偏移量作为内存地址,加载此地址的内容到Xt寄存器中,或者将Xt寄存器中的内容存储到此地址中。
2. 后变基模式
    ~~~asm
    LDR <Xt>,[<Xn>],#imm
    STR <Xt>,[<Xn>],#imm
    ~~~
    首先将Xn寄存器中的内容作为内存地址,加载此地址的内容到Xt寄存器中,或者将Xt寄存器中的内容存储到此地址中,然后更新Xn寄存器的值。

#### PC相对寻址

~~~asm
LDR <Xt>,<label>
~~~
这条指令将label所在内存地址的内容读到Xt寄存器中,但是这个label必须在当前PC地址前后1MB范围内。

~~~asm
mydata:
    .word 0x12345678
ldr x0, mydata
~~~
ldr指令将mydata所在内存地址的内容读到x0寄存器中,最终x0=0x12345678。

~~~asm
#define OFFSET 0x20
ldr x0, OFFSET
~~~
ldr会读取pc+offset地址的内容到x0寄存器中。

#### LDR伪指令
伪指令是对汇编器发出的命令,在源程序汇编期间由汇编器进行处理,一条伪指令可以分解为几条指令的集合
~~~asm
ldr x0, =0x12345678
~~~
这条指令将0x12345678读到x0寄存器中。

~~~asm
mydata:
   .quad 0x8

ldr x0, =mydata
ldr x2,[x0]
~~~
mydata是一个64位的地址,ldr x0,=mydata将mydata的地址读到x0寄存器中,ldr x2,[x0]将x0寄存器中的内容作为地址,读取此地址的内容到x2寄存器中,最终x2=0x8。

#### 多字节内存加载和存储指令LDP STP
LDP和STP指令用于加载和存储多个寄存器的值,它们的编码格式如下:
LDP指令:
~~~asm
LDP <Xt1>,<Xt2>,[<Xn>{,#<imm>}]
~~~
他以Xn寄存器中的内容作为内存地址,读取此地址＋imm地址的值到Xt1寄存器,读取此地址＋imm＋8地址的值到Xt2寄存器。
STP指令:
~~~asm
STP <Xt1>,<Xt2>,[<Xn>{,#<imm>}]
~~~
他以Xn寄存器中的内容作为内存地址,将Xt1寄存器中的内容存储到此地址＋imm地址中,将Xt2寄存器中的内容存储到此地址＋imm＋8地址中。

前变基与后变基与ldr指令类似。

**偏移量必须在-512-504并且必须为8的倍数**

#### mov指令
这里不过多介绍mov指令,只针对介绍mov指令使用的一些要点
1. mov指令能搬运的立即数只有两种
    - 16位的立即数
    - 16位立即数左移16位,32位或者48位后的立即数
2. 能搬运一些用于位图的立即数,此时等于orr指令

#### 陷阱

~~~asm
#define MY_LABEL 0X30
ldr x0, =MY_LABEL #伪指令,x0 = 0x30
ldr x0, MY_LABEL  #x0为PC+0x30地址中的值

mydata:
~~~

### 算术与移位指令
首先了解操作符后缀
| 条件码 | 后缀助记符 |    标志位     |                             定义                             |
| :----: | :--------: | :-----------: | :----------------------------------------------------------: |
|  0000  |     EQ     |      Z=1      |                             相等                             |
|  0001  |     NE     |      Z=0      |                            不相等                            |
|  0010  |   CS/HS    |      C=1      |                      无符号大于或者等于                      |
|  0011  |   CC/LO    |      C=0      |                          无符号小于                          |
|  0100  |     MI     |      N=1      |                             负值                             |
|  0101  |     PL     |      N=0      |                           正值或0                            |
|  0110  |     VS     |      V=1      |                             溢出                             |
|  0111  |     VC     |      V=0      |                            无溢出                            |
|  1000  |     HI     |   C=1且Z=0    |                          无符号大于                          |
|  1001  |     LS     |   C=0或Z=1    |                       无符号小于或等于                       |
|  1010  |     GE     |   N和V相同    |                       有符号大于或等于                       |
|  1011  |     LT     |   N和V不同    |                          有符号小于                          |
|  1100  |     GT     |  Z=0且N等于V  |                          有符号大于                          |
|  1101  |     LE     | Z=1或N不等于V |                       有符号小于或等于                       |
|  1110  |     AL     |     默认      |                            无条件                            |
|  1111  |     NV     |               | 无条件 |


#### 加法与减法指令

1. 使用立即数的加法指令
    ~~~asm
    add <Rd>,<Rn>,#<imm>{,<shift>}
    ~~~
    使用立即数的加法指令:
    正确的用法:
    ~~~asm
    add x0,x1,#1
    add x0,x1,#1 lsl 12
    ~~~
    错误的用法:
    ~~~asm
    add x0,x1,#4096
    add x0,x1,#1 lsl 1
    ~~~

    上面错误用法的原因是在使用立即数的add指令中对立即数的处理只占指令中的12位,所以最大只能表示4095,而sh字段只有一位,表示无位移或者左移12位。
2. 使用寄存器的加法指令
    ~~~asm
    add <Rd>,<Rn>,<Rm>{,<extend> {#amount}}
    ~~~
    重点关注extend和amount字段。
    extend对应指令编码的option字段,option的值和表达效果对应如下:
    - 000 表示对8位数据进行无符号扩展               UXTB
    - 001 表示对16位数据进行无符号扩展              UXTH
    - 010 表示对32位数据进行无符号扩展              UXTW
    - 011 表示对64位数据进行无符号扩展|逻辑左移操作  LSL|WXTX
    - 100 表示对8位数据进行有符号扩展               SXTB
    - 101 表示对16位数据进行有符号扩展              SXTH
    - 110 表示对32位数据进行有符号扩展              SXTW
    - 111 表示对64位数据进行有符号扩展              SXTX
    amount:当extend为lsl操作时,它的取值范围是0-4,对应指令编码中的imm3字段
    ~~~asm
    mov x1,#1
    mov x2,#0x108a
    add x0,x1,x2,UXTB #x0=0x8b
    add x0,x1,x2,SXTB #x0=0xffffffffffffff8b
    ~~~
3. 使用移位操作的加法指令
    ~~~asm
    add <xd>,<xn>,<xm>{,<shift> #<amount>}
    ~~~
    - shift:对应指令编码中的shift字段,shift字段的值和表达效果对应如下:
        - 000 表示LSL操作
        - 001 表示LSR操作
        - 010 表示ASR操作
    - amount:移位的数量,取值范围为0-63

    例:
    ~~~asm
    add x0,x1,x2,lsl 13 #x0=x1+x2<<13
    ~~~
**ADDS是ADD指令的变种,它的区别在于ADDS指令会影响PSTATE寄存器的NZCV标志位,SUBS同理**

**ADC是进位加法指令,最终的计算结果需要考虑PASTATE寄存器的C标志位,最终计算结果会加上C标志位的值**


subs指令计算方式:`operand1 +NOT(operand2) + 1`NOT(operand2)是对operand2取反。当计算结果发生无符号数溢出时,C=1,计算结果为负数时N=1
当进行无符号计算的时候,当被减数小于减数时不会发生无符号溢出,反之则会发生无符号溢出。

SBC指令会考虑到C标志位计算公式为`option1 + NOT(operand2) + C`

#### CMP 指令
1. 使用立即数的cmp指令
    ~~~asm
    CMP <Xn>,#<imm>{,<shift>}
    ~~~
    等同于
    ~~~asm
    SUBS XZR <Xn>,#<imm> {,{shift}}
    ~~~
    因此立即数最大只能表示4095
2. 使用立即数的CMP指令:
    ~~~asm
    CMP <Xn>,<Xm>{,<extend>,#<amount> }
    ~~~
    等同于
    ~~~asm
    SUBS XZR <Xn>,<Xm> {,<extend>,#<amount>}
    ~~~
    同样amount的取值范围和sub一样
3. 使用移位操作的cmp指令
    ~~~asm
    CMP <Xn>,<Xm>{,<shift> #<amount>}
    ~~~
    等同于
    ~~~asm
    SUBS XZR <Xn>,<Xm>{,<shift> #<amount>}
    ~~~
    同样amount的取值范围和sub一样
4. cmp与条件后缀
    ~~~asm
    cmp x1,x2
    b.cs label
    ~~~
    CMP判断是否触发无符号溢出的计算公司与SUBS类似

#### 移位指令
1. lsl,逻辑左移指令,最高位会被丢弃,最低位补0
2. lsr,逻辑右移指令,最高位补0,最低位丢弃
3. asr,算术右移指令,最高位补符号位,最低位丢弃
4. ror,循环右移指令,最低为会被移动到最高位

#### 位操作指令
1. and,按位与指令
    ~~~asm
    AND <Xd>,<Xn>,#<imm>
    AND <Xd>,<Xn>,<Xm>{,<shift> #<amount>}
    ~~~
    1. 立即数方式:对Xn寄存器中的内容和imm进行按位与操作,结果存储到Xd寄存器中
    2. 寄存器方式:对Xn寄存器中的内容和Xm寄存器中的内容进行按位与操作,结果存储到Xd寄存器中。
    3. shift表示移位操作,支持所有4种移位指令
    4. amount表示移位的数量,取值范围为0-63
2. ands,带条件标志位的与操作,影响Z标志位,其他与NAD指令相同

1. ORR,按位或指令
    ~~~asm
    ORR <Xd>,<Xn>,#<imm>
    ORR <Xd>,<Xn>,<Xm>{,<shift> #<amount>}
    ~~~
    1. 立即数方式:对Xn寄存器中的内容和imm进行按位或操作,结果存储到Xd寄存器中
    2. 寄存器方式:对Xn寄存器中的内容和Xm寄存器中的内容进行按位或操作,结果存储到Xd寄存器中。
    3. shift表示移位操作,支持所有4种移位指令
    4. amount表示移位的数量,取值范围为0-63
2. EOR,异或指令
    ~~~asm
    EOR <Xd>,<Xn>,#<imm>
    EOR <Xd>,<Xn>,<Xm>{,<shift> #<amount>}
    ~~~
    1. 立即数方式:对Xn寄存器中的内容和imm进行按位异或操作,结果存储到Xd寄存器中
    2. 寄存器方式:对Xn寄存器中的内容和Xm寄存器中的内容进行按位异或操作,结果存储到Xd寄存器中。
    3. shift表示移位操作,支持所有4种移位指令
    4. amount表示移位的数量,取值范围为0-63

1. BIC,按位清除指令
    ~~~asm
    BIC <Xd>,<Xn>,<Xm>{,<shift> #<amount>}
    ~~~
    BIC指令支持寄存器模式,先对Xm寄存器中的内容进行移位操作,然后对Xn寄存器中的内容和移位后的Xm寄存器中的内容进行位清除操作。

1. CLZ,计算前导零指令
    ~~~asm
    CLZ <Xd>,<Xn>
    ~~~
    CLZ指令用于计算Xn寄存器中的内容中前导零的数量,结果存储到Xd寄存器中,例:
    ~~~asm
    ldr x1,=0x1100000034578000
    clz x0,x1
    ~~~
    x1寄存器里为1的最高位为60位,前面还有3个为0的位,最终X0寄存器的值为3。

#### 位段操作指令

1. BFI指令:
    ~~~asm
    BFI <Xd>,<Xn>,#<lsb>,#<width>
    ~~~
    BFI指令的作用是用Xn寄存器中的Bit[0,width-1]替换Xd寄存器中的Bit[lsb,lsb+width-1],Xd寄存器的其他位不变。
    ~~~asm
    val &= ~(0xf << 4)
    val |= (0x5 << 4)
    ~~~
    上面的代码等价于
    ~~~asm
    mov x0,#0
    mov x1,#0x5
    bfi x0,x1,#4,#4
    ~~~
    上面的代码将x1寄存器中的Bit[0,3]替换到x0寄存器中的Bit[4,7],x0寄存器的其他位不变。
2. UBFX指令:
    ~~~asm
    UBFX <Xd>,<Xn>,#<lsb>,#<width>
    ~~~
    UBFI指令的作用是用Xn寄存器中的Bit[lsb,lsb+width-1]替换Xd寄存器中的Bit[0,width-1],Xd寄存器的其他位不变。
3. SBFX指令在提取字段以后做符号拓展,当提取后的字段中最高位为1时Xd寄存器的高位都要填充1


### 比较与跳转指令
#### 比较指令
1. cmp指令,不过多赘述,前面已经用了很多
2. cmn指令,用于将一个数和另一个数的相反数进行比较,基本格式如下:
    ~~~asm
    CMN <Xn>,#<imm>{,<shift>}
    CMN <Xn>,<Xm>{,<extend> #<amount>}
    ~~~
    上面两条指令相当于如下指令:
    ~~~asm
    ADDS XZR,<Xn>,#<imm>{,<shift>}
    ADDS XZR,<Xn>,<Xm>{,<extend> #<amount>}
    ~~~
    CMN指令的计算过程就是把第一个操作数加上第二个操作数,计算结果会影响PSTATE寄存器的NZCV标志位。
3. CSEL指令
    ~~~asm
    CSEL <Xd>,<Xn>,<Xm>,<cond>
    ~~~
    CSEL指令用于判断cond是否为真,如果为真,则返回Xn,否则返回Xm,把结果写回Xd寄存器。
3. CSET指令
    ~~~asm
    CSET <Xd>,<cond>
    ~~~
    CSET指令用于判断cond是否为真,如果为真,则返回1,否则返回0,把结果写回Xd寄存器。
4. CSINC指令
    ~~~asm
    CSINC <Xd>,<Xn>,<Xm>,<cond>
    ~~~
    CSINC指令用于判断cond是否为真,如果为真返回Xn,否则返回Xm+1,把结果写回Xd寄存器。

#### 跳转与返回指令
1. b LABEL:该跳转指令可以在当前PC偏移量+-128MB范围内跳转
2. b.cond:该跳转指令可以在当前PC偏移量+-1MB范围内跳转
3. BL:和b指令类似,不同的是,BL会将返回地址设置到LR中,保存的值为调用BL指令的当前PC值加上4
4. BR:跳转到寄存器指定地址
5. BLR:BR和BL的结合体

返回指令
1. RET:用于子函数的返回,返回地址保存在LR中
2. ERET:从当前异常中返回。会把SPSR的内容恢复到PSTATE寄存器中,从ELR中获取跳转地址并返回到该地址,可以实现从处理器模式的切换。

比较跳转指令:
1. CBZ:
    ~~~asm
    CBZ <Xn>,LABEL
    ~~~
    当Xn寄存器的值为0时,跳转到LABEL地址,跳转的范围是PC +- 1MB
2. CBNZ:
    ~~~asm
    CBNZ <Xn>,LABEL
    ~~~
    当Xn寄存器的值不为0时,跳转到LABEL地址,跳转的范围是PC +- 1MB
3. TBZ:
    ~~~asm
    TBZ <Xn>,#<lsb>,LABEL
    ~~~
    当Xn寄存器的值的第lsb位为0时,跳转到LABEL地址,跳转的范围是PC +- 32kb
4. TBNZ:
    ~~~asm
    TBNZ <Xn>,#<lsb>,LABEL
    ~~~
    当Xn寄存器的值的第lsb位不为0时,跳转到LABEL地址,跳转的范围是PC +- 32kb

### 其他重要指令
#### PC相对地址加载指令
1. ADR：
    ~~~asm
    ADR <Xd>,LABEL
    ~~~
    ADR指令用于加载一个在当前PC值+-1MB范围内的label地址到Xd寄存器中。
2. ADRP:
    ~~~asm
    ADRP <Xd>,LABEL
    ~~~
    ADRP指令用于加载一个在当前PC值一定范围内的label地址到Xd寄存器中，这个地址与label所在的地址按4KB对齐，偏移量为-4GB~4GB。

**LDR ADRP的区别是LDR伪指令可以寻址64位地址空间，而ADRP指令的寻址范围为当前PC地址 +-4GB.但是LDR伪指令加载的是绝对地址，也就是程序链接阶段的地址，而ADR/ADRP指令加载的是当前PC的相对地址，即当前PC值加上label的偏移量，可以理解为当前运行时label的物理地址，所以：**
+ 当运行地址等于链接地址时，LDR伪指令加载的地址与ADR/ADRP指令加载的地址相同
+ 当运行地址不等于链接地址时，LDR伪指令加载的地址与ADR/ADRP指令加载的地址不同

#### 内存独占访问指令

1. LDXR指令尝试在内存总线中申请一个独占访问的锁，然后访问一个内存地址。
    ~~~asm
    LDXR <Xd>,[<Xn>{,#0}]
    ~~~
2. STXR指令会往刚才LDXR指令已经申请独占访问的内存地址中写入新内容。
    ~~~asm
    STXR Ws,Xt,[Xn{,#0}]
上面两个指令通常组合使用,具体使用后续会详细介绍。

#### 异常处理指令

1. SVC指令
    ~~~asm
    SVC #<imm>
    ~~~
    允许应用程序通过SVC指令自陷到操作系统中，通常会陷入EL1。
2. HVC指令
    ~~~asm
    HVC #<imm>
    ~~~
    允许应用程序通过HVC指令自陷到虚拟机管理程序中，通常会陷入EL2。
3. SMC指令
    ~~~asm
    SMC #<imm>
    ~~~
    允许应用程序通过SMC指令自陷到安全监控程序中，通常会陷入EL3。
#### 系统寄存器访问指令
1. MRS指令
    ~~~asm
    MRS <Xd>,<reg>
    ~~~
    MRS指令用于从系统寄存器中读取数据到Xd寄存器中。
2. MSR指令
    ~~~asm
    MSR <reg>,<Xd>
    ~~~
    MSR指令用于将Xd寄存器中的数据写入到系统寄存器中。
armv8支持以下7类系统寄存器:
1. 通用系统控制寄存器
2. 调试寄存器
3. 性能监控寄存器
4. 活动监控寄存器
5. 统计扩展寄存器
6. RAS寄存器
7. 通用寄存器定时器

除了访问系统寄存器以外，MRS和MSR指令还可以访问与PSTATE寄存器相关的字段。这些字段可以看作特殊的系统寄存器：
| 特殊的系统寄存器 | 说明 |
| :----: | :--------: |
|CurrentEL|获取当前系统的异常等级|
|DAIF|获取和设置PSTATE寄存器的DAIF掩码|
|NZCV|获取和设置PSTATE寄存器的NZCV标志位|
|PAN|获取和设置PSTATE寄存器的PAN标志位|
|SPSel|获取和设置当前异常等级的sp寄存器|
|UAO|获取和设置PSTATE寄存器的UAO标志位|


例：在linux内核代码中使用如下指令来关闭本地处理器的中断
~~~asm
.macro disable_daif
    mrs daifset,#0xf
.endm

.macro enable_daif
    msr daifclr,#0xf
.endm
~~~
disable_daif宏用来关闭本地处理器中的PSTATE寄存器中的DAIF功能，也就是关闭处理器调试，系统错误，IRQ,以及FIQ,而enable_daif宏用来打开上述功能。


下面代码用于设置SP寄存器和获取当前异常等级：
~~~asm
    msr Spsel,#1
    mrs x0,CurrentEL
    cmp x0,#CurrentEL_EL2
    b.eq 1f
~~~

#### 内存屏障指令
1. DMB:数据存储屏障，确保在执行新的存储器访问前所有的存储器访问都已完成。
2. DSB:数据同步屏障，确保在执行下一个指令前前所有的存储器访问都已完成。
3. ISB：指令同步屏障，情况流水线，确保在执行新的指令前，之前所有的指令都已经完成
4. LDAR：加载-获取指令，LDAR指令后面的读写内存指令必须在LDAR指令完成后才能执行。
5. STLR：存储-释放指令，所有的读写指令必须在STLR指令之前执行。
