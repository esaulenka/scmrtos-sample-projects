
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include <ps7mmrs.h>
#include "z7int.h"
#include "z7ptmr.h"
#include "z7gpio.h"
#include "z7qspi.h"
#include "z7uart.h"


#include <scmRTOS.h>
               
const uint32_t PIN_INT = 50;

void swi_isr_handler();
void ptmr_isr_handler();
void gpio_isr_handler();
void default_isr_handler();

Uart uart1(UART1_ADDR);

//---------------------------------------------------------------------------
//
//      Process types
//
typedef OS::process<OS::pr0, 404> TProc1;
typedef OS::process<OS::pr1, 400> TProc2;
typedef OS::process<OS::pr2, 400> TProc3;
//---------------------------------------------------------------------------
//
//      Process objects
//
TProc1 Proc1;
TProc2 Proc2;
TProc3 Proc3;

//---------------------------------------------------------------------------
//
//      Test objects
//
struct TMamont                   //  data type for sending by message
{                                //
    enum TSource
    {
        PROC_SRC,
        ISR_SRC
    }
    src;
    int data;                    //
};                               //

OS::message<TMamont> MamontMsg;  // OS::message object

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
    //TxBuf.write(print_buf, size);                      // put formatted data to port buffer
                                                       //
    return size;
}
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
int main() 
{ 
    //----------------------------------------------------------------
    //
    //    Setup interrupts
    //

    //------------------------------------------------------
    //
    //    Initialize interrupt handlers table
    //
    for(uint32_t i = 0; i < PS7_MAX_IRQ_ID; ++i)
    {
        ps7_register_isr_handler(&default_isr_handler, i);
    }

    ps7_register_isr_handler(&swi_isr_handler,   PS7IRQ_ID_SW15);
    //ps7_register_isr_handler(&ptmr_isr_handler,  PS7IRQ_ID_PTMR);
    ps7_register_isr_handler(&OS::system_timer_isr,  PS7IRQ_ID_PTMR);
    ps7_register_isr_handler(&gpio_isr_handler,  PS7IRQ_ID_GPIO);

    //------------------------------------------------------
    //
    //    Setup GPIO interrupt
    //
//  gpio_clr_int_sts(PIN_INT);
//  gpio_int_pol(PIN_INT, GPIO_INT_POL_HIGH_RISE);
//  gpio_int_en(PIN_INT);

    gic_int_enable(PS7IRQ_ID_UART1);
    gic_set_target(PS7IRQ_ID_UART1, GIC_CPU0);

    gic_set_target(PS7IRQ_ID_GPIO, 1ul << GIC_CPU0);
    gic_set_config(PS7IRQ_ID_GPIO, GIC_EDGE_SINGLE);
    gic_int_enable(PS7IRQ_ID_GPIO);

    sbpa(GIC_ICCPMR, 0xff);
    gic_set_priority(PS7IRQ_ID_SW15, 30);    // lowest priority


    //------------------------------------------------------
    //
    //    CPU 0 Private Timer
    //
    gic_set_priority(PS7IRQ_ID_PTMR, 5);
    gic_int_enable(PS7IRQ_ID_PTMR);
    PrivateTimer::set_reload_value(200, 1000); // MHz, us
    PrivateTimer::start();

    //------------------------------------------------------
    //
    //    Initialize peripherals
    //
    uart1.init();

    wrpa(GIC_ICCBPR, 2);
    sbpa(GIC_ICDDCR, 0x1);  // enable GIC Distributor
    sbpa(GIC_ICCICR, 0x1);  // enable interruptes for CPU interfaces

    enable_interrupts();

    print("cam: program start!\n");

//  uint32_t n = 100;
//
//  for(;;)
//  {
//      if(--n == 0)
//      {
//          n = 10000;
//          wrpa( GIC_ICDSGIR,                                   // 0b10: send the interrupt on only to the CPU
//                (2 << GIC_ICDSGIR_TARGET_LIST_FILTER_BPOS) +   // interface that requested the interrupt
//                 PS7IRQ_ID_SW15                                // rise software interrupt ID15
//                );
//      }
//  }

    OS::run();

}
//------------------------------------------------------------------------------
namespace OS
{
    template <>
    OS_PROCESS void TProc1::exec()
    {
        for(;;)
        {
            MamontMsg.wait();               // wait for message
            TMamont Mamont = MamontMsg;     // read message content into local TMamont variable

            if (Mamont.src == TMamont::PROC_SRC)
            {
                gpio::pin_off(10); // JE2 off
                //PB0.Off();                  // show that message received from other process
            }
            else
            {
                gpio::pin_off(10); // JE2 off
                gpio::pin_on(10);  // JE2 on
                gpio::pin_off(10); // JE2 off
//              PB0.Off();                  // show that message received from isr
//              PB0.On();
//              PB0.Off();
            }
        }
    }

    template <>
    OS_PROCESS void TProc2::exec()
    {
        for(;;)
        {
            sleep(100);
        }
    }
        
    template <>
    OS_PROCESS void TProc3::exec()
    {
        for (;;)
        {
            sleep(1);
            TMamont m;                      // create message content
            m.src  = TMamont::PROC_SRC;
            m.data = 5;
            MamontMsg = m;                  // put the content to the OS::message object
            gpio::pin_on(10); // JE2 on
            //PB0.On();
            MamontMsg.send();               // send the message
        }
    }
}

void OS::system_timer_user_hook()
{
    TMamont m;                              // create message content
    m.src  = TMamont::ISR_SRC;
    m.data = 10;
    MamontMsg = m;                          // put the content to the OS::message object
    gpio::pin_on(10); // JE2 on
    //PB0.On();
    MamontMsg.send_isr();                   // send the message
}

#if scmRTOS_IDLE_HOOK_ENABLE
void OS::idle_process_user_hook()
{
    __WFI();
}
#endif


//------------------------------------------------------------------------------
void ptmr_isr_handler()
{
//  volatile auto slon = 0;
//
//  gpio::pin_on(10);  // JE2 on
//  for(size_t i = 0; i < 1000; ++i)
//  {
//      ++slon;
//  }
//  gpio::pin_off(10); // JE2 off
    
}
//------------------------------------------------------------------------------
void gpio_isr_handler()
{
    //write_pa(GPIO_INT_STAT_1_REG, 1ul << 18);
    gpio_clr_int_sts(PIN_INT);

    wrpa(GPIO_MASK_DATA_0_LSW_REG, (~(1ul << 7) << 16) | (1ul << 7) );
    wrpa(GPIO_MASK_DATA_0_LSW_REG, (~(1ul << 7) << 16) | 0 );

}
//------------------------------------------------------------------------------
void swi_isr_handler()
{
    volatile auto slon = 0;
    gpio::pin_on(13);
    for(size_t i = 0; i < 1000; ++i)
    {
        ++slon;
    }
    gpio::pin_off(13);
}
//------------------------------------------------------------------------------
void default_isr_handler()
{
    __nop();
    __dsb();
    __isb();
}
//------------------------------------------------------------------------------

