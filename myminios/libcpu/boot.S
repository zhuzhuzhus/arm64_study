#include "mm.h"


.section  .rodata
.align 3
el_string1:
	.string "Booting at EL"


.section ".text.boot"
.global _start
.start:
    mrs x0,mpidr_el1
    and x0,x0,#0xff
    cbz x0,master
    b loop

loop:
    b loop

master:
    bl print_el
    adr x0,bss_begin
    adr x1,bss_end
    sub x1,x1,x0
    bl memzero

    mov sp,#LOW_MEMORY
    bl start_kernel
    b loop

print_el:
	mov x10, x30

	/*
	   print EL
	 */
	adrp x0, el_string1
	add x0, x0, :lo12:el_string1
	bl put_string_uart

	mrs x5, CurrentEL
	/* get the currentEL value */
	lsr x2, x5, #2
	mov x0, #48
	add x0, x0, x2
	bl put_uart
	/* print the new line tab */
	mov x0, #10
	bl put_uart

	mov x30, x10
	ret