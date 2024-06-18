//------------------------------------------------------------------------------
//
//    Application Program Entry Point Source
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

.global __start

.global __stack
.global __irq_stack
.global __supervisor_stack
.global __abort_stack
.global __fiq_stack
.global __undef_stack
.global __vector_table

.set Undef_stack,   __undef_stack
.set FIQ_stack,     __fiq_stack
.set Abort_stack,   __abort_stack
.set SPV_stack,     __supervisor_stack
.set IRQ_stack,     __irq_stack
.set SYS_stack,     __stack

.set vector_base,   __vector_table

__start:

    /* set VBAR to the _vector_table address in linker script */
    ldr r0, =vector_base
    mcr p15, 0, r0, c12, c0, 0

    mrs r0, cpsr                /* get the current PSR */
    mvn r1, #0x1f               /* set up the irq stack pointer */
    and r2, r1, r0
    orr r2, r2, #0x12           /* IRQ mode */
    msr cpsr, r2
    ldr r13,=IRQ_stack          /* IRQ stack pointer */
    bic r2, r2, #(0x1 << 9)          /* Set EE bit to little-endian */
    msr spsr_fsxc,r2

    mrs r0, cpsr                /* get the current PSR */
    mvn r1, #0x1f               /* set up the supervisor stack pointer */
    and r2, r1, r0
    orr r2, r2, #0x13           /* supervisor mode */
    msr cpsr, r2
    ldr r13,=SPV_stack          /* Supervisor stack pointer */
    bic r2, r2, #(0x1 << 9)     /* Set EE bit to little-endian */
    msr spsr_fsxc,r2

    mrs r0, cpsr                /* get the current PSR */
    mvn r1, #0x1f               /* set up the Abort  stack pointer */
    and r2, r1, r0
    orr r2, r2, #0x17           /* Abort mode */
    msr cpsr, r2
    ldr r13,=Abort_stack        /* Abort stack pointer */
    bic r2, r2, #(0x1 << 9)     /* Set EE bit to little-endian */
    msr spsr_fsxc,r2

    mrs r0, cpsr                /* get the current PSR */
    mvn r1, #0x1f               /* set up the FIQ stack pointer */
    and r2, r1, r0
    orr r2, r2, #0x11           /* FIQ mode */
    msr cpsr, r2
    ldr r13,=FIQ_stack          /* FIQ stack pointer */
    bic r2, r2, #(0x1 << 9)     /* Set EE bit to little-endian */
    msr spsr_fsxc,r2

    mrs r0, cpsr               /* get the current PSR */
    mvn r1, #0x1f              /* set up the Undefine stack pointer */
    and r2, r1, r0
    orr r2, r2, #0x1b           /* Undefine mode */
    msr cpsr, r2
    ldr r13,=Undef_stack        /* Undefine stack pointer */
    bic r2, r2, #(0x1 << 9)     /* Set EE bit to little-endian */
    msr spsr_fsxc,r2

    mrs r0, cpsr                /* get the current PSR */
    mvn r1, #0x1f               /* set up the system stack pointer */
    and r2, r1, r0
    orr r2, r2, #0x1F           /* SYS mode */
    msr cpsr, r2
    ldr r13,=SYS_stack          /* SYS stack pointer */

    b   __cstart               /* jump to C startup code */
    and r0, r0, r0             /* no op */

.Ldone: b   .Ldone              /* Paranoia: we should never get here */

.end
