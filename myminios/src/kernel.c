#include "mini_uart.h"

void start_kernel(void)
{
    uart_init();
    uart_send_string("Hello, World!\n");

    while (1)
    {
        uart_send(uart_recv());
    }
}