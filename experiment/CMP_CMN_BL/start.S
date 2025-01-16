

cmn:
    cmn x1,x2
    mrs x0,nzcv
    mov x0,#0
    adds x2,x2,#1
    b.mi cmp
    ret

// x2 >= x1 ? x1++ ,cmp : ret
cmp:
    cmp x1,x2
    b.ls addddd
    ret

addddd:
    add x1,x1,#1
    b cmp


//x0 == 0 ? x0 = x1 + 2 : x0 = x1 - 1
chose:
    add x2,x1,#2
    sub x3,x1,#1
    cmp x0,#0
    csel x0,x2,x3,eq
    ret

.global bltest
bltest:
    b chose