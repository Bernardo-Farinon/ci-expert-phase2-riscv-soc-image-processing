-------------------------------------------------------------------------------
1) Compilar o firmware (dentro da pasta scr)
-------------------------------------------------------------------------------

~$ riscv64-unknown-elf-gcc -O3 -march=rv32im -mabi=ilp32 \
    -ffreestanding -nostartfiles -nodefaultlibs \
    -T linker.ld start.S sobel.c -o firmware.elf
    
~$ riscv64-unknown-elf-objcopy -O binary firmware.elf firmware.bin


-------------------------------------------------------------------------------
2) Executar a simulação carregando o Firmware com capacidade de processamento
        para imagens de 512x512 pixels
-------------------------------------------------------------------------------
~$ ./soc_riscv_litex_acc_sim.py --cpu-type=vexriscv \
    --integrated-rom-init=firmware.bin \
    --integrated-rom-size=0x80000 \
    --integrated-sram-size=0x80000 \
    | tee log_sim.txt


-------------------------------------------------------------------------------
3) Executar a simulação carregando o Firmware e gerando o arquivo VCD
-------------------------------------------------------------------------------
~$ ./soc_riscv_litex_acc_sim.py --cpu-type=vexriscv \
    --integrated-rom-init=firmware.bin \
    --integrated-rom-size=0x8000 \
    --integrated-sram-size=0x40000 \
    --trace 

