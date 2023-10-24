# TCL File Generated by Component Editor 22.1
# Tue Oct 24 21:39:08 CEST 2023
# DO NOT MODIFY


# 
# ci_div "ci_div" v1.0
#  2023.10.24.21:39:08
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module ci_div
# 
set_module_property DESCRIPTION ""
set_module_property NAME ci_div
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME ci_div
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL ci_div
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file math_pkg.vhd VHDL PATH ../vhdl/math/math_pkg.vhd
add_fileset_file alt_fwft_fifo.vhd VHDL PATH ../vhdl/fifo/alt_fwft_fifo.vhd
add_fileset_file ci_div.vhd VHDL PATH ../vhdl/div/ci_div.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point nios_custom_instruction_slave
# 
add_interface nios_custom_instruction_slave nios_custom_instruction end
set_interface_property nios_custom_instruction_slave clockCycle 0
set_interface_property nios_custom_instruction_slave operands 2
set_interface_property nios_custom_instruction_slave ENABLED true
set_interface_property nios_custom_instruction_slave EXPORT_OF ""
set_interface_property nios_custom_instruction_slave PORT_NAME_MAP ""
set_interface_property nios_custom_instruction_slave CMSIS_SVD_VARIABLES ""
set_interface_property nios_custom_instruction_slave SVD_ADDRESS_GROUP ""

add_interface_port nios_custom_instruction_slave clk_en clk_en Input 1
add_interface_port nios_custom_instruction_slave dataa dataa Input 32
add_interface_port nios_custom_instruction_slave datab datab Input 32
add_interface_port nios_custom_instruction_slave result result Output 32
add_interface_port nios_custom_instruction_slave start start Input 1
add_interface_port nios_custom_instruction_slave done done Output 1
add_interface_port nios_custom_instruction_slave n n Input 1
add_interface_port nios_custom_instruction_slave clk clk Input 1
add_interface_port nios_custom_instruction_slave reset reset Input 1

