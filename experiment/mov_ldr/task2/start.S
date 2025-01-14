my_memcpy_test:

1:
	ldr x4, [x1], #8
	str x4, [x2], #8
	cmp x1, x3
	b.cc 1b

	ret

loop:
    b loop


memset:

1:
	strb wzr, [x0], #1
	cmp x0, x1
	b.cc 1b
	ret