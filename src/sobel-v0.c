/*
	v0 - initial version 

*/

#include <stdint.h>
#include <stddef.h>
#include "image_data.h"

#define CSR_BASE 0xf0000000L 

#define CSR_FILTRO_SOBEL_DATA_IN_ADDR   (CSR_BASE + 0x800L)
#define CSR_FILTRO_SOBEL_START_ADDR     (CSR_BASE + 0x804L)
#define CSR_FILTRO_SOBEL_DATA_OUT_ADDR  (CSR_BASE + 0x808L)

#define CSR_UART_RXTX_ADDR              (CSR_BASE + 0x2000L)
#define CSR_UART_TXFULL_ADDR            (CSR_BASE + 0x2004L)

#define CSR_READ(addr)        (*(volatile uint32_t *)(addr))
#define CSR_WRITE(addr, val)  (*(volatile uint32_t *)(addr) = (val))

// Vetor na SRAM para guardar a imagem 512x512 filtrada sem travar a UART
static uint8_t imagem_resultado[262144];

void uart_write(char c) {
    while (CSR_READ(CSR_UART_TXFULL_ADDR));
    CSR_WRITE(CSR_UART_RXTX_ADDR, c);
}

void print_str(const char *s) {
    while (*s) {
        uart_write(*s++);
    }
}

void print_hex(uint8_t value) {
    static const char hex[] = "0123456789ABCDEF";
    uart_write(hex[(value >> 4) & 0x0F]);
    uart_write(hex[value & 0x0F]);
}

int main(void) {
    uint32_t total_pixels = IMG_WIDTH * IMG_HEIGHT; 

    print_str("\r\n=== PASSO 1: Processando Hardware (Silencioso) ===\r\n");

    // 1. LAÇO ULTRA-VELOZ: Sem nenhuma chamada de texto interna
    for (uint32_t i = 0; i < total_pixels; i++) {
        // Envia o pixel da imagem
        CSR_WRITE(CSR_FILTRO_SOBEL_DATA_IN_ADDR, input_image[i]);

        // Pulso de Start
        CSR_WRITE(CSR_FILTRO_SOBEL_START_ADDR, 1);
        CSR_WRITE(CSR_FILTRO_SOBEL_START_ADDR, 0);

        // Delay mínimo para sincronismo do hardware
        for (volatile int delay = 0; delay < 20; delay++);

        // Salva direto na RAM do SoC
        imagem_resultado[i] = (uint8_t)(CSR_READ(CSR_FILTRO_SOBEL_DATA_OUT_ADDR) & 0xFF);
    }

    print_str("=== PASSO 2: Imprimindo Matriz Filtrada ===\r\n\r\n");

    // 2. IMPRESSÃO COMPACTA: Exibe o resultado como uma matriz 32x32 real
    for (uint32_t i = 0; i < total_pixels; i++) {
        print_hex(imagem_resultado[i]);
        uart_write(' ');

        // Quebra de linha a cada 32 pixels para formar a imagem na tela
        if ((i % 32) == 31) {
            print_str("\r\n");
        }
    }

    print_str("\r\n=== PROCESSO FINALIZADO COMPLETAMENTE ===\r\n");

    while (1);
    return 0;
}
