-------------------------------------------------------------------------------
1) Compilar o firmware (dentro da pasta scr)
-------------------------------------------------------------------------------

~$ riscv64-unknown-elf-gcc -O3 -march=rv32im -mabi=ilp32 \
    -ffreestanding -nostartfiles -nodefaultlibs \
    -T linker.ld start.S sobel.c -o firmware.elf
    
~$ riscv64-unknown-elf-objcopy -O binary firmware.elf firmware.bin


-------------------------------------------------------------------------------
2) Executar a simulação carregando o Firmware com capacidade de processamento
-------------------------------------------------------------------------------

a) Para imagens de 512x512 pixels (512 kiB de memória):

~$ python3 soc_riscv_litex_acc_sim.py --cpu-type=vexriscv \
    --integrated-rom-init=firmware_512x512.bin \
    --integrated-rom-size=0x80000 \
    --integrated-sram-size=0x80000 \
    | tee log_sim.txt

b) Para imagens de 32x32 pixels (32 kiB de memória):

~$ python3 soc_riscv_litex_acc_sim.py --cpu-type=vexriscv \
    --integrated-rom-init=firmware_32x32.bin \
    --integrated-rom-size=0x8000 \
    --integrated-sram-size=0x8000 \
    | tee log_sim.txt


-------------------------------------------------------------------------------
3) Executar a simulação carregando o Firmware e gerando o arquivo VCD
-------------------------------------------------------------------------------
~$ ./soc_riscv_litex_acc_sim.py --cpu-type=vexriscv \
    --integrated-rom-init=firmware.bin \
    --integrated-rom-size=0x8000 \
    --integrated-sram-size=0x40000 \
    --trace 

