# Configura ambiente
source setup.tcl

# Carrega .db
read_db $TARGET_LIBRARY_FILES
report_lib $TARGET_LIBRARY_FILES > report_lib_saed32lvt.txt

# Análise
analyze -format sverilog {\
	../../rtl/vexriscv/DataCache.v \
	../../rtl/vexriscv/InstructionCache.v \
	../../rtl/vexriscv/VexRiscv.v \
   ../../rtl/soc_top/soc_top.v \
}

# Elaboração
elaborate soc_top

# Link e Check
if {[link] == 0}{
    exit
}

check_design -html check_soc_top.html

# Salva no formato GTECH
write_file -format ddc -hier -output ../unmapped/soc_top.ddc




