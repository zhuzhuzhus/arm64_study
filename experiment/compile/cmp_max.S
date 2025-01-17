

.section data
.align 3
head:
    .string "the max num is %d\n"

.section text

.globl main
main:
	mov x10, x30
    adrp x0, head
	add x0, x0, :lo12:head
    bl put_string_uart
	mov x5, #4
    mov x6, #5
    cmp x5,x6

    csel x7,x5,x6,hi
    mov x0, x7
	add x0,x7,#'0'
    bl put_uart
	mov x0, #10
	bl put_uart
	mov x30, x10
    ret
