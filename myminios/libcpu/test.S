

.section .data
.global func_table
func_table:
	.quad 0x800800
	.quad 0x800860
	.quad 0x800880

.global function_name
function_name:
	.asciz "func_a"
	.asciz "func_b"
	.asciz "func_c"