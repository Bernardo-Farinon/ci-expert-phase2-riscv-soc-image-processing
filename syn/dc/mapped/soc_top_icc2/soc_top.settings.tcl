
##################################################################
# Created by :	Design Compiler (R) NXT (Topographical)
# Version    :	W-2024.09-SP5-4 Sep 10, 2025
# Date       :	Sun Nov  1 01:50:59 2026
# Command    :	write_icc2_files -environment_only	\
#		-o ./mapped/soc_top_icc2/soc_top.settings.tcl 
##################################################################

##################################################################
# Set application variables for app 
##################################################################
set_app_var search_path "$search_path .                                        \
/tools/synopsys/designcompiler/W-2024.09-SP5-4/libraries/syn                   \
/tools/synopsys/designcompiler/W-2024.09-SP5-4/dw/syn_ver                      \
/tools/synopsys/designcompiler/W-2024.09-SP5-4/dw/sim_ver ~/pdk/DBs            \
~/pdk/CLIBs ~/pdk/tech ./rtl ./scripts ~/pdk/DBs ~/pdk/CLIBs ~/pdk/tech ./rtl  \
./scripts "

##################################################################
# Set application variables for design 
##################################################################
set_app_options -name design.bus_delimiters -value {[]}

##################################################################
# Set application variables for mv 
##################################################################
set_app_options -name mv.cells.no_main_power_violations -value true 

##################################################################
# Set application variables for power 
##################################################################
set_app_options -name power.default_static_probability -value 0.5 
set_app_options -name power.default_toggle_rate -value 0.1 
set_app_options -name power.default_toggle_rate_reference_clock -value fastest
set_app_options -name mv.upf.enable_golden_upf -value false 

##################################################################
# Set application variables for time 
##################################################################
set_app_options -name time.enable_clock_to_data_analysis -value false 
set_app_options -name time.high_fanout_net_pin_capacitance -value 1000pF
set_app_options -name time.high_fanout_net_threshold -value 1000 
set_app_options -name time.use_special_default_path_groups -value false 
set_app_options -name time.remove_clock_reconvergence_pessimism -value false 
set_app_options -name time.gclock_source_network_num_master_registers -value   \
10000000 
set_app_options -name time.disable_cond_default_arcs -value false 
set_app_options -name time.crpr_remove_clock_to_data_crp -value false 
set_app_options -name time.clock_reconvergence_pessimism -value normal 
set_app_options -name time.case_analysis_sequential_propagation -value never 

##################################################################
# Set application variables for place 
##################################################################
set_app_options -name place.coarse.channel_detect_mode -value false
set_app_options -name place.coarse.icg_auto_bound -value false
set_app_options -name place.coarse.enable_enhanced_soft_blockages -value true 

##################################################################
# Set application variables for opt 
##################################################################
set_app_options -name opt.timing.effort -value low

##################################################################
# Set attributes 
##################################################################

##################################################################
# Commands 
##################################################################
