
#include <stddef.h>
#include <stdint.h>
#include <array>
#include "z7int.h"

extern isr_ptr_t ps7_handlers[PS7_MAX_IRQ_ID];

//------------------------------------------------------------------------------
class IntIdStack
{
    static const size_t SIZE = 8;
public:
    IntIdStack() : top(0) { }

    uint32_t save()
    {
        CritSect cs;
        uint32_t id = rdpa(GIC_ICCIAR);
        pool[top++] = id;
        return id;
    }

    void restore()
    {
        CritSect cs;
        wrpa(GIC_ICCEOIR, pool[--top]);
    }

private:
    std::array<uint32_t, SIZE> pool;
    size_t                     top;
    uint32_t                   mask;
};
//------------------------------------------------------------------------------

IntIdStack int_id_stack;

extern "C"
{

intptr_t prefetch_abort_addr;
intptr_t data_abort_addr;
intptr_t undefined_exception_addr;

//------------------------------------------------------------------------------
void irq_handler()
{ 
    const uint32_t INT_ID = int_id_stack.save();
    if (INT_ID < PS7_MAX_IRQ_ID)
    {
    #if NESTED_INTERRUPTS_ENABLE == 1
        enable_nested_interrupts();
    #endif
        (*ps7_handlers[INT_ID])();
    #if NESTED_INTERRUPTS_ENABLE == 1
        disable_nested_interrupts();
    #endif
    }
    int_id_stack.restore();
}
//------------------------------------------------------------------------------

void undefined_exception()       { }
void data_abort_exception()      { }
void prefetch_abort_exception()  { }

}  // extern "C"
//------------------------------------------------------------------------------

