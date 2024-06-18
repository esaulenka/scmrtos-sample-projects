//------------------------------------------------------------------------------
//
//    Bootloader Main Source
//
//    Permission is hereby granted, free of charge, to any person
//    obtaining  a copy of this software and associated documentation
//    files (the "Software"), to deal in the Software without restriction,
//    including without limitation the rights to use, copy, modify, merge,
//    publish, distribute, sublicense, and/or sell copies of the Software,
//    and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included
//    in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
//    THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//    Copyright (c) 2017-2024, Zynq-7000 Bare-metal Project
//    -----------------------------------------------------
//    Project sources: https://github.com/z7bm
//
//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include <ps7mmrs.h>
#include <ps7_init.h>
#include <z7gpio.h>
#include <z7int.h>
#include <z7qspi.h>
#include <z7uart.h>
        
//---------------------------------------------------------------------------
//
//      Declarations
//
const uint32_t JE1 = 13;    // Zed Board
const uint32_t JE2 = 10;    // Zed Board

void default_isr_handler();
void cpy32(uint32_t *const dst, const uint32_t *src, const size_t count);

const uint32_t QSPI_BUF_SIZE = 1024;

uint32_t QSpiBuf[QSPI_BUF_SIZE];
//TQSpi QSpi(QSpiBuf);

extern uint32_t QSpiBuf_ddr[QSPI_BUF_SIZE];

TQSpi QSpi_ddr(QSpiBuf_ddr);

Uart  uart1(UART1_ADDR);

//------------------------------------------------------------------------------

const int TX_BUF_SIZE = 256;

char print_buf[TX_BUF_SIZE];
int print(const char *format, ...)
{
    va_list args;                                      //
    va_start(args, format);                            //
    uint16_t size = vsprintf(print_buf, format, args); //
    va_end(args);                                      //
                                                       //
    uart1.send(print_buf);
                                                       //
    return size;
}
//------------------------------------------------------------------------------
void remap_mmu_tt(uintptr_t src, uintptr_t dst)
{
    cpy32(reinterpret_cast<uint32_t*>(dst), reinterpret_cast<uint32_t*>(src), 4096);
    uint32_t ttbr0 = dst | 0x5b;


    uint32_t tmp;
    __asm__ __volatile__("mrc p15, 0, %[tmp], c1, c0, 0\n\t"
                         "bic %[tmp], %[tmp], #0x1\n\t"
                         "mcr p15, 0, %[tmp], c1, c0, 0\n\t"
                         : [tmp] "=r" (tmp)
                         :       "r"  (tmp));

    __asm__ __volatile__("mcr p15, 0, %1, c2, c0, 0"
                         : "=r" (ttbr0)
                         : "r"  (ttbr0));

    __asm__ __volatile__("mrc p15, 0, %[tmp], c1, c0, 0\n\t"
                         "orr %[tmp], %[tmp], #0x1\n\t"
                         "mcr p15, 0, %[tmp], c1, c0, 0\n\t"
                         "dsb\n\t"
                         "isb\n\t"
                         : [tmp] "=r" (tmp)
                         :       "r"  (tmp));
}
//------------------------------------------------------------------------------
int main() 
{ 
    //----------------------------------------------------------------
    //
    //    relocate and remap MMU translate table
    //
    remap_mmu_tt(MMU_TT_INIT_ADDR, MMU_TT_ADDR);

    //-----------------------------------------------
    //
    //    set up output pins
    //
    sbpa(GPIO_DIRM_0_REG, 1ul << JE1);
    sbpa(GPIO_OEN_0_REG,  1ul << JE1);
    sbpa(GPIO_DATA_0_REG, 1ul << JE1);
    
    sbpa(GPIO_DIRM_0_REG, 1ul << JE2);
    sbpa(GPIO_OEN_0_REG,  1ul << JE2);
    sbpa(GPIO_DATA_0_REG, 1ul << JE2);

        
    //-----------------------------------------------
    // initialize interrupt handlers table
    for(uint32_t i = 0; i < PS7_MAX_IRQ_ID; ++i)
    {
        ps7_register_isr(&default_isr_handler, i);
    }
    
    gic_int_enable(PS7IRQ_ID_UART1);
    gic_set_target(PS7IRQ_ID_UART1, GIC_CPU0);

    sbpa(GIC_ICCPMR, 0xff);
    sbpa(GIC_ICDDCR, 0x1);   // enable GIC Distributor
    sbpa(GIC_ICCICR, 0x1);   // enable interruptes for CPU interfaces

    enable_interrupts();
    
   // QSpi.init();
    QSpi_ddr.init();
    uart1.init();
    
    print("\n------------------------------------------------\n");
    print("bld: start!\n");
    print("bld: MMU translation table remaped!\n");
    print("bld: go to relocate OCM segments to upper memory and load cam program!\n");

    while(uart1.is_busy()) { } // wait for all pending prints complete

    disable_interrupts();

    //----------------------------------------------------------------
    //
    //    Relocate OCM to upper memory
    //
    slcr_unlock();
    __dsb();
    __isb();

    sbpa(OCM_CFG_REG, 0x07);                                                  // OCM0, OCM1 and OCM2 segments relocate
    slcr_lock();

    wrpa(SCU_CTRL_REG, 0);                                                    // disable SCU address filtering
    wrpa(FILTERING_START_ADDR_REG, 0);
    wrpa(SCU_CTRL_REG, SCU_ADDRESS_FILTERING_ENABLE_MASK | SCU_ENABLE_MASK);  // enable SCU address filtering
    __dmb();
    __isb();

    //----------------------------------------------------------------

    bool load_img(const uint32_t img_addr);
    load_img(0x20000);

    for(;;)
    {
        gpio::pin_on(JE1);
        gpio::pin_off(JE1);
       // QSpi.run();
    }
}
//------------------------------------------------------------------------------
void default_isr_handler()
{
    __nop();
    __dsb();
    __isb();
}
//------------------------------------------------------------------------------
void cpy32(uint32_t * const dst, const uint32_t * src, const size_t count)
{
    for(size_t i = 0; i < count; ++i)
    {
        dst[i] = src[i];
    }
}
//------------------------------------------------------------------------------

