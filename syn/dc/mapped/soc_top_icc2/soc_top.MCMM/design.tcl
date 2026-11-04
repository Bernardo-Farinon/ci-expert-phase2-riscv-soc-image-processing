if { [namespace current] != {::6AE6C533} } { error {This script [file tail [info script]] should not be sourced directly}; }
###################################################################

# Created by write_script -format dctcl for global constraints on Sun Nov  1   \
01:50:59 2026

###################################################################

# Set the current_design #
current_design soc_top

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA
set_local_link_library {saed32lvt_ss0p75v125c.db}
set_register_merging [current_design] 17
set_multibit_options -mode non_timing_driven
set_register_merging [get_cells {uart_core_rx_fifo_level0_reg[2]}] 17
set_register_merging [get_cells {uart_core_rx_fifo_level0_reg[3]}] 17
set_register_merging [get_cells {uart_core_rx_fifo_level0_reg[4]}] 17
set_register_merging [get_cells {uart_core_rx_fifo_level0_reg[0]}] 17
set_register_merging [get_cells {uart_core_rx_fifo_level0_reg[1]}] 17
set compile_inbound_cell_optimization false
set compile_inbound_max_cell_percentage 10.0
