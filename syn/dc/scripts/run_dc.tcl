# ------------------------------------------------------
# Configura ambiente
# ------------------------------------------------------
source setup.tcl

report_lib $target_library

# Gera .svf para o Formality
set_svf ./scripts/soc_top.svf

# ------------------------------------------------------
# Análise, elaboração, link e verificação
# ------------------------------------------------------
# Análise
analyze -format sverilog {\
	../../rtl/vexriscv/DataCache.v \
	../../rtl/vexriscv/InstructionCache.v \
	../../rtl/vexriscv/VexRiscv.v \
    ../../rtl/soc_top/soc_top.v \
}

# Elaboração
elaborate soc_top
current_design soc_top

# Vincula as instâncias às células do PDK
if {[link] == 0} { exit }

# Verifica se há referências não resolvidas ou múltiplos drivers
check_design -unresolved

# ------------------------------------------------------
# salva do projeto como ddc unmapped
# ------------------------------------------------------

write_file -format ddc -hier -out ./unmapped/soc_top.ddc

# ------------------------------------------------------
# carrega e verifica as restrições de temporização
# ------------------------------------------------------
source -echo scripts/soc_top.con

report_timing

check_timing 

report_clock

report_clock -skew

report_port -verbose

# ------------------------------------------------------
# aplica as restrições físicas para pre-floorplan
# ------------------------------------------------------
source -echo scripts/soc_top.pcon


# configura as direções de roteamento

set_preferred_routing_direction -layers {M1 M3 M5 M7 M9} -direction horizontal

set_preferred_routing_direction -layers {M2 M4 M6 M8 MRDL} -direction vertical

# lê as constraints físicas para floorplan

report_physical_constraints

# aplica comando para otimização multicore

set_host_options -max_cores 16 ;# valor máximo

# ------------------------------------------------------
# Compila o projeto, inserindo as estruturas de scan-chain,
# permitindo retimng para melhoria da temporização
# ------------------------------------------------------

# Previne desagrupamento do projeto (ou usar compile_ultra -no_autoungroup)
set_ungroup soc_top false
#compile_ultra -no_autoungroup

# Previne que hierarquias DesignWare sejam desagrupadas:
set_app_var compile_ultra_ungroup_dw false

# Desabilita otimizações de contorno
set_boundary_optimization soc_top false


# Prioritize setup timing or max-delay over DRC
set_cost_priority –delay



compile_ultra -spg -retime -scan 

# verifica a hierarquia resultante

report_hierarchy -noleaf

# gera um relatório dos operadores de datapath (DW para DesignWare)
report_resources

# gera um relatório das constraints

redirect -tee -file rc_compile_ultra.rpt {rc}

redirect -tee -file rt_compile_ultra.rpt {rt}

# ------------------------------------------------------
# Salva o projeto para nível de portas mapeadas na biblioteca
# ------------------------------------------------------

write_file -format ddc -hier -out ./mapped/soc_top.ddc
write_file -format verilog -hier -out ./mapped/soc_top_ntl.v
write_icc2_files -out ./mapped/soc_top_icc2

 ------------------------------------------------------
# Para de gravar as alterações de projeto no .svf praa o Formality
# ------------------------------------------------------

set_svf -off

# ------------------------------------------------------
# Faz o report das constraints físicas
# ------------------------------------------------------

report_physical_constraints

