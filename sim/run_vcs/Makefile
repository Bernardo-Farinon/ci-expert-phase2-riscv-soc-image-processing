RTL_DIR  = ../../rtl
SOC_DIR  = $(RTL_DIR)/soc_top
VEX_DIR  = $(RTL_DIR)/vexriscv
TB_DIR   = ../../bench

VERDI_HOME ?= /tools/synopsys/verdi/W-2024.09-SP2-6

INCDIRS  = +incdir+$(RTL_DIR) +incdir+$(SOC_DIR) +incdir+$(VEX_DIR)
SOURCES  = $(SOC_DIR)/soc_top.v \
           $(VEX_DIR)/*.v \
           $(TB_DIR)/tb_soc_top.v

SIM_EXEC = simv_soc

.PHONY: all clean compile run

all: clean compile run

compile:
	export VERDI_HOME=$(VERDI_HOME) && \
	vcs -full64 -sverilog -kdb -lca \
		-debug_access+all \
		$(INCDIRS) \
		$(SOURCES) \
		-o $(SIM_EXEC)

run:
	ln -sf $(VEX_DIR)/*.init .
	export VERDI_HOME=$(VERDI_HOME) && \
	./$(SIM_EXEC)

clean:
	rm -rf csrc *.daidir $(SIM_EXEC) *.log *.key *.fsdb novas.* verdiLog AN.DB work.lib++ *.init
