
//------------------------------------------------------------------------------
MEMORY
{
   OCM_CODE : ORIGIN = 0xFFFC0000, LENGTH = 64k*2
   OCM_DATA : ORIGIN = 0xFFFE0000, LENGTH = 64k*2 - 16k
}

ENTRY(__vector_table)

SECTIONS
{
//--------------------------------------------------------------------
.text : {
   __vectors_start = .;
   KEEP(*(.vectors))
   __vectors_end   = .;
   *(.exhandlers)
   *(.text)
   *(.text.*)
   *(.gnu.linkonce.t.*)
   *(.plt)
   *(.gnu_warning)
   *(.gcc_execpt_table)
   *(.glue_7)
   *(.glue_7t)
   *(.vfp11_veneer)
   *(.ARM.extab)
   *(.gnu.linkonce.armextab.*)
} > OCM_CODE
//--------------------------------------------------------------------
.init : {
   KEEP (*(.init))
} > OCM_CODE
//--------------------------------------------------------------------
.fini : {
   KEEP (*(.fini))
} > OCM_CODE
//--------------------------------------------------------------------
.rodata : {
   __rodata_start = .;
   *(.rodata)
   *(.rodata.*)
   *(.gnu.linkonce.r.*)
   __rodata_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.rodata1 : {
   __rodata1_start = .;
   *(.rodata1)
   *(.rodata1.*)
   __rodata1_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.sdata2 : {
   __sdata2_start = .;
   *(.sdata2)
   *(.sdata2.*)
   *(.gnu.linkonce.s2.*)
   __sdata2_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.sbss2 : {
   __sbss2_start = .;
   *(.sbss2)
   *(.sbss2.*)
   *(.gnu.linkonce.sb2.*)
   __sbss2_end = .;
} > OCM_DATA
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
} > OCM_DATA
//--------------------------------------------------------------------
//.data1 : {
//   __data1_start = .;
//   *(.data1)
//   *(.data1.*)
//   __data1_end = .;
//} > OCM_DATA
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
} > OCM_CODE
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
} > OCM_CODE
//--------------------------------------------------------------------
.init_array : {
   __init_array_start = .;
   KEEP (*(SORT(.init_array.*)))
   KEEP (*(.init_array))
   __init_array_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.fini_array : {
   __fini_array_start = .;
   KEEP (*(SORT(.fini_array.*)))
   KEEP (*(.fini_array))
   __fini_array_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.ARM.attributes : {
   __ARM.attributes_start = .;
   *(.ARM.attributes)
   __ARM.attributes_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.sdata : {
   __sdata_start = .;
   *(.sdata)
   *(.sdata.*)
   *(.gnu.linkonce.s.*)
   __sdata_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.sbss (NOLOAD) : {
   __sbss_start = .;
   *(.sbss)
   *(.sbss.*)
   *(.gnu.linkonce.sb.*)
   __sbss_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.tdata : {
   __tdata_start = .;
   *(.tdata)
   *(.tdata.*)
   *(.gnu.linkonce.td.*)
   __tdata_end = .;
} > OCM_DATA
//--------------------------------------------------------------------
.tbss : {
   __tbss_start = .;
   *(.tbss)
   *(.tbss.*)
   *(.gnu.linkonce.tb.*)
   __tbss_end = .;
} > OCM_DATA
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
} > OCM_DATA
//--------------------------------------------------------------------
_SDA_BASE_ = __sdata_start + ((__sbss_end - __sdata_start) / 2 );

_SDA2_BASE_ = __sdata2_start + ((__sbss2_end - __sdata2_start) / 2 );

//--------------------------------------------------------------------
//.heap (NOLOAD) : {
//   . = ALIGN(16);
//   _heap = .;
//   HeapBase = .;
//   _heap_start = .;
//   . += _HEAP_SIZE;
//   _heap_end = .;
//   HeapLimit = .;
//} > OCM

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
} > OCM_DATA

_end = .;
}
//------------------------------------------------------------------------------

