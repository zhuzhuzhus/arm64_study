#include "mini_uart.h"


// extern int bltest(int a, int b);
// extern void atomic_test(int nr, volatile unsigned long* addr);
void start_kernel(void)
{
    // int a = bltest(0,3);
    // unsigned long a = 1;
    // atomic_test(1, &a);
    // atomic_test(5, &a);

    uart_init();
    uart_send_string("Hello, World!\n");

    while (1)
    {
        uart_send(uart_recv());
    }
}