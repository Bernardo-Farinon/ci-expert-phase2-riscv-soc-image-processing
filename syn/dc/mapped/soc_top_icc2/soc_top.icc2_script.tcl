set _DCG_ICC2_DIR_ [file dirname [file normalize [info script]]]



##################################################################
# Default operating conditions
##################################################################
echo "Information: IC Compiler II will be using the default operating condition inferred by DCNXT."




##################################################################
# Read Design
##################################################################
if {[file exists ${_DCG_ICC2_DIR_}/soc_top.v]} {
read_verilog ${_DCG_ICC2_DIR_}/soc_top.v -top soc_top
}



##################################################################
# Read settings
##################################################################
if {[file exists ${_DCG_ICC2_DIR_}/soc_top.settings.tcl]} {
source -continue_on_error ${_DCG_ICC2_DIR_}/soc_top.settings.tcl 
}



##################################################################
# Read SDC
##################################################################
if {[file exists ${_DCG_ICC2_DIR_}/soc_top.MCMM/top.tcl]} {
source -continue_on_error ${_DCG_ICC2_DIR_}/soc_top.MCMM/top.tcl 
}



##################################################################
# Read Floorplan
##################################################################
if {[file exists ${_DCG_ICC2_DIR_}/soc_top.floorplan/floorplan.tcl]} {
source -continue_on_error ${_DCG_ICC2_DIR_}/soc_top.floorplan/floorplan.tcl 
}



##################################################################
# Read scan DEF
##################################################################
if {[file exists ${_DCG_ICC2_DIR_}/soc_top.scan.def]} {
read_def ${_DCG_ICC2_DIR_}/soc_top.scan.def 
}



##################################################################
# Read cell expansion data
##################################################################
if {[file exists ${_DCG_ICC2_DIR_}/soc_top.cell.exp]} {
read_cell_expansion -input ${_DCG_ICC2_DIR_}/soc_top.cell.exp 
}



