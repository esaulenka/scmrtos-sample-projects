
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include <ps7mmrs.h>
#include <z7int.h>
#include <z7ptmr.h>
#include <z7gpio.h>
#include <z7qspi.h>
#include <z7uart.h>

#include <scmRTOS.h>
               

const uint16_t JE1 = 13;
const uint16_t JE2 = 10;

void ttc0_0_isr();
void default_isr();

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

//------------------------------------------------------------------------------
//
//   Message "body"
//
//
class TSlon
{
public:
    TSlon() { }
    virtual void eat() = 0;      // feed the slon. For non-russians: slon == elephant ;)
};
//------------------------------------------------------------------------------
class TAfricanSlon : public TSlon
{
public:
    virtual void eat()
    {
        TCritSect cs;

        gpio::pin_on(JE2);
        gpio::pin_off(JE2);
    }
};
//------------------------------------------------------------------------------
class TIndianSlon : public TSlon
{
public:
    virtual void eat()
    {
        TCritSect cs;

        gpio::pin_on(JE2);
        gpio::pin_off(JE2);
        gpio::pin_on(JE2);
        gpio::pin_off(JE2);
    }
};
//------------------------------------------------------------------------------

TAfricanSlon African;
TIndianSlon  Indian;

OS::channel<TSlon*, 8> SlonQueue; // OS::channel object for 8 'TSlon*' items

OS::TEventFlag ef_timer;

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
    uart1.send(print_buf);                             //
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
        ps7_register_isr(&default_isr, i);
    }

    ps7_register_isr(&ttc0_0_isr, PS7IRQ_ID_TTC0_0);

    gic_int_enable(PS7IRQ_ID_UART1);
    gic_set_target(PS7IRQ_ID_UART1, GIC_CPU0);

    gic_set_priority(PS7IRQ_ID_TTC0_0, 10);
    gic_set_target(PS7IRQ_ID_TTC0_0, GIC_CPU0);
    gic_int_enable(PS7IRQ_ID_TTC0_0);

    sbpa(GIC_ICCPMR, 0xff);


    //------------------------------------------------------
    //
    //    CPU 0 Private Timer
    //
    OS::start_system_timer(200, 1000, 20);

    //------------------------------------------------------
    //
    //    Initialize peripherals
    //
    uart1.init();
    
    //  TTC0
    wrpa(TTC_CLK_CTRL1_REG0, (2 << TTC_CLK_CTRL1_PS_V_BPOS) |      // set prescaler to 2^(2+1): 100MHz/8 = 12.5MHz
                             (1  << TTC_CLK_CTRL1_PS_EN_BPOS) );   // enable prescaler

    wrpa(TTC_INTERVAL_CNT1_REG0, 12500);                           // 12.5MHz/12500 = 1kHz
    wrpa(TTC_INT_EN1_REG0, 0x1);                                   // enable interval interrupts
    sbpa(TTC_CNT_CTRL1_REG0, 1 << TTC_CNT_CTRL1_INT_BPOS);         // turn on interval mode
    cbpa(TTC_CNT_CTRL1_REG0, 1 << TTC_CNT_CTRL1_DIS_BPOS);         // enable TTC0


    wrpa(GIC_ICCBPR, 2);
    sbpa(GIC_ICDDCR, 0x1);  // enable GIC Distributor
    sbpa(GIC_ICCICR, 0x1);  // enable interruptes for CPU interfaces
    //------------------------------------------------------
    
    enable_interrupts();

    print("scmRTOS: 3-channel sample start!\n");

    OS::run();

}
//------------------------------------------------------------------------------
namespace OS
{
template<> void TProc1::exec()
{
    for(;;)
    {
        ef_timer.wait();
        SlonQueue.push(&African);
    }
}
//---------------------------------------------------------------------------
template<> void TProc2::exec()
{
    for(;;)
    {
        sleep(1);
        SlonQueue.push(&Indian);
    }
}
//---------------------------------------------------------------------------
template<> void TProc3::exec()
{
    for(;;)
    {
        //--------------------------------------------------
        //
        //            Channel test
        //
        //
        //     Get data through channel
        //
        TSlon *p;
        SlonQueue.pop(p);     // get pointer from queue
        p->eat();             // feed the appropriate Slon
    }
}

}  // namespace OS
//---------------------------------------------------------------------------
//void OS::system_timer_user_hook() { }
//---------------------------------------------------------------------------
#if scmRTOS_IDLE_HOOK_ENABLE
void OS::idle_process_user_hook()
{
    __wfi();
}
#endif
//------------------------------------------------------------------------------
void ttc0_0_isr()
{
    OS::TISRW isr;

    rdpa(TTC_INT1_REG0);     // clear TTC0_0 interrupt flag
    ef_timer.signal_isr();
}
//------------------------------------------------------------------------------
void default_isr()
{
    __nop();
    __dsb();
    __isb();
}
//------------------------------------------------------------------------------

