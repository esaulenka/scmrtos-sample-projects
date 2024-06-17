                                               
//------------------------------------------------------------------------------
MEMORY
{
   MEM_SEG0 : ORIGIN = 0x00000000, LENGTH = 64k
   MEM_SEG1 : ORIGIN = 0x00010000, LENGTH = 64k
   MEM_SEG2 : ORIGIN = 0xFFFFd600, LENGTH = 64k
   DDR      : ORIGIN = 0x00100000, LENGTH = 1M
}

/* Specify the default entry point to the program */

ENTRY(_vector_table)

SECTIONS
{
.text : {
   *(.vectors)
   *(.boot)
   *(EXCLUDE_FILE (*loader.o *main.o) .text)
   *(EXCLUDE_FILE (*loader.o *main.o) .text.*)
 //  *(.text)
 //  *(.text.*)
   *(.gnu.linkonce.t.*)
   *(.plt)
   *(.gnu_warning)
   *(.gcc_execpt_table)
   *(.glue_7)
   *(.glue_7t)
   *(.vfp11_veneer)
   *(.ARM.extab)
   *(.gnu.linkonce.armextab.*)
} > MEM_SEG0
//--------------------------------------------------------------------
.mmu_tbl (ALIGN(0x4000)): {
   __mmu_tbl_start = .;
   KEEP(*(.mmu_tbl))
   __mmu_tbl_end = .;
} > MEM_SEG0
//--------------------------------------------------------------------
.init : {
   KEEP (*(.init))
} > MEM_SEG0
//--------------------------------------------------------------------
.fini : {
   KEEP (*(.fini))
} > MEM_SEG0
//--------------------------------------------------------------------
.rodata : {
   __rodata_start = .;
   *(.rodata)
   *(.rodata.*)
   *(.gnu.linkonce.r.*)
   __rodata_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.rodata1 : {
   __rodata1_start = .;
   *(.rodata1)
   *(.rodata1.*)
   __rodata1_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.sdata2 : {
   __sdata2_start = .;
   *(.sdata2)
   *(.sdata2.*)
   *(.gnu.linkonce.s2.*)
   __sdata2_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.sbss2 : {
   __sbss2_start = .;
   *(.sbss2)
   *(.sbss2.*)
   *(.gnu.linkonce.sb2.*)
   __sbss2_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.data : {
   __data_start = .;
   *(.data)
   *(.data.*)
   *(.gnu.linkonce.d.*)
   *(.jcr)
   *(.got)
   *(.got.plt)
   __data_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.text.align :
{
    . = ALIGN(8);
    __ddr_src_start = .; // start of initialized data label
} > MEM_SEG0
//--------------------------------------------------------------------
.ddr_code : {
    __ddr_code_start = .;
   KEEP ( *main.o (.text) )
   KEEP ( *main.o (.text.*) )
   KEEP ( *loader.o (.text) )
   KEEP ( *loader.o (.text.*) )
    __ddr_code_end = .;

} > DDR AT > MEM_SEG0
//--------------------------------------------------------------------
.data1 : {
   __data1_start = .;
   *(.data1)
   *(.data1.*)
   __data1_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
//.got : {
//   *(.got)
//} > MEM_SEG0
//--------------------------------------------------------------------
.ctors : {
   __CTOR_LIST__ = .;
   ___CTORS_LIST___ = .;
   KEEP (*crtbegin.o(.ctors))
   KEEP (*(EXCLUDE_FILE(*crtend.o) .ctors))
   KEEP (*(SORT(.ctors.*)))
   KEEP (*(.ctors))
   __CTOR_END__ = .;
   ___CTORS_END___ = .;
} > MEM_SEG0
//--------------------------------------------------------------------
.dtors : {
   __DTOR_LIST__ = .;
   ___DTORS_LIST___ = .;
   KEEP (*crtbegin.o(.dtors))
   KEEP (*(EXCLUDE_FILE(*crtend.o) .dtors))
   KEEP (*(SORT(.dtors.*)))
   KEEP (*(.dtors))
   __DTOR_END__ = .;
   ___DTORS_END___ = .;
} > MEM_SEG0
//--------------------------------------------------------------------
.init_array : {
   __init_array_start = .;
   KEEP (*(SORT(.init_array.*)))
   KEEP (*(.init_array))
   __init_array_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.fini_array : {
   __fini_array_start = .;
   KEEP (*(SORT(.fini_array.*)))
   KEEP (*(.fini_array))
   __fini_array_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.ARM.attributes : {
   __ARM.attributes_start = .;
   *(.ARM.attributes)
   __ARM.attributes_end = .;
} > MEM_SEG0
//--------------------------------------------------------------------
.sdata : {
   __sdata_start = .;
   *(.sdata)
   *(.sdata.*)
   *(.gnu.linkonce.s.*)
   __sdata_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.sbss (NOLOAD) : {
   __sbss_start = .;
   *(.sbss)
   *(.sbss.*)
   *(.gnu.linkonce.sb.*)
   __sbss_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.tdata : {
   __tdata_start = .;
   *(.tdata)
   *(.tdata.*)
   *(.gnu.linkonce.td.*)
   __tdata_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.tbss : {
   __tbss_start = .;
   *(.tbss)
   *(.tbss.*)
   *(.gnu.linkonce.tb.*)
   __tbss_end = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.bss (NOLOAD) : {
   __bss_start = .;
   __bss_start__ = .;
   *(.bss)
   *(.bss.*)
   *(.gnu.linkonce.b.*)
   *(COMMON)
   __bss_end = .;
   __bss_end__ = .;
} > MEM_SEG1
//--------------------------------------------------------------------
_SDA_BASE_ = __sdata_start + ((__sbss_end - __sdata_start) / 2 );

_SDA2_BASE_ = __sdata2_start + ((__sbss2_end - __sdata2_start) / 2 );
//--------------------------------------------------------------------
.heap (NOLOAD) : {
   . = ALIGN(16);
   _heap = .;
   HeapBase = .;
   _heap_start = .;
   . += HEAP_SIZE;
   _heap_end = .;
   HeapLimit = .;
} > MEM_SEG1
//--------------------------------------------------------------------
.stack (NOLOAD) : {
   . = ALIGN(16);
   _stack_end = .;
   . += MAIN_STACK_SIZE;
   _stack = .;
   __stack = _stack;
   . = ALIGN(16);
   _irq_stack_end = .;
   . += IRQ_STACK_SIZE;
   __irq_stack = .;
   _supervisor_stack_end = .;
   . += SUPERVISOR_STACK_SIZE;
   . = ALIGN(16);
   __supervisor_stack = .;
   _abort_stack_end = .;
   . += ABORT_STACK_SIZE;
   . = ALIGN(16);
   __abort_stack = .;
   _fiq_stack_end = .;
   . += FIQ_STACK_SIZE;
   . = ALIGN(16);
   __fiq_stack = .;
   _undef_stack_end = .;
   . += UNDEF_STACK_SIZE;
   . = ALIGN(16);
   __undef_stack = .;
} > MEM_SEG2

_end = .;
}
//------------------------------------------------------------------------------

