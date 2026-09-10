/* linker.ld */
OUTPUT_FORMAT("elf32-littleriscv")
ENTRY(_start)

/* Regiões de memória conforme o hardware gerado pelo LiteX */
MEMORY {
    rom     : ORIGIN = 0x00000000, LENGTH = 0x00080000  /* 512 kiB ROM física */
    sram    : ORIGIN = 0x10000000, LENGTH = 0x00080000  /* 512 kiB RAM física */
    csr     : ORIGIN = 0xf0000000, LENGTH = 0x00010000  /* Registradores CSR */
}

SECTIONS {
    /* Todo o código do firmware e constantes ficam na ROM */
    .text : {
        *(.text.start)   /* Garante que o start.S inicialize no endereço 0x0 */
        *(.text .text.*)
        *(.rodata .rodata.*)
    } > rom

    /* Variáveis globais inicializadas vão para a SRAM */
    .data : {
        *(.data .data.*)
        *(.sdata .sdata.*)
    } > sram AT > rom

    /* Variáveis globais não-inicializadas na SRAM */
    .bss : {
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(COMMON)
    } > sram

    /* Define o topo da pilha (Stack Pointer) no fim da SRAM */
    _stack_top = ORIGIN(sram) + LENGTH(sram);
}
