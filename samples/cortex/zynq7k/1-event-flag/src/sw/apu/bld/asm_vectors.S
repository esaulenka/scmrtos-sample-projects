//------------------------------------------------------------------------------
//
//    Exception Vectors Source
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

//------------------------------------------------------------------------------
    .global _vector_table

    .org 0
    .text

//------------------------------------------------------------------------------
.section .vectors
_vector_table:
    b   _boot
    b   undefined
    b   svc
    b   prefetch_abort
    b   data_abort
    nop                                  // placeholder for address exception vector
    b   irq
    b   fiq
//------------------------------------------------------------------------------
irq:

    stmdb   sp!,{r0-r3,r12,lr}
#if FPU_ENABLE
    vpush   {d0-d7}
    vpush   {d16-d31}
    vmrs     r1, fpscr
    push    {r1}
    vmrs    r1, fpexc
    push    {r1}
#endif

#ifdef PROFILING
    ldr r2, =prof_pc
    subs    r3, lr, #0
    str r3, [r2]
#endif

    bl  irq_handler

#if FPU_ENABLE
    pop     {r1}
    vmsr    fpexc, r1
    pop     {r1}
    vmsr    fpscr, r1
    vpop    {d16-d31}
    vpop    {d0-d7}
#endif
    ldmia     sp!,{r0-r3,r12,lr}

    subs    pc, lr, #4                   // adjust LR to return from IRQ
//------------------------------------------------------------------------------
fiq:
    stmdb   sp!,{r0-r3,r12,lr}
#if FPU_ENABLE
    vpush   {d0-d7}
    vpush   {d16-d31}
    vmrs    r1, fpscr
    push    {r1}
    vmrs    r1, fpexc
    push    {r1}
#endif

    nop                                  // placeholder for FIQ hander

#if FPU_ENABLE
    pop     {r1}
    vmsr    fpexc, r1
    pop     {r1}
    vmsr    fpscr, r1
    vpop    {d16-d31}
    vpop    {d0-d7}
#endif
    ldmia   sp!,{r0-r3,r12,lr}
    subs    pc, lr, #4                   // adjust LR to return from FIQ
//------------------------------------------------------------------------------
undefined:
    stmdb   sp!,{r0-r3,r12,lr}
    ldr     r0, =undefined_exception_addr
    sub     r1, lr, #4
    str     r1, [r0]                     // store address of instruction causing undefined exception

    bl       undefined_exception
    ldmia   sp!,{r0-r3,r12,lr}
    movs    pc, lr                       // return to the next instruction after the undefined instruction
//------------------------------------------------------------------------------
svc:
    stmdb   sp!,{r0-r3,r12,lr}

    tst r0, #0x20                        // check the T bit
    ldrneh  r0, [lr,#-2]                 // Thumb mode
    bicne   r0, r0, #0xff00              // Thumb mode
    ldreq   r0, [lr,#-4]                 // ARM mode
    biceq   r0, r0, #0xff000000          // ARM mode

    nop                                  // placeholder for SVC handler code

    ldmia   sp!,{r0-r3,r12,lr}

    movs    pc, lr                       // return to the next instruction after the svc instruction
//------------------------------------------------------------------------------
data_abort:
    dsb                                  // ARM ERRATA 775420: data cache maintenance operation which aborts, might lead to deadlock

    stmdb   sp!,{r0-r3,r12,lr}
    ldr     r0, =data_abort_addr
    sub     r1, lr, #8
    str     r1, [r0]                     // stores instruction causing data abort

    bl  data_abort_exception

    ldmia   sp!,{r0-r3,r12,lr}

    subs    pc, lr, #8                   // points to the instruction that caused the Data Abort exception
//------------------------------------------------------------------------------
prefetch_abort:
    dsb                                  // ARM ERRATA 775420: data cache maintenance operation which aborts, might lead to deadlock

    stmdb   sp!,{r0-r3,r12,lr}
    ldr     r0, =prefetch_abort_addr
    sub     r1, lr, #4
    str     r1, [r0]                     // stores instruction causing prefetch abort

    bl  prefetch_abort_exception

    ldmia   sp!,{r0-r3,r12,lr}

    subs    pc, lr, #4                   // points to the instruction that caused the Prefetch Abort exception
//------------------------------------------------------------------------------

.end
//------------------------------------------------------------------------------

