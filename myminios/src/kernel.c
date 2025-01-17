#include "mini_uart.h"

extern void put_string_uart(unsigned char *s);
void* find_func(unsigned long addr)
{

    extern unsigned long func_table[];
    extern unsigned char function_name[];
    for (int i = 0; i < 3; i++)
    {
        if (func_table[i] == addr)
        {
            unsigned char* p = function_name;
            while (1)
            {
                if (i == 0)
                {
                    put_string_uart(p);
                    put_string_uart((unsigned char *)"\n");
                    break;
                }
                if (*p == '\0')
                {
                    i--;
                }
                p++;

            }

        }
    }
}

// extern int bltest(int a, int b);
// extern void atomic_test(int nr, volatile unsigned long* addr);
void start_kernel(void)
{
    // int a = bltest(0,3);
    // unsigned long a = 1;
    // atomic_test(1, &a);
    // atomic_test(5, &a);
    find_func(0x800800);
    uart_init();
    uart_send_string("Hello, World!\n");

    while (1)
    {
        uart_send(uart_recv());
    }
}