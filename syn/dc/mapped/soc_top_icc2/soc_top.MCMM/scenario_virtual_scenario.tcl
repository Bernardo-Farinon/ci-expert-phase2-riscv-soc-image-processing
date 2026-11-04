if { [namespace current] != {::6AE6C533} } { error {This script [file tail [info script]] should not be sourced directly}; }
###################################################################

# Created by write_script -format dctcl for scenario constraints on Sun Nov 1 01:50:59 2026

###################################################################

# Set the current_design #
current_design soc_top


set_tlu_plus_files -max_tluplus /home/ciexpert/alexsandro.bonatto/pdk/tech/saed32nm_1p9m_Cmax.tluplus -tech2itf_map /home/ciexpert/alexsandro.bonatto/pdk/tech/saed32nm_tf_itf_tluplus.map 
set_operating_conditions ss0p75v125c -library saed32lvt_ss0p75v125c
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[7]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[6]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[5]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[4]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[3]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[2]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[1]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports {serial_sink_data[0]}]
set_switching_activity -period 1 -toggle_rate 0.1 -static_probability 0.5 [get_ports serial_source_ready]
set_switching_activity -period 1 -toggle_rate 0.00390625 -static_probability 0.667252 [get_pins {uart_core_rx_fifo_level0_reg[2]/QN}]
set_switching_activity -period 1 -toggle_rate 0.00195312 -static_probability 0.665924 [get_pins {uart_core_rx_fifo_level0_reg[3]/QN}]
set_switching_activity -period 1 -toggle_rate 0.000976562 -static_probability 0.640137 [get_pins {uart_core_rx_fifo_level0_reg[4]/QN}]
set_switching_activity -period 1 -toggle_rate 0.015625 -static_probability 0.684738 [get_pins {uart_core_rx_fifo_level0_reg[0]/QN}]
set_switching_activity -period 1 -toggle_rate 0.0078125 -static_probability 0.676666 [get_pins {uart_core_rx_fifo_level0_reg[1]/QN}]
set compile_inbound_cell_optimization false
set compile_inbound_max_cell_percentage 10.0
