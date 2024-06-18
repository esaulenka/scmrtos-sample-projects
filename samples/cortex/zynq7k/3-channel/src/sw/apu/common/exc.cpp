//------------------------------------------------------------------------------
//
//    Exception Support Source
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

#include <stddef.h>
#include <stdint.h>
#include <array>

#include <z7int.h>

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

