



.section .data
.align 3
my_data1:
    .word 50

my_data2:
   .quad 100
print_data:
    .string ".string data : %d\n"

.align 3
.section .text

.globl main
main:
   stp x29, x30, [sp, -16]!
   ldr x5, =my_data1
   ldr x2,[x5]

   ldr x5, =my_data2
   ldr x3,[x5]

   add x1,x2,x3
   ldr x0, =print_data
   ldp x29, x30, [sp], 16
   bl printf
   ret



.macro add_f a,b,label
    mov x0,\a
    mov x1,\b
    bl add_\()\label
.endm

add_1:
	mov x10,x30
    add x0,x0,x1
	mov x0,#1
	add x0,x0,#48
	bl put_uart
	mov x30,x10
    ret
add_2:
    mov x10,x30
    add x0,x0,x1
	mov x0,#2
	add x0,x0,#48
	bl put_uart
    mov x30,x10
    ret