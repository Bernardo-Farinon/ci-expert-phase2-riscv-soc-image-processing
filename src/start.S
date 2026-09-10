.section .text
.global _start

_start:
    la sp, _stack_top   /* Carrega automaticamente o endereço correto */
    call main

_hang:
    j _hang
